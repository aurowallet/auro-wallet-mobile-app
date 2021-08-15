// Mina schnorr signatures and eliptic curve arithmatic
//
//     * Produces a schnorr signature according to the specification here:
//       https://github.com/MinaProtocol/mina/blob/develop/docs/specs/signatures/description.md
//
//     * Signer reference here: https://github.com/MinaProtocol/signer-reference
//
//     * Curve arithmatic
//         - field_add, field_sub, field_mul, field_sq, field_inv, field_negate, field_pow, field_eq
//         - scalar_add, scalar_sub, scalar_mul, scalar_sq, scalar_pow, scalar_eq
//         - group_add, group_dbl, group_scalar_mul (group elements use projective coordinates)
//         - affine_scalar_mul
//         - affine_from_group
//         - generate_pubkey, generate_keypair
//         - sign
//
//     * Curve details
//         Pasta.Pallas (https://github.com/zcash/pasta)
//         E1/Fp : y^2 = x^3 + 5
//         GROUP_ORDER   = 28948022309329048855892746252171976963363056481941647379679742748393362948097 (Fq, 0x94)
//         FIELD_MODULUS = 28948022309329048855892746252171976963363056481941560715954676764349967630337 (Fp, 0x4c)

// #include <assert.h>

#define THROW exit

#include <assert.h>
#include <inttypes.h>

#include "crypto.h"
#include "utils.h"
#include "poseidon.h"
#include "pasta_fp.h"
#include "pasta_fq.h"
#include "blake2.h"
#include "libbase58.h"
#include "sha256.h"

State MAINNET_INIT_STATE = {
  {0xc21e7c13c81e894, 0x710189d783717f27, 0x7825ac132f04e050, 0x6fd140c96a52f28},
  {0x25611817aeec99d8, 0x24e1697f7e63d4b4, 0x13dabc79c3b8bba9, 0x232c7b1c778fbd08},
  {0x70bff575f3c9723c, 0x96818a1c2ae2e7ef, 0x2eec149ee0aacb0c, 0xecf6e7248a576ad}
};

State TESTNET_INIT_STATE = {
  { 0x67097c15f1a46d64, 0xc76fd61db3c20173, 0xbdf9f393b220a17, 0x10c0e352378ab1fd} ,
  { 0x57dbbe3a20c2a32, 0x486f1b93a41e04c7, 0xa21341e97da1bdc1, 0x24a095608e4bf2e9},
  { 0xd4559679d839ff92, 0x577371d495f4d71b, 0x3227c7db607b3ded, 0x2ca212648a12291e}
};

// a = 0, b = 5
static const Field GROUP_COEFF_B = {
  0xa1a55e68ffffffed, 0x74c2a54b4f4982f3, 0xfffffffffffffffd, 0x3fffffffffffffff
};

static const Field FIELD_ONE = {
  0x34786d38fffffffd, 0x992c350be41914ad, 0xffffffffffffffff, 0x3fffffffffffffff
};
static const Field FIELD_THREE = {
  0x6b0ee5d0fffffff5, 0x86f76d2b99b14bd0, 0xfffffffffffffffe, 0x3fffffffffffffff
};
static const Field FIELD_FOUR = {
  0x65a221cfffffff1, 0xfddd093b747d6762, 0xfffffffffffffffd, 0x3fffffffffffffff
};
static const Field FIELD_EIGHT = {
  0x7387134cffffffe1, 0xd973797adfadd5a8, 0xfffffffffffffffb, 0x3fffffffffffffff
};

static const Field FIELD_ZERO = { 0, 0, 0, 0 };
static const Scalar SCALAR_ZERO = { 0, 0, 0, 0 };

// (X : Y : Z) = (0 : 1 : 0)
static const Group GROUP_ZERO = {
    { 0, 0, 0, 0},
    { 0x34786d38fffffffd, 0x992c350be41914ad, 0xffffffffffffffff, 0x3fffffffffffffff },
    { 0, 0, 0, 0}
};

// g_generator = (1 : 12418654782883325593414442427049395787963493412651469444558597405572177144507)
static const Affine AFFINE_ONE = {
    {
        0x34786d38fffffffd, 0x992c350be41914ad, 0xffffffffffffffff, 0x3fffffffffffffff
    },
    {
        0x2f474795455d409d, 0xb443b9b74b8255d9, 0x270c412f2c9a5d66, 0x8e00f71ba43dd6b
    }
};

void field_add(Field c, const Field a, const Field b)
{
    fiat_pasta_fp_add(c, a, b);
}

void field_copy(Field c, const Field a)
{
    fiat_pasta_fp_copy(c, a);
}

void field_sub(Field c, const Field a, const Field b)
{
    fiat_pasta_fp_sub(c, a, b);
}

void field_mul(Field c, const Field a, const Field b)
{
    fiat_pasta_fp_mul(c, a, b);
}

void field_sq(Field c, const Field a)
{
    fiat_pasta_fp_square(c, a);
}

