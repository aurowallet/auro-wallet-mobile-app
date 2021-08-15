#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

void fiat_pasta_fp_sqrt(uint64_t x[4], const uint64_t value[4]);
void fiat_pasta_fp_set_one(uint64_t out1[4]);
void fiat_pasta_fp_add(uint64_t out1[4], const uint64_t arg1[4], const uint64_t arg2[4]);
void fiat_pasta_fp_sub(uint64_t out1[4], const uint64_t arg1[4], const uint64_t arg2[4]);
void fiat_pasta_fp_mul(uint64_t out1[4], const uint64_t arg1[4], const uint64_t arg2[4]);
void fiat_pasta_fp_inv(uint64_t out1[4], const uint64_t arg1[4]);
void fiat_pasta_fp_opp(uint64_t out1[4], const uint64_t arg1[4]);
void fiat_pasta_fp_square(uint64_t out1[4], const uint64_t arg1[4]);
bool fiat_pasta_fp_equals_one(const uint64_t x[4]);
bool fiat_pasta_fp_equals(const uint64_t x[4], const uint64_t y[4]);
void fiat_pasta_fp_pow(uint64_t out1[4], const uint64_t arg1[4], const bool* msb_bits, const size_t bits_len);
void fiat_pasta_fp_print(const uint64_t x[4]);
void fiat_pasta_fp_to_montgomery(uint64_t out1[4], const uint64_t arg1[4]);
void fiat_pasta_fp_from_montgomery(uint64_t out1[4], const uint64_t arg1[4]);
void fiat_pasta_fp_copy(uint64_t out[4], const uint64_t value[4]);
