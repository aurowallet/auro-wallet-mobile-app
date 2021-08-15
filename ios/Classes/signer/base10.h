#include <stdint.h>
#define DIGITS 78

typedef uint8_t DecimalInt[DIGITS];

void bigint_to_string(char* out, const uint64_t x[4]);