void field_inv(Field c, const Field a)
{
    fiat_pasta_fp_inv(c, a);
}

void field_negate(Field c, const Field a)
{
    fiat_pasta_fp_opp(c, a);
}

unsigned int field_eq(const Field a, const Field b)
{
    if (fiat_pasta_fp_equals(a, b)) {
      return 1;
    } else {
      return 0;
    }
}

void scalar_copy(Scalar b, const Scalar a)
{
    fiat_pasta_fq_copy(b, a);
}

void scalar_from_words(Scalar a, const uint64_t words[4])
{
    uint64_t tmp[4];
    memcpy(tmp, words, sizeof(tmp));
    tmp[3] &= (((uint64_t)1 << 62) - 1); // drop top two bits
    fiat_pasta_fq_to_montgomery(a, tmp);
}

void scalar_add(Scalar c, const Scalar a, const Scalar b)
{
    fiat_pasta_fq_add(c, a, b);
}

void scalar_sub(Scalar c, const Scalar a, const Scalar b)
{
    fiat_pasta_fq_sub(c, a, b);
}

void scalar_mul(Scalar c, const Scalar a, const Scalar b)
{
    fiat_pasta_fq_mul(c, a, b);
}

void scalar_sq(Scalar c, const Scalar a)
{
    fiat_pasta_fq_square(c, a);
}

void scalar_negate(Scalar c, const Scalar a)
{
    fiat_pasta_fq_opp(c, a);
}

bool scalar_eq(const Scalar a, const Scalar b)
{
    return fiat_pasta_fq_equals(a, b);
}

// zero is the only point with Z = 0 in jacobian coordinates
unsigned int is_zero(const Group *p)
{
    return field_eq(p->Z, FIELD_ZERO);
}

unsigned int affine_is_zero(const Affine *p)
{
    return (field_eq(p->x, FIELD_ZERO) && field_eq(p->y, FIELD_ZERO));
}

unsigned int group_is_on_curve(const Group *p)
{
    if (is_zero(p)) {
        return 1;
    }

    Field lhs, rhs;
    if (field_eq(p->Z, FIELD_ONE)) {
        // we can check y^2 == x^3 + ax + b
        field_sq(lhs, p->Y);                // y^2
        field_sq(rhs, p->X);                // x^2
        field_mul(rhs, rhs, p->X);          // x^3
        field_add(rhs, rhs, GROUP_COEFF_B); // x^3 + b
    }
    else {
        // we check (y/z^3)^2 == (x/z^2)^3 + b
        // => y^2 == x^3 + bz^6
        Field x3, z6;
        field_sq(x3, p->X);                 // x^2
        field_mul(x3, x3, p->X);            // x^3
        field_sq(lhs, p->Y);                // y^2
        field_sq(z6, p->Z);                 // z^2
        field_sq(z6, z6);                   // z^4
        field_mul(z6, z6, p->Z);            // z^5
        field_mul(z6, z6, p->Z);            // z^6

        field_mul(rhs, z6, GROUP_COEFF_B);  // bz^6
        field_add(rhs, x3, rhs);            // x^3 + bz^6
    }

    return field_eq(lhs, rhs);
}

void affine_to_group(Group *r, const Affine *p)
{
    if (field_eq(p->x, FIELD_ZERO) && field_eq(p->y, FIELD_ZERO)) {
        os_memcpy(r->X, FIELD_ZERO, FIELD_BYTES);
        os_memcpy(r->Y, FIELD_ONE, FIELD_BYTES);
        os_memcpy(r->Z, FIELD_ZERO, FIELD_BYTES);
        return;
    }

    os_memcpy(r->X, p->x, FIELD_BYTES);
    os_memcpy(r->Y, p->y, FIELD_BYTES);
    os_memcpy(r->Z, FIELD_ONE, FIELD_BYTES);
}

void affine_from_group(Affine *r, const Group *p)
{
    if (field_eq(p->Z, FIELD_ZERO)) {
        os_memcpy(r->x, FIELD_ZERO, FIELD_BYTES);
        os_memcpy(r->y, FIELD_ZERO, FIELD_BYTES);
        return;
    }

    Field zi, zi2, zi3;
    field_inv(zi, p->Z);        // 1/Z
    field_mul(zi2, zi, zi);     // 1/Z^2
    field_mul(zi3, zi2, zi);    // 1/Z^3
    field_mul(r->x, p->X, zi2); // X/Z^2
    field_mul(r->y, p->Y, zi3); // Y/Z^3
}

