/*******************************************************************************
 * Poseidon is a hash function explained in https://eprint.iacr.org/2019/458
 * It requires the following parameters, with p a prime defining a prime field.
 * alpha = smallest prime st gcd(p, alpha) = 1
 * m = number of field elements in the state of the hash function.
 * N = number of rounds the hash function performs on each digest.
 * For m = r + c, the sponge absorbs (via field addition) and squeezes r field
 * elements per iteration, and offers log2(c) bits of security.
 * For our p (definied in crypto.c), we have alpha = 11, m = 3, r = 1, s = 2.
 *
 * Poseidon splits the full rounds into two, putting half before the parital
 * rounds are run, and the other half after. We have :
 * full rounds = 8
 * partial = 30,
 * meaning that the rounds total 38.
 * poseidon.c handles splitting the partial rounds in half and execution order.
 ********************************************************************************/

#pragma once

#include "crypto.h"

#define ROUNDS 64
#define FULL_ROUNDS 63
#define SPONGE_SIZE 3

typedef Field State[SPONGE_SIZE];

void poseidon_update(State s, const uint64_t *input, size_t len);
void poseidon_digest(Scalar out, const State s);
void poseidon_copy_state(State out, const State s);
