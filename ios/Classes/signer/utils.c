#include "utils.h"

// Not constant time
void packed_bit_array_set(uint8_t *bits, size_t i, bool b) {
  size_t byte_idx = i / 8;
  size_t in_byte_idx = i % 8;

  if (b) {
    bits[byte_idx] |= (1 << in_byte_idx);
  } else {
    bits[byte_idx] &= ~( (uint8_t)(1 << in_byte_idx) );
  }
}

bool packed_bit_array_get(uint8_t *bits, size_t i) {
  size_t byte_idx = i / 8;
  size_t in_byte_idx = i % 8;

  return (bits[byte_idx] >> in_byte_idx) & 1;
}