// https://www.hyperelliptic.org/EFD/g1p/auto-code/shortw/jacobian-0/doubling/dbl-2009-l.op3
// cost 2M + 5S + 6add + 3*2 + 1*3 + 1*8
void group_dbl(Group *r, const Group *p)
{
    if (is_zero(p)) {
        *r = *p;
        return;
    }

    Field a, b, c;
    field_sq(a, p->X);            // a = X1^2
    field_sq(b, p->Y);            // b = Y1^2
    field_sq(c, b);               // c = b^2

    Field d, e, f;
    field_add(r->X, p->X, b);     // t0 = X1 + b
    field_sq(r->Y, r->X);         // t1 = t0^2
    field_sub(r->Z, r->Y, a);     // t2 = t1 - a
    field_sub(r->X, r->Z, c);     // t3 = t2 - c
    field_add(d, r->X, r->X);     // d = 2 * t3
    field_mul(e, FIELD_THREE, a); // e = 3 * a
    field_sq(f, e);               // f = e^2

    field_add(r->Y, d, d);        // t4 = 2 * d
    field_sub(r->X, f, r->Y);     // X = f - t4

    field_sub(r->Y, d, r->X);     // t5 = d - X
    field_mul(f, FIELD_EIGHT, c); // t6 = 8 * c
    field_mul(r->Z, e, r->Y);     // t7 = e * t5
    field_sub(r->Y, r->Z, f);     // Y = t7 - t6

    field_mul(f, p->Y, p->Z);     // t8 = Y1 * Z1
    field_add(r->Z, f, f);        // Z = 2 * t8
}

// https://www.hyperelliptic.org/EFD/g1p/auto-code/shortw/jacobian-0/addition/add-2007-bl.op3
// cost 11M + 5S + 9add + 4*2
void group_add(Group *r, const Group *p, const Group *q)
{
    if (is_zero(p)) {
        *r = *q;
        return;
    }

    if (is_zero(q)) {
        *r = *p;
        return;
    }

    if (field_eq(p->X, q->X) && field_eq(p->Y, q->Y) && field_eq(p->Z, q->Z)) {
        return group_dbl(r, p);
    }

    Field z1z1, z2z2;
    field_sq(z1z1, p->Z);         // Z1Z1 = Z1^2
    field_sq(z2z2, q->Z);         // Z2Z2 = Z2^2

    Field u1, u2, s1, s2;
    field_mul(u1, p->X, z2z2);    // u1 = x1 * z2z2
    field_mul(u2, q->X, z1z1);    // u2 = x2 * z1z1
    field_mul(r->X, q->Z, z2z2);  // t0 = z2 * z2z2
    field_mul(s1, p->Y, r->X);    // s1 = y1 * t0
    field_mul(r->Y, p->Z, z1z1);  // t1 = z1 * z1z1
    field_mul(s2, q->Y, r->Y);    // s2 = y2 * t1

    Field h, i, j, w, v;
    field_sub(h, u2, u1);         // h = u2 - u1
    field_add(r->Z, h, h);        // t2 = 2 * h
    field_sq(i, r->Z);            // i = t2^2
    field_mul(j, h, i);           // j = h * i
    field_sub(r->X, s2, s1);      // t3 = s2 - s1
    field_add(w, r->X, r->X);     // w = 2 * t3
    field_mul(v, u1, i);          // v = u1 * i

    // X3 = w^2 - j - 2*v
    field_sq(r->X, w);            // t4 = w^2
    field_add(r->Y, v, v);        // t5 = 2 * v
    field_sub(r->Z, r->X, j);     // t6 = t4 - j
    field_sub(r->X, r->Z, r->Y);  // t6 - t5

    // Y3 = w * (v - X3) - 2*s1*j
    field_sub(r->Y, v, r->X);     // t7 = v - X3
    field_mul(r->Z, s1, j);       // t8 = s1 * j
    field_add(s1, r->Z, r->Z);    // t9 = 2 * t8
    field_mul(r->Z, w, r->Y);     // t10 = w * t7
    field_sub(r->Y, r->Z, s1);    // w * (v - X3) - 2*s1*j

    // Z3 = ((Z1 + Z2)^2 - Z1Z1 - Z2Z2) * h
    field_add(r->Z, p->Z, q->Z);  // t11 = z1 + z2
    field_sq(s1, r->Z);           // t12 = (z1 + z2)^2
    field_sub(r->Z, s1, z1z1);    // t13 = (z1 + z2)^2 - z1z1
    field_sub(j, r->Z, z2z2);     // t14 = (z1 + z2)^2 - z1z1 - z2z2
    field_mul(r->Z, j, h);        // ((z1 + z2)^2 - z1z1 - z2z2) * h
}

