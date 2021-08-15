#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

void fiat_pasta_fq_set_one(uint64_t out1[4]);
void fiat_pasta_fq_add(uint64_t out1[4], const uint64_t arg1[4], const uint64_t arg2[4]);
void fiat_pasta_fq_sub(uint64_t out1[4], const uint64_t arg1[4], const uint64_t arg2[4]);
void fiat_pasta_fq_mul(uint64_t out1[4], const uint64_t arg1[4], const uint64_t arg2[4]);
void fiat_pasta_fq_opp(uint64_t out1[4], const uint64_t arg1[4]);
void fiat_pasta_fq_square(uint64_t out1[4], const uint64_t arg1[4]);
bool fiat_pasta_fq_equals(const uint64_t x[4], const uint64_t y[4]);
void fiat_pasta_fq_to_montgomery(uint64_t out1[4], const uint64_t arg1[4]);
void fiat_pasta_fq_from_montgomery(uint64_t out1[4], const uint64_t arg1[4]);
void fiat_pasta_fq_nonzero(uint64_t* out1, const uint64_t arg1[4]);
void fiat_pasta_fq_copy(uint64_t out[4], const uint64_t value[4]);
void fiat_pasta_fq_print(const uint64_t x[4]);
