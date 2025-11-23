#include "jacobi_core.h"
#include <cmath>

// Length parameters (185, 170, 77, 23, 171/2, 230) in mm units

void jacobi_zjui_core(const double q[6], double J[36]) {
  const double q1 = q[0];
  const double q2 = q[1];
  const double q3 = q[2];
  const double q4 = q[3];
  const double q5 = q[4];
  // q6 not used in geometric Jacobian

  const double Sigma = q2 + q3 + q4;

  const double s1 = std::sin(q1);
  const double c1 = std::cos(q1);
  const double s2 = std::sin(q2);
  const double c2 = std::cos(q2);
  const double s23 = std::sin(q2 + q3);
  const double c23 = std::cos(q2 + q3);
  const double sSig = std::sin(Sigma);
  const double cSig = std::cos(Sigma);
  const double s5 = std::sin(q5);
  const double c5 = std::cos(q5);

  const double k = 171.0 / 2.0;

  // Column 1
  const double J1vx = -185.0 * s1 * s2 - 170.0 * s1 * s23 - 77.0 * s1 * sSig -
                      k * s1 * c5 * cSig - k * s5 * c1 - 23.0 * c1;

  const double J1vy = -k * s1 * s5 - 23.0 * s1 + 185.0 * s2 * c1 +
                      170.0 * s23 * c1 + 77.0 * sSig * c1 + k * c1 * c5 * cSig;

  // Linear velocity
  J[0 * 6 + 0] = J1vx;
  J[1 * 6 + 0] = J1vy;
  J[2 * 6 + 0] = 0.0;
  // Angular velocity: z1 = [0,0,1]^T
  J[3 * 6 + 0] = 0.0;
  J[4 * 6 + 0] = 0.0;
  J[5 * 6 + 0] = 1.0;

  // Column 2
  const double common2 =
      -k * sSig * c5 + 185.0 * c2 + 170.0 * c23 + 77.0 * cSig;

  const double J2vx = c1 * common2;
  const double J2vy = s1 * common2;
  const double J2vz = -185.0 * s2 - 170.0 * s23 - 77.0 * sSig - k * c5 * cSig;

  J[0 * 6 + 1] = J2vx;
  J[1 * 6 + 1] = J2vy;
  J[2 * 6 + 1] = J2vz;
  // Angular velocity: z2 = [-sin(q1), cos(q1), 0]^T
  J[3 * 6 + 1] = -s1;
  J[4 * 6 + 1] = c1;
  J[5 * 6 + 1] = 0.0;

  // Column 3
  const double common3 = -k * sSig * c5 + 170.0 * c23 + 77.0 * cSig;

  const double J3vx = c1 * common3;
  const double J3vy = s1 * common3;
  const double J3vz = -170.0 * s23 - 77.0 * sSig - k * c5 * cSig;

  J[0 * 6 + 2] = J3vx;
  J[1 * 6 + 2] = J3vy;
  J[2 * 6 + 2] = J3vz;
  // Angular velocity: z3 = z2
  J[3 * 6 + 2] = -s1;
  J[4 * 6 + 2] = c1;
  J[5 * 6 + 2] = 0.0;

  // Column 4
  const double common4 = -k * sSig * c5 + 77.0 * cSig;

  const double J4vx = c1 * common4;
  const double J4vy = s1 * common4;
  const double J4vz = -77.0 * sSig - k * c5 * cSig;

  J[0 * 6 + 3] = J4vx;
  J[1 * 6 + 3] = J4vy;
  J[2 * 6 + 3] = J4vz;
  // Angular velocity: z4 = z2
  J[3 * 6 + 3] = -s1;
  J[4 * 6 + 3] = c1;
  J[5 * 6 + 3] = 0.0;

  // Column 5
  const double J5vx = -k * s1 * c5 - k * s5 * c1 * cSig;

  const double J5vy = -k * s1 * s5 * cSig + k * c1 * c5;

  const double J5vz = k * s5 * sSig;

  J[0 * 6 + 4] = J5vx;
  J[1 * 6 + 4] = J5vy;
  J[2 * 6 + 4] = J5vz;
  // Angular velocity: z5
  J[3 * 6 + 4] = sSig * c1;
  J[4 * 6 + 4] = s1 * sSig;
  J[5 * 6 + 4] = cSig;

  // Column 6
  // Linear velocity is zero
  J[0 * 6 + 5] = 0.0;
  J[1 * 6 + 5] = 0.0;
  J[2 * 6 + 5] = 0.0;

  // Angular velocity: z6
  const double J6wx = -s1 * s5 + c1 * c5 * cSig;
  const double J6wy = s1 * c5 * cSig + s5 * c1;
  const double J6wz = -sSig * c5;

  J[3 * 6 + 5] = J6wx;
  J[4 * 6 + 5] = J6wy;
  J[5 * 6 + 5] = J6wz;

  // Convert linear velocity from mm to m
  const double scale = 1e-3;
  for (int col = 0; col < 6; ++col) {
    for (int row = 0; row < 3; ++row) {
      J[row * 6 + col] *= scale;
    }
  }
}