// https://www.hyperelliptic.org/EFD/g1p/auto-code/shortw/jacobian-0/addition/madd-2007-bl.op3
// for p = (X1, Y1, Z1), q = (X2, Y2, Z2); assumes Z2 = 1
// cost 7M + 4S + 9add + 3*2 + 1*4 ?
void group_madd(Group *r, const Group *p, const Group *q)
{
    if (is_zero(p)) {
        *r = *q;
        return;
    }
    if (is_zero(q)) {
        *r = *p;
        return;
    }

    Field z1z1, u2;
    field_sq(z1z1, p->Z);            // z1z1 = Z1^2
    field_mul(u2, q->X, z1z1);       // u2 = X2 * z1z1

    Field s2;
    field_mul(r->X, p->Z, z1z1);     // t0 = Z1 * z1z1
    field_mul(s2, q->Y, r->X);       // s2 = Y2 * t0

    Field h, hh;
    field_sub(h, u2, p->X);          // h = u2 - X1
    field_sq(hh, h);                 // hh = h^2

    Field j, w, v;
    field_mul(r->X, FIELD_FOUR, hh); // i = 4 * hh
    field_mul(j, h, r->X);           // j = h * i
    field_sub(r->Y, s2, p->Y);       // t1 = s2 - Y1
    field_add(w, r->Y, r->Y);        // w = 2 * t1
    field_mul(v, p->X, r->X);        // v = X1 * i

    // X3 = w^2 - J - 2*V
    field_sq(r->X, w);               // t2 = w^2
    field_add(r->Y, v, v);           // t3 = 2*v
    field_sub(r->Z, r->X, j);        // t4 = t2 - j
    field_sub(r->X, r->Z, r->Y);     // X3 = w^2 - j - 2*v = t4 - t3

    // Y3 = w * (V - X3) - 2*Y1*J
    field_sub(r->Y, v, r->X);        // t5 = v - X3
    field_mul(v, p->Y, j);           // t6 = Y1 * j
    field_add(r->Z, v, v);           // t7 = 2 * t6
    field_mul(s2, w, r->Y);          // t8 = w * t5
    field_sub(r->Y, s2, r->Z);       // w * (v - X3) - 2*Y1*j = t8 - t7

    // Z3 = (Z1 + H)^2 - Z1Z1 - HH
    field_add(w, p->Z, h);           // t9 = Z1 + h
    field_sq(v, w);                  // t10 = t9^2
    field_sub(w, v, z1z1);           // t11 = t10 - z1z1
    field_sub(r->Z, w, hh);          // (Z1 + h)^2 - Z1Z1 - hh = t11 - hh
}

void group_scalar_mul(Group *r, const Scalar k, const Group *p)
{
    *r = GROUP_ZERO;
    if (is_zero(p)) {
        return;
    }
    if (scalar_eq(k, SCALAR_ZERO)) {
        return;
    }

    // Group r1 = *p;
    Group tmp;

    uint64_t k_bits[4];
    fiat_pasta_fq_from_montgomery(k_bits, k);

    // Not constant time
    for (size_t i = 0; i < FIELD_SIZE_IN_BITS; ++i) {
        size_t j = FIELD_SIZE_IN_BITS - 1 - i;
        size_t limb_idx = j / 64;
        size_t in_limb_idx = (j % 64);
        bool di = (k_bits[limb_idx] >> in_limb_idx) & 1;

        group_dbl(&tmp, r);

        if (di) {
          group_add(r, &tmp, p);
        } else {
          field_copy(r->X, tmp.X);
          field_copy(r->Y, tmp.Y);
          field_copy(r->Z, tmp.Z);
        }
    }
}

void group_negate(Group *q, const Group *p)
{
    field_copy(q->X, p->X);
    field_negate(q->Y, p->Y);
    field_copy(q->Z, p->Z);
}

void affine_scalar_mul(Affine *r, const Scalar k, const Affine *p)
{
    Group pp, pr;
    affine_to_group(&pp, p);
    group_scalar_mul(&pr, k, &pp);
    affine_from_group(r, &pr);
}

bool affine_eq(const Affine *p, const Affine *q)
{
    return field_eq(p->x, q->x) && field_eq(p->y, q->y);
}

void affine_add(Affine *r, const Affine *p, const Affine *q)
{
    Group gr, gp, gq;
    affine_to_group(&gp, p);
    affine_to_group(&gq, q);
    group_add(&gr, &gp, &gq);
    affine_from_group(r, &gr);
}

void affine_negate(Affine *q, const Affine *p)
{
    Group gq, gp;
    affine_to_group(&gp, p);
    group_negate(&gq, &gp);
    affine_from_group(q, &gq);
}

bool affine_is_on_curve(const Affine *p)
{
    Group gp;
    affine_to_group(&gp, p);
    return group_is_on_curve(&gp);
}

bool is_odd(const Field y)
{
    uint64_t tmp[4];
    fiat_pasta_fp_from_montgomery(tmp, y);
    return tmp[0] & 1;
}

void roinput_print_fields(const ROInput *input) {
  for (size_t i = 0; i < LIMBS_PER_FIELD * input->fields_len; ++i) {
    printf("fs[%zu] = 0x%" PRIx64 "\n", i, input->fields[i]);
  }
}

void roinput_print_bits(const ROInput *input) {
  for (size_t i = 0; i < input->bits_len; ++i) {
    printf("bs[%zu] = %u\n", i, packed_bit_array_get(input->bits, i));
  }
}

