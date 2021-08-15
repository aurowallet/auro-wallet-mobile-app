#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include "base10.h"
#include "utils.h"

void decimalint_add(DecimalInt out, const DecimalInt x1, const DecimalInt x2) {
  uint8_t carry = 0;

  for (size_t i = 0; i < DIGITS; ++i) {
    const uint8_t a = x1[i] + x2[i] + carry;
    out[i] = a % 10;
    carry = a / 10;
  }

  if (carry != 0) {
    printf("decimalint_add: overflow");
    exit(1);
  }
}

void decimalint_copy(DecimalInt out, const DecimalInt x) {
  for (size_t i = 0; i < DIGITS; ++i) {
    out[i] = x[i];
  }
}

void decimalint_from_bigint(DecimalInt out, const uint64_t x[4]) {
  const size_t NUM_BITS = 64 * 4;

  DecimalInt tmp;

  DecimalInt one;
  one[0] = 1;
  for (size_t i = 1; i < DIGITS; ++i) {
    one[i] = 0;
  }

  for (size_t i = 0; i < DIGITS; ++i) {
    out[i] = 0;
  }

  // Double and add
  for (size_t i = 0; i < NUM_BITS; ++i) {
    decimalint_add(tmp, out, out);

    const size_t j = NUM_BITS - 1 - i;
    size_t limb_idx = j / 64;
    size_t in_limb_idx = (j % 64);
    bool bj = (x[limb_idx] >> in_limb_idx) & 1;

    if (bj) {
      decimalint_add(out, tmp, one);
    } else {
      decimalint_copy(out, tmp);
    }
  }
}

void decimalint_to_string(char* out, const DecimalInt x) {
  int i = DIGITS - 1;

  while (x[i] == 0 && i != 0) {
    i -= 1;
  }

  size_t j = 0;
  while (i >= 0) {
    out[j] = '0' + x[i];

    i -= 1;
    j += 1;
  }
  out[j] = '\0';
}

void bigint_to_string(char* out, const uint64_t x[4]) {
  DecimalInt tmp;
  decimalint_from_bigint(tmp, x);
  decimalint_to_string(out, tmp);
}
