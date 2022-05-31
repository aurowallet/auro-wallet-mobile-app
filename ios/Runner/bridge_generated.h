#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct wire_uint_8_list {
  uint8_t *ptr;
  int32_t len;
} wire_uint_8_list;

typedef struct WireSyncReturnStruct {
  uint8_t *ptr;
  int32_t len;
  bool success;
} WireSyncReturnStruct;

typedef int64_t DartPort;

typedef bool (*DartPostCObjectFnType)(DartPort port_id, void *message);

void wire_getAddressFromSecretHex(int64_t port_, struct wire_uint_8_list *secret_hex);

void wire_signPayment(int64_t port_,
                      struct wire_uint_8_list *secret_hex,
                      struct wire_uint_8_list *to,
                      uint64_t amount,
                      uint64_t fee,
                      uint32_t nonce,
                      uint32_t valid_until,
                      struct wire_uint_8_list *memo,
                      uint8_t network_id);

void wire_signDelegation(int64_t port_,
                         struct wire_uint_8_list *secret_hex,
                         struct wire_uint_8_list *to,
                         uint64_t fee,
                         uint32_t nonce,
                         uint32_t valid_until,
                         struct wire_uint_8_list *memo,
                         uint8_t network_id);

struct wire_uint_8_list *new_uint_8_list(int32_t len);

void free_WireSyncReturnStruct(struct WireSyncReturnStruct val);

void store_dart_post_cobject(DartPostCObjectFnType ptr);

static int64_t dummy_method_to_enforce_bundling(void) {
    int64_t dummy_var = 0;
    dummy_var ^= ((int64_t) (void*) wire_getAddressFromSecretHex);
    dummy_var ^= ((int64_t) (void*) wire_signPayment);
    dummy_var ^= ((int64_t) (void*) wire_signDelegation);
    dummy_var ^= ((int64_t) (void*) new_uint_8_list);
    dummy_var ^= ((int64_t) (void*) free_WireSyncReturnStruct);
    dummy_var ^= ((int64_t) (void*) store_dart_post_cobject);
    return dummy_var;
}