// input for poseidon
void roinput_add_field(ROInput *input, const Field a) {
  int remaining = (int)input->fields_capacity - (int)input->fields_len;
  if (remaining < 1) {
    printf("fields at capacity\n");
    exit(1);
  }

  size_t offset = LIMBS_PER_FIELD * input->fields_len;

  fiat_pasta_fp_copy(input->fields + offset, a);

  input->fields_len += 1;
}

void roinput_add_bit(ROInput *input, bool b) {
  int remaining = (int)input->bits_capacity - (int)input->bits_len;

  if (remaining < 1) {
    printf("add_bit: bits at capacity\n");
    exit(1);
  }

  size_t offset = input->bits_len;

  packed_bit_array_set(input->bits, offset, b);
  input->bits_len += 1;
}

void roinput_add_scalar(ROInput *input, const Scalar a) {
  int remaining = (int)input->bits_capacity - (int)input->bits_len;
  const size_t len = FIELD_SIZE_IN_BITS;

  uint64_t scalar_bigint[4];
  fiat_pasta_fq_from_montgomery(scalar_bigint, a);

  if (remaining < len) {
    printf("add_scalar: bits at capacity\n");
    exit(1);
  }

  size_t offset = input->bits_len;
  for (size_t i = 0; i < len; ++i) {
    size_t limb_idx = i / 64;
    size_t in_limb_idx = (i % 64);
    bool b = (scalar_bigint[limb_idx] >> in_limb_idx) & 1;
    packed_bit_array_set(input->bits, offset + i, b);
  }

  input->bits_len += len;
}

void roinput_add_bytes(ROInput *input, const uint8_t *bytes, size_t len) {
  int remaining = (int)input->bits_capacity - (int)input->bits_len;
  if (remaining < 8 * len) {
    printf("add_bytes: bits at capacity (bytes)\n");
    exit(1);
  }

  // LSB bits
  size_t k = input->bits_len;
  for (size_t i = 0; i < len; ++i) {
    const uint8_t b = bytes[i];

    for (size_t j = 0; j < 8; ++j) {
      packed_bit_array_set(input->bits, k, (b >> j) & 1);
      ++k;
    }
  }

  input->bits_len += 8 * len;
}

void roinput_add_uint32(ROInput *input, const uint32_t x) {
  const size_t NUM_BYTES = 4;
  uint8_t le[NUM_BYTES];

  for (size_t i = 0; i < NUM_BYTES; ++i) {
    le[i] = (uint8_t) (0xff & (x >> (8 * i)));
  }

  roinput_add_bytes(input, le, NUM_BYTES);
}

void roinput_add_uint64(ROInput *input, const uint64_t x) {
  const size_t NUM_BYTES = 8;
  uint8_t le[NUM_BYTES];

  for (size_t i = 0; i < NUM_BYTES; ++i) {
    le[i] = (uint8_t) (0xff & (x >> (8 * i)));
  }

  roinput_add_bytes(input, le, NUM_BYTES);
}

void roinput_to_bytes(uint8_t *out, const ROInput *input) {
  size_t bit_idx = 0;

  Field tmp;

  // first the field elements, then the bitstrings
  for (size_t i = 0; i < input->fields_len; ++i) {
    fiat_pasta_fp_from_montgomery(tmp, input->fields + (i * LIMBS_PER_FIELD));

    for (size_t j = 0; j < FIELD_SIZE_IN_BITS; ++j) {
      size_t limb_idx = j / 64;
      size_t in_limb_idx = (j % 64);
      bool b = (tmp[limb_idx] >> in_limb_idx) & 1;

      packed_bit_array_set(
          out
          , bit_idx
          , b);
      bit_idx += 1;
    }
  }

  for (size_t i = 0; i < input->bits_len; ++i) {
    packed_bit_array_set(out, bit_idx, packed_bit_array_get(input->bits, i));
    bit_idx += 1;
  }
}

size_t roinput_to_fields(uint64_t *out, const ROInput *input) {
  size_t output_len = 0;

  // Copy over the field elements
  for (size_t i = 0; i < input->fields_len; ++i) {
    size_t offset = i * LIMBS_PER_FIELD;
    fiat_pasta_fp_copy(out + offset, input->fields + offset);
  }
  output_len += input->fields_len;

  size_t bits_consumed = 0;

  // pack in the bits
  uint64_t* next_chunk = out + input->fields_len * LIMBS_PER_FIELD;
  const size_t MAX_CHUNK_SIZE = FIELD_SIZE_IN_BITS - 1;
  while (bits_consumed < input->bits_len) {
    uint64_t chunk_non_montgomery[4] = { 0, 0, 0, 0 };

    size_t remaining = input->bits_len - bits_consumed;
    size_t chunk_size_in_bits = remaining >= MAX_CHUNK_SIZE ? MAX_CHUNK_SIZE : remaining;

    for (size_t i = 0; i < chunk_size_in_bits; ++i) {
      size_t limb_idx = i / 64;
      size_t in_limb_idx = (i % 64);
      size_t b = packed_bit_array_get(input->bits, bits_consumed + i);

      chunk_non_montgomery[limb_idx] =  chunk_non_montgomery[limb_idx] | (((uint64_t) b) << in_limb_idx);
    }
    fiat_pasta_fp_to_montgomery(next_chunk, chunk_non_montgomery);

    output_len += 1;
    bits_consumed += chunk_size_in_bits;
    next_chunk += LIMBS_PER_FIELD;
  }

  return output_len;
}

