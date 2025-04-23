#include <stdio.h>
#include <math.h>
#include <stdint.h>

int main() {
    FILE *fp;
    int n;
    double atan_value_radian;
    double atan_value_degree;
    int64_t fixed_point_value;

    // 開啟 arctan_table_verilog.txt
    fp = fopen("arctan_table_verilog.txt", "w");
    if (fp == NULL) {
        printf("Failed to open output file!\n");
        return 1;
    }

    // 計算 n = 0 ~ 63
    for (n = 0; n <= 63; n++) {
        double x = 1.0 / (1ULL << n);  // 1/(2^n)

        // 計算 arctan，先得到 radians
        atan_value_radian = atan(x);
        // 再從 radians 轉成 degrees
        atan_value_degree = atan_value_radian * (180.0 / M_PI);

        // 轉成 Q9.55：乘上 2^55，再四捨五入成整數
        fixed_point_value = (int64_t)round(atan_value_degree * (1ULL << 55));

        // 輸出成十六進位，固定16個字元（64位）
        fprintf(fp, "%016llx\n", (unsigned long long)fixed_point_value);
    }

    fclose(fp);
    printf("arctan degree values written to arctan_table_verilog.txt (Q9.55 format)\n");
    return 0;
}


// #include <stdio.h>
// #include <math.h>

// int main() {
//     FILE *fp;
//     int n;
//     double atan_value_radian;
//     double atan_value_degree;

//     // 開啟 arctan.txt 準備寫入
//     fp = fopen("arctan.txt", "w");
//     if (fp == NULL) {
//         printf("Failed to open file!\n");
//         return 1;
//     }

//     // 計算 n = 0 ~ 63
//     for (n = 0; n <= 63; n++) {
//         double x = 1.0 / (1ULL << n);  // 1/(2^n)

//         atan_value_radian = atan(x); // 計算 arctan(x)，單位是 "弧度" radians
//         atan_value_degree = atan_value_radian * (180.0 / M_PI); // 轉換成度 (degree)

//         // 寫入檔案：以degree為單位
//         fprintf(fp, "n = %2d : arctan(1/2^%d) = %.15f degrees\n", n, n, atan_value_degree);
//     }

//     fclose(fp);

//     printf("arctan values written to arctan.txt (in degrees)\n");
//     return 0;
// }
