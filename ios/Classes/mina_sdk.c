#include <stdint.h>
#include <stdio.h>
#include <assert.h>
#include <sys/resource.h>
#include <inttypes.h>

#include "signer/pasta_fp.h"
#include "signer/pasta_fq.h"
#include "signer/crypto.h"
#include "signer/poseidon.h"
#include "signer/base10.h"
#include "signer/utils.h"
#include "signer/sha256.h"
#include "signer/curve_checks.h"

#define ARRAY_LEN(x) (sizeof(x)/sizeof(x[0]))

#define DEFAULT_TOKEN_ID 1
static bool _verbose;

__attribute__((visibility("default"))) __attribute__((used))
void privkey_to_hex(char *hex, const size_t len, const Scalar priv_key) {
  uint64_t priv_words[4];
  hex[0] = '\0';

  assert(len > 2*sizeof(priv_words));
  if (len < 2*sizeof(priv_words)) {
    return;
  }

  uint8_t *p = (uint8_t *)priv_words;
  fiat_pasta_fq_from_montgomery(priv_words, priv_key);
  for (size_t i = sizeof(priv_words); i > 0; i--) {
    sprintf(&hex[2*(sizeof(priv_words) - i)], "%02x", p[i - 1]);
  }
  hex[len] = '\0';
}

__attribute__((visibility("default"))) __attribute__((used))
bool privkey_from_hex(Scalar priv_key, const char *priv_hex) {
  size_t priv_hex_len = strnlen(priv_hex, 64);
  if (priv_hex_len != 64) {
    return false;
  }
  uint8_t priv_bytes[32];
  for (size_t i = sizeof(priv_bytes); i > 0; i--) {
    sscanf(&priv_hex[2*(i - 1)], "%02hhx", &priv_bytes[sizeof(priv_bytes) - i]);
  }

  if (priv_bytes[3] & 0xc000000000000000) {
      return false;
  }

  fiat_pasta_fq_to_montgomery(priv_key, (uint64_t *)priv_bytes);

  char priv_key_hex[65];
  privkey_to_hex(priv_key_hex, sizeof(priv_key_hex), priv_key);

  // sanity check
  int result = memcmp(priv_key_hex, priv_hex, sizeof(priv_key_hex)) == 0;
  assert(result);
  return result;
}

__attribute__((visibility("default"))) __attribute__((used))
void privhex_to_address(char *address, char *priv_hex) {
  Scalar priv_key;
  if (!privkey_from_hex(priv_key, priv_hex)) {
    return;
  }
  Keypair kp;
  scalar_copy(kp.priv, priv_key);
  generate_pubkey(&kp.pub, priv_key);

  if (!generate_address(address, MINA_ADDRESS_LEN, &kp.pub)) {
    return;
  }

  if (_verbose) {
    printf("%s => %s\n", priv_hex, address);
  }
  return;
}

//void sig_to_hex(char *hex, const size_t len, const Signature sig) {
//  hex[0] = '\0';
//
//  assert(len == 2*sizeof(Signature) + 1);
//  if (len < 2*sizeof(Signature) + 1) {
//    return;
//  }
//
//  uint64_t words[4];
//  fiat_pasta_fp_from_montgomery(words, sig.rx);
//  for (size_t i = 4; i > 0; i--) {
//    sprintf(&hex[16*(4 - i)], "%016lx", htole64(words[i - 1]));
//  }
//  fiat_pasta_fq_from_montgomery(words, sig.s);
//  for (size_t i = 4; i > 0; i--) {
//    sprintf(&hex[64 + 16*(4 - i)], "%016lx", htole64(words[i - 1]));
//  }
//}

__attribute__((visibility("default"))) __attribute__((used))
bool sign_transaction(char *out_field, char *out_scalar,
                      const char *sender_priv_hex,
                      const char *receiver_address,
                      Currency amount,
                      Currency fee,
                      Nonce nonce,
                      GlobalSlot valid_until,
                      const char *memo,
                      bool delegation,
                      uint8_t network_id) {
  Transaction txn;

  prepare_memo(txn.memo, memo);

  Scalar priv_key;
  if (!privkey_from_hex(priv_key, sender_priv_hex)) {
    return false;
  }

  Keypair kp;
  scalar_copy(kp.priv, priv_key);
  generate_pubkey(&kp.pub, priv_key);

  char source_str[MINA_ADDRESS_LEN];
  if (!generate_address(source_str, sizeof(source_str), &kp.pub)) {
    return false;
  }

  char *fee_payer_str = source_str;

  txn.fee = fee;
  txn.fee_token = DEFAULT_TOKEN_ID;
  read_public_key_compressed(&txn.fee_payer_pk, fee_payer_str);
  txn.nonce = nonce;
  txn.valid_until = valid_until;

  if (delegation) {
    txn.tag[0] = 0;
    txn.tag[1] = 0;
    txn.tag[2] = 1;
  }
  else {
    txn.tag[0] = 0;
    txn.tag[1] = 0;
    txn.tag[2] = 0;
  }

  read_public_key_compressed(&txn.source_pk, source_str);
  read_public_key_compressed(&txn.receiver_pk, receiver_address);
  txn.token_id = DEFAULT_TOKEN_ID;
  txn.amount = amount;
  txn.token_locked = false;

  Compressed pub_compressed;
  compress(&pub_compressed, &kp.pub);

  Signature sig;
  sign(&sig, &kp, &txn, network_id);

  if (!verify(&sig, &pub_compressed, &txn, network_id)) {
    return false;
  }
  uint64_t tmp[4];
  memset(tmp, 0, sizeof(tmp));
  fiat_pasta_fp_from_montgomery(tmp, sig.rx);
  bigint_to_string(out_field, tmp);
  memset(tmp, 0, sizeof(tmp));
  fiat_pasta_fq_from_montgomery(tmp, sig.s);
  bigint_to_string(out_scalar, tmp);

  return true;
}