void generate_keypair(Keypair *keypair, uint32_t account)
{
    if (!keypair) {
        THROW(INVALID_PARAMETER);
    }

    uint64_t priv_non_montgomery[4] = { 0, 0, 0, 0 };
    FILE* fr = fopen("/dev/urandom", "r");
    if (!fr) perror("urandom"), exit(EXIT_FAILURE);
    fread((void*)priv_non_montgomery, sizeof(uint8_t), 32, fr);
    fclose(fr), fr = NULL;

    // Make sure the private key is in [0, p)
    //
    // Note: Mina does rejection sampling to obtain a private key in
    // [0, p), where the field modulus
    //
    //     p = 28948022309329048855892746252171976963363056481941560715954676764349967630337
    //
    // Due to constraints, this implementation take a different
    // approach and just unsets the top two bits of the 256bit bip44
    // secret, so
    //
    //     max = 28948022309329048855892746252171976963317496166410141009864396001978282409983.
    //
    // If p < max then we could still generate invalid private keys
    // (although it's highly unlikely), but
    //
    //     p - max = 45560315531419706090280762371685220354
    //
    // Thus, we cannot generate invalid private keys and instead lose an
    // insignificant amount of entropy.

    priv_non_montgomery[3] &= (((uint64_t)1 << 62) - 1); // drop top two bits
    fiat_pasta_fq_to_montgomery(keypair->priv, priv_non_montgomery);

    affine_scalar_mul(&keypair->pub, keypair->priv, &AFFINE_ONE);

    return;
}

void generate_pubkey(Affine *pub_key, const Scalar priv_key)
{
    affine_scalar_mul(pub_key, priv_key, &AFFINE_ONE);
}

bool generate_address(char *address, const size_t len, const Affine *pub_key)
{
    address[0] = '\0';

    assert (len == MINA_ADDRESS_LEN);
    if (len != MINA_ADDRESS_LEN) {
        return false;
    }

    struct bytes {
        uint8_t version;
        uint8_t payload[35];
        uint8_t checksum[4];
    } raw;

    raw.version    = 0xcb; // version for base58 check
    raw.payload[0] = 0x01; // non_zero_curve_point version
    raw.payload[1] = 0x01; // compressed_poly version

    // x-coordinate
    fiat_pasta_fp_from_montgomery((uint64_t *)&raw.payload[2], pub_key->x);

    // y-coordinate parity
    raw.payload[34] = is_odd(pub_key->y);

    uint8_t hash1[SHA256_BLOCK_SIZE];
    sha256_hash(&raw, 36, hash1, sizeof(hash1));

    uint8_t hash2[SHA256_BLOCK_SIZE];
    sha256_hash(hash1, sizeof(hash1), hash2, sizeof(hash2));

    memcpy(raw.checksum, hash2, 4);

    // Encode as address
    size_t out_len = len;
    bool result = b58enc(address, &out_len, &raw, sizeof(raw));
    address[MINA_ADDRESS_LEN - 1] = '\0';
    assert(out_len == len);
    if (out_len != len) {
        return false;
    }
    return result;
}

void message_derive(Scalar out, const Keypair *kp, const ROInput *msg, uint8_t network_id)
{
    ROInput input;
    uint64_t input_fields[4 * 5];
    uint8_t input_bits[108];
    size_t bits_capacity = 8 * 108;
    uint8_t input_bytes[268] = { 0 };

    input.fields = input_fields;
    input.bits = input_bits;

    for (size_t i = 0; i < msg->fields_len * LIMBS_PER_FIELD; ++i) {
      input.fields[i] = msg->fields[i];
    }
    memcpy(input.bits, msg->bits, sizeof(uint8_t) * ((msg->bits_len + 7) / 8));

    input.fields_len = msg->fields_len;
    input.bits_len = msg->bits_len;
    input.fields_capacity = 5;
    input.bits_capacity = bits_capacity;

    roinput_add_field(&input, kp->pub.x);
    roinput_add_field(&input, kp->pub.y);
    roinput_add_scalar(&input, kp->priv);
    roinput_add_bytes(&input, &network_id, 1);

    size_t input_size_in_bits = input.bits_len + FIELD_SIZE_IN_BITS * input.fields_len;
    size_t input_size_in_bytes = (input_size_in_bits + 7) / 8;
    assert(input_size_in_bytes <= 268);
    roinput_to_bytes(input_bytes, &input);

    uint8_t hash_out[32];
    mina_blake2b(hash_out, 32, input_bytes, input_size_in_bytes, NULL, 0);

    // take 254 bits / drop the top 2 bits
    packed_bit_array_set(hash_out, 255, 0);
    packed_bit_array_set(hash_out, 254, 0);

    uint64_t tmp[4] = { 0, 0, 0, 0 };
    for (size_t i = 0; i < 4; ++i) {
      // 8 bytes
      for (size_t j = 0; j < 8; ++j) {
        tmp[i] |= ((uint64_t) hash_out[8*i + j]) << (8 * j);
      }
    }
    fiat_pasta_fq_to_montgomery(out, tmp);
}

