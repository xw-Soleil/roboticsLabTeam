from setuptools import setup
from pybind11.setup_helpers import Pybind11Extension, build_ext

# Extension module configuration
ext_modules = [
    Pybind11Extension(
        "jacobi_zjui",
        ["jacobi_zjui_module.cpp", "jacobi_core.cpp"],
    ),
]

# Package setup
setup(
    name="jacobi_zjui",
    version="0.1",
    ext_modules=ext_modules,
    cmdclass={"build_ext": build_ext},
)
