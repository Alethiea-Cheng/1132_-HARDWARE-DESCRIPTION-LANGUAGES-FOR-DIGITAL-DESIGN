#include <stdio.h>
#include <stdint.h>
#include <math.h>
#include <string.h>

#define ITERATIONS 16
#define Q9_55_SHIFT 55
#define DEGREE_SCAN 91
#define FULL_CIRCLE 360

// Q9.55 format arctan table (degree)
uint64_t arctan_table_q955[64] = {
    0x1680000000000000, 0x0d485398d30ee200, 0x0704a3a03eb80b80, 0x0390008924ffd060,
    0x01c9c55326164cf0, 0x00e51bca72971540, 0x0072950d58cc3ad8, 0x00394b6bd0893ee4,
    0x001ca5d28dcac943, 0x000e52ecdb9e3864, 0x00072976e066771f, 0x000394bb7e8628f1,
    0x0001ca5dc10d7235, 0x0000e52ee0c004d2, 0x0000729770672be0, 0x0000394bb8347b1f,
    0x00001ca5dc1a5a35, 0x00000e52ee0d30af, 0x00000729770698ca, 0x00000394bb834c73,
    0x000001ca5dc1a63c, 0x000000e52ee0d31e, 0x000000729770698f, 0x000000394bb834c8,
    0x0000001ca5dc1a64, 0x0000000e52ee0d32, 0x0000000729770699, 0x0000000394bb834c,
    0x00000001ca5dc1a6, 0x00000000e52ee0d3, 0x000000007297706a, 0x00000000394bb835,
    0x000000001ca5dc1a, 0x000000000e52ee0d, 0x0000000007297707, 0x000000000394bb83,
    0x0000000001ca5dc2, 0x0000000000e52ee1, 0x0000000000729770, 0x0000000000394bb8,
    0x00000000001ca5dc, 0x00000000000e52ee, 0x0000000000072977, 0x00000000000394bc,
    0x000000000001ca5e, 0x000000000000e52f, 0x0000000000007297, 0x000000000000394c,
    0x0000000000001ca6, 0x0000000000000e53, 0x0000000000000729, 0x0000000000000395,
    0x00000000000001ca, 0x00000000000000e5, 0x0000000000000073, 0x0000000000000039,
    0x000000000000001d, 0x000000000000000e, 0x0000000000000007, 0x0000000000000004,
    0x0000000000000002, 0x0000000000000001, 0x0000000000000000, 0x0000000000000000
};
// TA golden sin values (Q2.10 hex)
char* sin_ta_golden[DEGREE_SCAN] = {
        "000","012","024","036","047","059","06b","07d","08f","0a0",
        "0b2","0c3","0d5","0e6","0f8","109","11a","12b","13c","14d",
        "15e","16f","180","190","1a0","1b1","1c1","1d1","1e1","1f0",
        "200","20f","21f","22e","23d","24b","25a","268","276","284",
        "292","2a0","2ad","2ba","2c7","2d4","2e1","2ed","2f9","305",
        "310","31c","327","332","33c","347","351","35b","364","36e",
        "377","380","388","390","398","3a0","3a7","3af","3b5","3bc",
        "3c2","3c8","3ce","3d3","3d8","3dd","3e2","3e6","3ea","3ed",
        "3f0","3f3","3f6","3f8","3fa","3fc","3fe","3ff","3ff","400","400"
    };
    
    // TA golden cos values (Q2.10 hex)
    char* cos_ta_golden[DEGREE_SCAN] = {
        "400","400","3ff","3ff","3fe","3fc","3fa","3f8","3f6","3f3",
        "3f0","3ed","3ea","3e6","3e2","3dd","3d8","3d3","3ce","3c8",
        "3c2","3bc","3b5","3af","3a7","3a0","398","390","388","380",
        "377","36e","364","35b","351","347","33c","332","327","31c",
        "310","305","2f9","2ed","2e1","2d4","2c7","2ba","2ad","2a0",
        "292","284","276","268","25a","24b","23d","22e","21f","20f",
        "200","1f0","1e1","1d1","1c1","1b1","1a0","190","180","16f",
        "15e","14d","13c","12b","11a","109","0f8","0e6","0d5","0c3",
        "0b2","0a0","08f","07d","06b","059","047","036","024","012","000"
    };