void message_hash(Scalar out, const Affine *pub, const Field rx, const ROInput *msg, uint8_t network_id)
{
    ROInput input;

    uint64_t input_fields[4 * 6];
    uint8_t input_bits[75];

    input.fields_capacity = 6;
    input.bits_capacity = 8 * 75;
    assert(msg->fields_len <= 6);
    assert(msg->bits_len <= input.bits_capacity);

    input.fields = input_fields;
    input.bits = input_bits;
    input.fields_len = msg->fields_len;
    input.bits_len = msg->bits_len;

    memcpy(input.fields, msg->fields, sizeof(uint64_t) * LIMBS_PER_FIELD * msg->fields_len);
    memcpy(input.bits, msg->bits, sizeof(uint8_t) * ((msg->bits_len + 7) / 8));

    roinput_add_field(&input, pub->x);
    roinput_add_field(&input, pub->y);
    roinput_add_field(&input, rx);

    // Initial sponge state
    State pos;
    poseidon_copy_state(pos, network_id == MAINNET_ID ? MAINNET_INIT_STATE : TESTNET_INIT_STATE);

    // over-estimate of field elements needed
    uint64_t packed_elements[20 * LIMBS_PER_FIELD];
    size_t packed_elements_len = roinput_to_fields(packed_elements, &input);

    poseidon_update(pos, packed_elements, packed_elements_len);
    poseidon_digest(out, pos);
}

#define FULL_BITS_LEN (FEE_BITS + TOKEN_ID_BITS + 1 + NONCE_BITS + GLOBAL_SLOT_BITS + MEMO_BITS + TAG_BITS + 1 + 1 + TOKEN_ID_BITS + AMOUNT_BITS + 1)
#define FULL_BITS_BYTES ((FULL_BITS_LEN + 7) / 8)

void compress(Compressed *compressed, const Affine *pt) {
  fiat_pasta_fp_copy(compressed->x, pt->x);

  Field y_bigint;
  fiat_pasta_fp_from_montgomery(y_bigint, pt->y);

  compressed->is_odd = y_bigint[0] & 1;
}

void decompress(Affine *pt, const Compressed *compressed) {
  fiat_pasta_fp_copy(pt->x, compressed->x);

  Field x2;
  fiat_pasta_fp_square(x2, pt->x);
  Field x3;
  fiat_pasta_fp_mul(x3, x2, pt->x); // x^3
  Field y2;
  fiat_pasta_fp_add(y2, x3, GROUP_COEFF_B);

  Field y_pre;
  fiat_pasta_fp_sqrt(y_pre, y2);
  Field y_pre_bigint;
  fiat_pasta_fp_from_montgomery(y_pre_bigint, y_pre);

  const bool y_pre_odd = (y_pre_bigint[0] & 1);
  if (y_pre_odd == compressed->is_odd) {
    fiat_pasta_fp_copy(pt->y, y_pre);
  } else {
    fiat_pasta_fp_opp(pt->y, y_pre);
  }
}

void read_public_key_compressed(Compressed *out, char *pubkeyBase58) {
  size_t pubkeyBytesLen = 40;
  unsigned char pubkeyBytes[40];
  b58tobin(pubkeyBytes, &pubkeyBytesLen, pubkeyBase58, 0);

  uint64_t x_coord_non_montgomery[4] = { 0, 0, 0, 0 };

  size_t offset = 3;
  for (size_t i = 0; i < 4; ++i) {
    const size_t BYTES_PER_LIMB = 8;
    // 8 bytes per limb
    for (size_t j = 0; j < BYTES_PER_LIMB; ++j) {
      size_t k = offset + BYTES_PER_LIMB * i + j;
      x_coord_non_montgomery[i] |= ( ((uint64_t) pubkeyBytes[k]) << (8 * j));
    }
  }

  fiat_pasta_fp_to_montgomery(out->x, x_coord_non_montgomery);
  out->is_odd = (bool) pubkeyBytes[offset + 32];
}

void prepare_memo(uint8_t *out, char *s) {
  size_t len = strlen(s);
  out[0] = 1;
  out[1] = len; // length
  for (size_t i = 0; i < len; ++i) {
    out[2 + i] = s[i];
  }
  for (size_t i = 2 + len; i < MEMO_BYTES; ++i) {
    out[i] = 0;
  }
}

