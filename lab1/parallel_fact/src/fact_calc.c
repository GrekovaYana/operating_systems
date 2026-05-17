#include "fact_calc.h"

int fact_calc(int n) {
    if (n <= 1) return 1;
    return n * fact_calc(n - 1);
}