// tie-to-even rounding for Q2.10
int16_t round_to_nearest_tie_even(double val) {
    double scaled = val * 1024.0;
    double floor_val = floor(scaled);
    double frac = scaled - floor_val;

    if (frac < 0.5) {
        return (int16_t)floor_val;
    } else if (frac > 0.5) {
        return (int16_t)(floor_val + 1.0);
    } else {
        if (((int64_t)floor_val) & 1) {
            return (int16_t)(floor_val + 1.0);
        } else {
            return (int16_t)floor_val;
        }
    }
}

int main() {
    double cordic_sin[DEGREE_SCAN];
    double cordic_cos[DEGREE_SCAN];
    double cumulative_K = 1.0;

    // Calculate cumulative K value
    for (int n = 0; n < ITERATIONS; n++) {
        double K = 1.0 / sqrt(1.0 + pow(2.0, -2 * n));
        cumulative_K *= K;
    }

    printf("\nCumulative K after %d iterations = %.15f\n\n", ITERATIONS, cumulative_K);
    // Q2,62 representation
    int64_t cumulative_K_q2_62 = (int64_t)llrint(cumulative_K * (1LL << 62));
    printf("Cumulative K (Q2.62) = 0x%016llx\n\n", (unsigned long long)cumulative_K_q2_62);

    // Calculate 0~90 degree using CORDIC
    for (int angle = 0; angle <= 90; angle++) {
        double X = 1.0;
        double Y = 0.0;
        double Z = (double)angle;

        for (int n = 0; n < ITERATIONS; n++) {
            double atan_deg = (n < 64) ? (double)((int64_t)arctan_table_q955[n]) / (1LL << Q9_55_SHIFT) : 0.0;
            double K = 1.0 / sqrt(1.0 + pow(2.0, -2 * n));
            int d = (Z >= 0) ? 1 : -1;

            double Xn1 = K * (X - d * Y * pow(2.0, -n));
            double Yn1 = K * (Y + d * X * pow(2.0, -n));
            double Zn1 = Z - d * atan_deg;

            X = Xn1;
            Y = Yn1;
            Z = Zn1;
        }

        if (Y > 0.9995) Y = 1.0;
        if (X > 0.9995) X = 1.0;

        cordic_sin[angle] = Y;
        cordic_cos[angle] = X;

        // Check against TA golden
        int16_t y_q2_10 = round_to_nearest_tie_even(Y);
        int16_t x_q2_10 = round_to_nearest_tie_even(X);

        uint16_t y_q2_10_unsigned = (uint16_t)y_q2_10 & 0xFFF;
        uint16_t x_q2_10_unsigned = (uint16_t)x_q2_10 & 0xFFF;

        char my_result_sin[4], my_result_cos[4];
        sprintf(my_result_sin, "%03x", y_q2_10_unsigned);
        sprintf(my_result_cos, "%03x", x_q2_10_unsigned);

        printf("Angle %3d deg: SIN %s (%s) | COS %s (%s)\n",
            angle,
            (strcasecmp(my_result_sin, sin_ta_golden[angle]) == 0) ? "PASS" : "FAIL",
            my_result_sin,
            (strcasecmp(my_result_cos, cos_ta_golden[angle]) == 0) ? "PASS" : "FAIL",
            my_result_cos);
    }

    // Generate 0~359 full circle
    printf("\nFull 0~359 Degree Table (Q2.10):\n");
    printf("Angle  SIN(Q2.10)  COS(Q2.10)\n");

    for (int angle = 0; angle < FULL_CIRCLE; angle++) {
        double sin_val = 0.0;
        double cos_val = 0.0;

        if (angle <= 90) {
            sin_val = cordic_sin[angle];
            cos_val = cordic_cos[angle];
        } else if (angle <= 180) {
            sin_val = cordic_sin[180 - angle];
            cos_val = -cordic_cos[180 - angle];
        } else if (angle <= 270) {
            sin_val = -cordic_sin[angle - 180];
            cos_val = -cordic_cos[angle - 180];
        } else {
            sin_val = -cordic_sin[360 - angle];
            cos_val = cordic_cos[360 - angle];
        }

        int16_t sin_q2_10 = round_to_nearest_tie_even(sin_val);
        int16_t cos_q2_10 = round_to_nearest_tie_even(cos_val);

        uint16_t sin_q2_10_unsigned = (uint16_t)sin_q2_10 & 0xFFF;
        uint16_t cos_q2_10_unsigned = (uint16_t)cos_q2_10 & 0xFFF;

        printf("%3d    %03x         %03x\n", angle, sin_q2_10_unsigned, cos_q2_10_unsigned);
    }

    return 0;
}