bool verify(Signature *sig, const Compressed *pub_compressed, const Transaction *transaction, uint8_t network_id)
{
    // Convert transaction to ROInput
    uint64_t input_fields[4 * 3];
    uint8_t input_bits[FULL_BITS_BYTES];
    ROInput input;
    input.fields_capacity = 3;
    input.bits_capacity = 8 * FULL_BITS_BYTES;
    input.fields = input_fields;
    input.bits = input_bits;
    input.fields_len = 0;
    input.bits_len = 0;

    roinput_add_field(&input, transaction->fee_payer_pk.x);
    roinput_add_field(&input, transaction->source_pk.x);
    roinput_add_field(&input, transaction->receiver_pk.x);

    roinput_add_uint64(&input, transaction->fee);
    roinput_add_uint64(&input, transaction->fee_token);
    roinput_add_bit(&input, transaction->fee_payer_pk.is_odd);
    roinput_add_uint32(&input, transaction->nonce);
    roinput_add_uint32(&input, transaction->valid_until);
    roinput_add_bytes(&input, transaction->memo, MEMO_BYTES);
    for (size_t i = 0; i < 3; ++i) {
      roinput_add_bit(&input, transaction->tag[i]);
    }
    roinput_add_bit(&input, transaction->source_pk.is_odd);
    roinput_add_bit(&input, transaction->receiver_pk.is_odd);
    roinput_add_uint64(&input, transaction->token_id);
    roinput_add_uint64(&input, transaction->amount);
    roinput_add_bit(&input, transaction->token_locked);

    Affine pub;
    decompress(&pub, pub_compressed);

    Scalar e;
    message_hash(e, &pub, sig->rx, &input, network_id);

    Group g;
    affine_to_group(&g, &AFFINE_ONE);

    Group sg;
    group_scalar_mul(&sg, sig->s, &g);

    Group pub_proj;
    affine_to_group(&pub_proj, &pub);
    Group epub;
    group_scalar_mul(&epub, e, &pub_proj);

    Group neg_epub;
    fiat_pasta_fp_copy(neg_epub.X, epub.X);
    fiat_pasta_fp_opp(neg_epub.Y, epub.Y);
    fiat_pasta_fp_copy(neg_epub.Z, epub.Z);

    Group r;
    group_add(&r, &sg, &neg_epub);

    Affine raff;
    affine_from_group(&raff, &r);

    Field ry_bigint;
    fiat_pasta_fp_from_montgomery(ry_bigint, raff.y);

    const bool ry_even = (ry_bigint[0] & 1) == 0;

    return (ry_even && fiat_pasta_fp_equals(raff.x, sig->rx));
}

void sign(Signature *sig, const Keypair *kp, const Transaction *transaction, uint8_t network_id)
{
    // Convert transaction to ROInput
    uint64_t input_fields[4 * 3];
    uint8_t input_bits[FULL_BITS_BYTES];
    ROInput input;
    input.fields_capacity = 3;
    input.bits_capacity = 8 * FULL_BITS_BYTES;
    input.fields = input_fields;
    input.bits = input_bits;
    input.fields_len = 0;
    input.bits_len = 0;

    roinput_add_field(&input, transaction->fee_payer_pk.x);
    roinput_add_field(&input, transaction->source_pk.x);
    roinput_add_field(&input, transaction->receiver_pk.x);

    roinput_add_uint64(&input, transaction->fee);
    roinput_add_uint64(&input, transaction->fee_token);
    roinput_add_bit(&input, transaction->fee_payer_pk.is_odd);
    roinput_add_uint32(&input, transaction->nonce);
    roinput_add_uint32(&input, transaction->valid_until);
    roinput_add_bytes(&input, transaction->memo, MEMO_BYTES);
    for (size_t i = 0; i < 3; ++i) {
      roinput_add_bit(&input, transaction->tag[i]);
    }
    roinput_add_bit(&input, transaction->source_pk.is_odd);
    roinput_add_bit(&input, transaction->receiver_pk.is_odd);
    roinput_add_uint64(&input, transaction->token_id);
    roinput_add_uint64(&input, transaction->amount);
    roinput_add_bit(&input, transaction->token_locked);

    Scalar k;
    message_derive(k, kp, &input, network_id);

    uint64_t k_nonzero;
    fiat_pasta_fq_nonzero(&k_nonzero, k);
    if (! k_nonzero) {
      exit(1);
    }

    // r = k*g
    Affine r;
    affine_scalar_mul(&r, k, &AFFINE_ONE);

    field_copy(sig->rx, r.x);

    if (is_odd(r.y)) {
        // negate (k = -k)
        Scalar tmp;
        fiat_pasta_fq_copy(tmp, k);
        scalar_negate(k, tmp);
    }

    Scalar e;
    message_hash(e, &kp->pub, r.x, &input, network_id);

    // s = k + e*sk
    Scalar e_priv;
    scalar_mul(e_priv, e, kp->priv);
    scalar_add(sig->s, k, e_priv);
}
