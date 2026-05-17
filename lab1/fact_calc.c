/*
 * Автор: Грекова Яна Викторовна
 * Группа: 02271-ДБ
 * Лабораторная работа №1
 */

#include <stdio.h>

int fact_calc(int n) {
    if (n <= 1) return 1;
    return n * fact_calc(n - 1);
}

int main() {
    printf("%d\n", fact_calc(7));
    return 0;
}