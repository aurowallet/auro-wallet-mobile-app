#pragma once

#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

#define INVALID_PARAMETER 1
#define os_memcmp memcmp
#define os_memcpy memcpy

#define BIP32_PATH_LEN 5
#define BIP32_HARDENED_OFFSET 0x80000000

#define FIELD_BYTES   32

#define LIMBS_PER_FIELD 4
#define LIMBS_PER_SCALAR 4

#define FIELD_SIZE_IN_BITS 255

#define MINA_ADDRESS_LEN 56 // includes null-byte

#define COIN 1000000000ULL

typedef uint64_t Field[LIMBS_PER_FIELD];
typedef uint64_t Scalar[LIMBS_PER_FIELD];

typedef uint64_t Currency;
#define FEE_BITS 64
#define AMOUNT_BITS 64
typedef uint32_t GlobalSlot;
#define GLOBAL_SLOT_BITS 32
typedef uint32_t Nonce;
#define NONCE_BITS 32
typedef uint64_t TokenId;
#define TOKEN_ID_BITS 64
#define MEMO_BYTES 34
typedef uint8_t Memo[MEMO_BYTES];
#define MEMO_BITS (MEMO_BYTES * 8)
typedef bool Tag[3];
#define TAG_BITS 3

#define MAINNET_ID 1
#define TESTNET_ID 0

typedef uint8_t* PackedBits;

typedef struct group_t {
    Field X;
    Field Y;
    Field Z;
} Group;

typedef struct affine_t {
    Field x;
    Field y;
} Affine;

typedef struct compressed_t {
    Field x;
    bool is_odd;
} Compressed;

typedef struct transaction_t {
  // common
  Currency fee;
  TokenId fee_token;
  Compressed fee_payer_pk;
  Nonce nonce;
  GlobalSlot valid_until;
  Memo memo;
  // body
  Tag tag;
  Compressed source_pk;
  Compressed receiver_pk;
  TokenId token_id;
  Currency amount;
  bool token_locked;
} Transaction;

typedef struct signature_t {
    Field rx;
    Scalar s;
} Signature;

typedef struct keypair_t {
    Affine pub;
    Scalar priv;
} Keypair;

typedef struct roinput_t {
  uint64_t* fields;
  PackedBits bits;
  size_t fields_len;
  size_t fields_capacity;
  size_t bits_len;
  size_t bits_capacity;
} ROInput;

void roinput_add_field(ROInput *input, const Field a);
void roinput_add_scalar(ROInput *input, const Scalar a);
void roinput_add_bit(ROInput *input, bool b);
void roinput_add_bytes(ROInput *input, const uint8_t *bytes, size_t len);
void roinput_add_uint32(ROInput *input, const uint32_t x);
void roinput_add_uint64(ROInput *input, const uint64_t x);

void scalar_copy(Scalar b, const Scalar a);
void scalar_from_words(Scalar a, const uint64_t words[4]);
bool scalar_eq(const Scalar a, const Scalar b);
void scalar_add(Scalar c, const Scalar a, const Scalar b);
void scalar_mul(Scalar c, const Scalar a, const Scalar b);
void scalar_negate(Scalar b, const Scalar a);

void field_add(Field c, const Field a, const Field b);
void field_copy(Field c, const Field a);
void field_mul(Field c, const Field a, const Field b);
void field_sq(Field c, const Field a);

bool affine_eq(const Affine *p, const Affine *q);
void affine_add(Affine *r, const Affine *p, const Affine *q);
void affine_negate(Affine *q, const Affine *p);
void affine_scalar_mul(Affine *r, const Scalar k, const Affine *p);
bool affine_is_on_curve(const Affine *p);

void generate_keypair(Keypair *keypair, uint32_t account);
void generate_pubkey(Affine *pub_key, const Scalar priv_key);
bool generate_address(char *address, size_t len, const Affine *pub_key);

void sign(Signature *sig, const Keypair *kp, const Transaction *transaction, uint8_t network_id);
bool verify(Signature *sig, const Compressed *pub, const Transaction *transaction, uint8_t network_id);

void compress(Compressed *compressed, const Affine *pt);

void read_public_key_compressed(Compressed *out, char *pubkeyBase58);
void prepare_memo(uint8_t *out, char *s);
