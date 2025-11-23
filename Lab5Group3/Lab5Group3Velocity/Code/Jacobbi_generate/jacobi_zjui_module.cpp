#include "jacobi_core.h"
#include <pybind11/numpy.h>
#include <pybind11/pybind11.h>

namespace py = pybind11;

// Python wrapper for Jacobian computation
py::array_t<double>
jacobi_py(py::array_t<double, py::array::c_style | py::array::forcecast> q_in) {
  if (q_in.size() != 6)
    throw std::runtime_error("q must be length 6");

  // Extract joint angles from numpy array
  double q[6];
  auto buf = q_in.request();
  double *qptr = static_cast<double *>(buf.ptr);
  for (int i = 0; i < 6; ++i)
    q[i] = qptr[i];

  // Compute Jacobian
  double J[36];
  jacobi_zjui_core(q, J);

  // Return 6x6 numpy array
  auto result = py::array_t<double>({6, 6});
  auto rbuf = result.request();
  double *rptr = static_cast<double *>(rbuf.ptr);
  for (int i = 0; i < 36; ++i)
    rptr[i] = J[i];

  return result;
}

PYBIND11_MODULE(jacobi_zjui, m) {
  m.doc() = "Geometric Jacobian for ZJU-I arm";
  m.def("jacobi", &jacobi_py, "Compute 6x6 Jacobian J(q)");
}
