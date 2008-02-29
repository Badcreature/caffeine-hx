/*
 * Copyright (c) 2008, The Caffeine-hx project contributors
 * Original author : Russell Weir
 * Contributors:
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE CAFFEINE-HX PROJECT CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE CAFFEINE-HX PROJECT CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <cfhxdef.h>
#include <math.h>
#include <assert.h>
#include <openssl/bn.h>
#include <openssl/crypto.h>
#include <neko/neko.h>
#include "bn_neko.h"

DEFINE_KIND(k_biginteger);
#define val_biginteger(o) (BIGNUM *)val_data(o)
//#DEFINE_ENTRY_POINT(bi_init)
#define NEW_CTX(a) BN_CTX* a = BN_CTX_new()
#define FREE_CTX(a) BN_CTX_end(a); BN_CTX_free(a)

//static void bi_init() {
//The PRNG must be seeded prior to calling BN_rand() or BN_rand_range().
//}

/**
	Openssl callback function
**/
static void status_ignore(int i,int j,void *p) {}

/**
	Allocate neko GC object
**/
static value bi_allocate(BIGNUM *bi) {
	value v = alloc_abstract(k_biginteger, bi);
	val_gc(v, destroy_biginteger);
	return v;
}

/**
	Create a new, uninitialized BI
**/
static value bi_new() {
	BIGNUM *bi = BN_new();
	return bi_allocate(bi);
}
DEFINE_PRIM(bi_new,0);

/**
	Neko garbage collection for bigInteger struct.
	@param bi bigInteger structure
**/
static void destroy_biginteger( value bi ) {
	if(!val_is_kind(bi, k_biginteger))
		return;
	//BN_FREE(val_biginteger(bi));
	BN_clear_free(val_biginteger(bi));
}
DEFINE_PRIM(destroy_biginteger,1);

/**
	New BI with value 0
**/
static value bi_ZERO() {
	BIGNUM *bi = BN_new();
// 	#define BN_zero_ex(a) \
// 	do { \
// 		BIGNUM *_tmp_bn = (a); \
// 		_tmp_bn->top = 0; \
// 		_tmp_bn->neg = 0; \
// 	} while(0)
	BN_zero(bi);
	return bi_allocate(bi);
}
DEFINE_PRIM(bi_ZERO,0);

/**
	New BI with value 1
**/
static value bi_ONE() {
	BIGNUM *bi = BN_new();
	//#define BN_one(a)	(BN_set_word((a),1))
	BN_one(bi);
	return bi_allocate(bi);
}
DEFINE_PRIM(bi_ONE,0);

/**
	Copies FROM to TO. Note reverse polish notation on args.
**/
static value bi_copy(value TO, value FROM) {
	val_check_kind(TO, k_biginteger);
	val_check_kind(FROM, k_biginteger);
	BN_copy(val_biginteger(TO), val_biginteger(FROM));
	return val_true;
}
DEFINE_PRIM(bi_copy,2);

/**
	Generate a prime of the specified number of bits
	WARNING is deprecated
*/
static value bi_generate_prime(value nbits) {
	value BI = bi_new();
	val_check(nbits, int);
	if(nbits < 0)
		THROW("nbits < 0");
	BN_generate_prime(val_biginteger(BI), val_int(nbits), 1, NULL,NULL,status_ignore,NULL);
	return BI;
}
DEFINE_PRIM(bi_generate_prime,1);

//////////////////////////////////////////////////////////////
//                MATH methods                              //
//////////////////////////////////////////////////////////////
/** abs(A) **/
static value bi_abs(value A) {
	val_check_kind(A, k_biginteger);
	BIGNUM *a = val_biginteger(A);
	value T = bi_new();
	BIGNUM *t = val_biginteger(T);
	BN_copy(t, a);
	t->neg = 0;
	return T;
}
DEFINE_PRIM(bi_abs,1);

/** A + B = R **/
static value bi_add_to(value A, value B, value R) {
	val_check_kind(A, k_biginteger);
	val_check_kind(B, k_biginteger);
	val_check_kind(R, k_biginteger);
// 	if(R == val_null)
// 		value R = bi_new();
	BN_add(val_biginteger(R), val_biginteger(A), val_biginteger(B));
	return R;
}
DEFINE_PRIM(bi_add_to,3);

/** A - B = R **/
static value bi_sub_to(value A, value B, value R) {
	val_check_kind(A, k_biginteger);
	val_check_kind(B, k_biginteger);
	val_check_kind(R, k_biginteger);
// 	if(R == val_null)
// 		value R = bi_new();
	BN_sub(val_biginteger(R), val_biginteger(A), val_biginteger(B));
	return R;
}
DEFINE_PRIM(bi_sub_to,3);

/** A * B = R **/
static value bi_mul_to(value A, value B, value R) {
	val_check_kind(A, k_biginteger);
	val_check_kind(B, k_biginteger);
	val_check_kind(R, k_biginteger);
// 	if(R == val_null)
// 		value R = bi_new();
	NEW_CTX(ctx);
	BN_mul(val_biginteger(R), val_biginteger(A), val_biginteger(B), ctx);
	FREE_CTX(ctx);
	return R;
}
DEFINE_PRIM(bi_mul_to,3);

/** sqr(A) = R **/
static value bi_sqr_to(value A, value R) {
	val_check_kind(A, k_biginteger);
	val_check_kind(R, k_biginteger);
// 	if(R == val_null)
// 		value R = bi_new();
	NEW_CTX(ctx);
	if(!BN_sqr(val_biginteger(R), val_biginteger(A), ctx)) {
		FREE_CTX(ctx);
		THROW("bi_sqr_to: error");
	}
	FREE_CTX(ctx);
	return R;
}
DEFINE_PRIM(bi_sqr_to,2);

/** A / D = [dv, remainder] **/
static value bi_div(value A, value B) {
	val_check_kind(A, k_biginteger);
	val_check_kind(B, k_biginteger);
	value DV = bi_new();
	value REM = bi_new();
	bi_div_rem_to(A, B, DV, REM);
	value v = alloc_array(2);
	val_array_ptr(v)[0] = DV;
	val_array_ptr(v)[1] = REM;
	return v;
}
DEFINE_PRIM(bi_div,2);

/** A / D = [dv, remainder] **/
static value bi_div_rem_to(value A, value B, value DV, value REM) {
	val_check_kind(A, k_biginteger);
	val_check_kind(B, k_biginteger);
	val_check_kind(DV, k_biginteger);
	val_check_kind(REM, k_biginteger);
	NEW_CTX(ctx);
	BN_div(val_biginteger(DV), val_biginteger(REM), val_biginteger(A), val_biginteger(B), ctx);
	FREE_CTX(ctx);
	value v = alloc_array(2);
	val_array_ptr(v)[0] = DV;
	val_array_ptr(v)[1] = REM;
	return v;
}
DEFINE_PRIM(bi_div_rem_to,4);

/** A % B = R **/
static value bi_mod(value A, value B) {
	val_check_kind(A, k_biginteger);
	val_check_kind(B, k_biginteger);
	value R = bi_new();
	NEW_CTX(ctx);
	BN_mod(val_biginteger(R), val_biginteger(A), val_biginteger(B), ctx);
	FREE_CTX(ctx);
	return R;
}
DEFINE_PRIM(bi_mod,2);

/** A ^ P % M = R **/
static value bi_mod_exp(value A, value P, value M) {
	val_check_kind(A, k_biginteger);
	val_check_kind(P, k_biginteger);
	val_check_kind(M, k_biginteger);
	NEW_CTX(ctx);
	value R = bi_new();
	BN_mod_exp(val_biginteger(R), val_biginteger(A), val_biginteger(P), val_biginteger(M), ctx);
	FREE_CTX(ctx);
	return R;
}
DEFINE_PRIM(bi_mod_exp,3);

/** 1/A % M **/
static value bi_mod_inverse(value A, value M) {
	val_check_kind(A, k_biginteger);
	val_check_kind(M, k_biginteger);
	NEW_CTX(ctx);
	value R = bi_new();
	BN_mod_inverse(val_biginteger(R), val_biginteger(A), val_biginteger(M), ctx);
	FREE_CTX(ctx);
	return R;
}
DEFINE_PRIM(bi_mod_inverse,2);

/** BN_nnmod() ?
static value bi_(value A, value B) {
	val_check_kind(A, k_biginteger);
	val_check_kind(B, k_biginteger);
	value R = bi_new();
	BN_(val_biginteger(R), val_biginteger(A), val_biginteger(B));
	return R;
}

BN_mod_add()

BN_mod_sub()

BN_mod_mul()

BN_mod_sqr()


**/

/** A^B = R **/
static value bi_pow(value A, value B) {
	val_check_kind(A, k_biginteger);
	val_check_kind(B, k_biginteger);
	NEW_CTX(ctx);
	value R = bi_new();
	BN_exp(val_biginteger(R), val_biginteger(A), val_biginteger(B), ctx);
	FREE_CTX(ctx);
	return R;
}
DEFINE_PRIM(bi_pow,2);


/** greatest common divisor **/
static value bi_gcd(value A, value B) {
	val_check_kind(A, k_biginteger);
	val_check_kind(B, k_biginteger);
	NEW_CTX(ctx);
	value R = bi_new();
	BN_gcd(val_biginteger(R), val_biginteger(A), val_biginteger(B), ctx);
	FREE_CTX(ctx);
	return R;
}
DEFINE_PRIM(bi_gcd,2);


/*
static value bi_(value A, value B) {
	val_check_kind(A, k_biginteger);
	val_check_kind(B, k_biginteger);
	NEW_CTX(ctx);
	value R = bi_new();
	BN_(val_biginteger(R), val_biginteger(A), val_biginteger(B), ctx);
	FREE_CTX(ctx);
	return R;
}
*/

/** Returns 1 for positive numbers, 0 for 0, -1 for negative numbers **/
static value bi_signum(value A) {
	val_check_kind(A, k_biginteger);
	BIGNUM *a = val_biginteger(A);
	int n;
	n = (a->neg == 0)?1:-1;
	if(BN_is_zero(a))
		n = 0;
	return alloc_int(n);
}
DEFINE_PRIM(bi_signum,1);


//////////////////////////////////////////////////////////////
//              Comparison methods                          //
//////////////////////////////////////////////////////////////
/** compare A B **/
static value bi_cmp(value A, value B) {
	val_check_kind(A, k_biginteger);
	val_check_kind(B, k_biginteger);
	return alloc_int(BN_cmp(val_biginteger(A), val_biginteger(B)));
}
DEFINE_PRIM(bi_cmp,2);

/** compare abs(a) abs(b) **/
static value bi_ucmp(value A, value B) {
	val_check_kind(A, k_biginteger);
	val_check_kind(B, k_biginteger);
	return alloc_int(BN_ucmp(val_biginteger(A), val_biginteger(B)));
}
DEFINE_PRIM(bi_ucmp,2);

/** is A == zero? **/
static value bi_is_zero(value A) {
	val_check_kind(A, k_biginteger);
	return alloc_int(BN_is_zero(val_biginteger(A)));
}
DEFINE_PRIM(bi_is_zero,1);

/** is A == 1? **/
static value bi_is_one(value A) {
	val_check_kind(A, k_biginteger);
	return alloc_int(BN_is_one(val_biginteger(A)));
}
DEFINE_PRIM(bi_is_one,1);

/** is A odd **/
static value bi_is_odd(value A) {
	val_check_kind(A, k_biginteger);
	return alloc_int(BN_is_odd(val_biginteger(A)));
}
DEFINE_PRIM(bi_is_odd,1);

//////////////////////////////////////////////////////////////
//                RAND methods                              //
//////////////////////////////////////////////////////////////

/**
Seed the RNG with a string of bytes. Should be longer than
the number of bits of keys etc. that need to be generated.
MUST be called before using the rand functions.
**/
static value bi_rand_seed(value data) {
	val_check(data, string);
	RAND_seed(val_string(data), val_strlen(data));
}
DEFINE_PRIM(bi_rand_seed,1);

/** Generate strong RNG
If top is -1, the most significant bit of the random number can be zero. If top is 0, it is set to 1, and if top is 1, the two most significant bits of the number will be set to 1, so that the product of two such random numbers will always have 2*bits length. If bottom is true, the number will be odd.
 **/
static value bi_rand(value bits, value top, value bottom) {
	int nb;
	int t;
	int b;
	val_check(bits, int);
	val_check(top, int);
	val_check(bottom, int);
	nb = val_int(bits);
	if(nb < 0)
		return val_null;
	t = val_int(top);
	t = (t==0) ? 0: (t<0) ? -1 : 1;
	b = val_int(bottom);
	b = (b==0) ? 0: 1;
	value R = bi_new();
	if(!BN_rand(val_biginteger(R), nb, t, b))
		THROW("error");
	return R;
}
DEFINE_PRIM(bi_rand,3);

/** Generate pseudo RNG
If top is -1, the most significant bit of the random number can be zero. If top is 0, it is set to 1, and if top is 1, the two most significant bits of the number will be set to 1, so that the product of two such random numbers will always have 2*bits length. If bottom is true, the number will be odd.
 **/
static value bi_pseudo_rand(value bits, value top, value bottom) {
	int nb;
	int t;
	int b;
	val_check(bits, int);
	val_check(top, int);
	val_check(bottom, int);
	nb = val_int(bits);
	if(nb < 0)
		return val_null;
	t = val_int(top);
	t = (t==0) ? 0: (t<0) ? -1 : 1;
	b = val_int(bottom);
	b = (b==0) ? 0: 1;
	value R = bi_new();
	if(!BN_pseudo_rand(val_biginteger(R), nb, t, b))
		THROW("error");
	return R;
}
DEFINE_PRIM(bi_pseudo_rand,3);

//////////////////////////////////////////////////////////////
//               Conversion methods                         //
//////////////////////////////////////////////////////////////
/**
	Truncates leading 0 chars from BN_bn2dec()
**/
static char *bi_dec_string(char *v) {
	int i;
	if(v == NULL)
		return "0";
	for(i = 0; i < strlen(v) && v[i] == '0'; i++);
	if(i >= strlen(v))
		return "0";
	return &v[i];
}

/** A -> hex string **/
static value bi_to_hex(value A) {
	val_check_kind(A, k_biginteger);
	char *h = BN_bn2hex(val_biginteger(A));
	char *h1 = bi_dec_string(h);
	value v = copy_string(h1, strlen(h1));
	OPENSSL_free(h);
	return v;
}
DEFINE_PRIM(bi_to_hex,1);

/** hex string -> R BigInteger **/
static value bi_from_hex(value s) {
	val_check(s, string);
	BIGNUM *bi = NULL;
	BN_hex2bn(&bi, (const char *)val_string(s));
	return bi_allocate(bi);
}
DEFINE_PRIM(bi_from_hex,1);

/** A -> decimal string **/
static value bi_to_decimal(value A) {
	val_check_kind(A, k_biginteger);
	char *h = BN_bn2dec(val_biginteger(A));
	char *h1 = bi_dec_string(h);
	value v = copy_string(h1, strlen(h1));
	OPENSSL_free(h);
	return v;
}
DEFINE_PRIM(bi_to_decimal,1);

/** hex string -> R BigInteger **/
static value bi_from_decimal(value s) {
	val_check(s, string);
	BIGNUM *bi = NULL;
	BN_dec2bn(&bi, (const char *)val_string(s));
	return bi_allocate(bi);
}
DEFINE_PRIM(bi_from_decimal,1);

/** A -> BigEndian base 256 string. First character will be 0 (+) or 0x80 (-) **/
static value bi_to_bin(value A) {
	val_check_kind(A, k_biginteger);
	BIGNUM *a = val_biginteger(A);
	value buf = alloc_empty_string(BN_num_bytes(a) + 1);
	if(a->neg != 0)
		val_string(buf)[0] = 0x80;
	else
		val_string(buf)[0] = 0x00;
	BN_bn2bin(a, val_string(buf)+1);
	return buf;
}
DEFINE_PRIM(bi_to_bin,1);

/** BigEndian base 256 string -> R BigInteger where first char is 0 or 0x80 (-) **/
static value bi_from_bin(value S) {
	val_check(S, string);
	int neg = 0;
	const unsigned char *s = (const unsigned char *)val_string(S);

	BIGNUM *bi = BN_bin2bn(s+1, (int)val_strlen(s)-1, NULL);
	if(s[0] == 0x80)
		bi->neg = 1;
	return bi_allocate(bi);
}
DEFINE_PRIM(bi_from_bin,1);

/**
	BigInteger A = (int)I
	If A is null, a new BigInteger will be returned.
**/
static value bi_from_int(value A, value I) {
	val_check_kind(A, k_biginteger);
	if(val_is_null(A))
		A = bi_new();
	BIGNUM *bi = val_biginteger(A);

	BN_set_word(bi, (unsigned long) abs(val_int(I)));
	if(val_int(I) < 0)
		bi->neg = 1;
	return A;
}
DEFINE_PRIM(bi_from_int, 2);

/**
	Return
**/
static value bi_to_int(value A) {
	val_check_kind(A, k_biginteger);
	BIGNUM *a = val_biginteger(A);
	unsigned int n = 0;
	int rv;

	if(a->top == 0)
		return alloc_int(0);
	n = (unsigned int)a->d[0];
	if(a->neg != 0)
		rv = (int)(0 - n);
	else
		rv = (int)n;

	rv &= 0x7fffffff;
	return alloc_int(rv);
}
DEFINE_PRIM(bi_to_int, 1);

//////////////////////////////////////////////////////////////
//                Bitwise methods                           //
//////////////////////////////////////////////////////////////
/** R = A << N **/
static value bi_shl_to(value A, value N, value R) {
	val_check_kind(A, k_biginteger);
	val_check(N, int);
	val_check_kind(R, k_biginteger);
// 	if(R == val_null)
// 		value R = bi_new();
	if(!BN_lshift(val_biginteger(R), val_biginteger(A), val_int(N)))
		THROW("error");
	return R;
}
DEFINE_PRIM(bi_shl_to, 3);

/** R = A >> N **/
static value bi_shr_to(value A, value N, value R) {
	val_check_kind(A, k_biginteger);
	val_check(N, int);
	val_check_kind(R, k_biginteger);
// 	if(R == val_null)
// 		value R = bi_new();
	if(!BN_rshift(val_biginteger(R), val_biginteger(A), val_int(N)))
		THROW("error");
	return R;
}
DEFINE_PRIM(bi_shr_to, 3);

/** number of bits set in A **/
static value bi_bitlength(value A) {
	val_check_kind(A, k_biginteger);
	return alloc_int(BN_num_bits(val_biginteger(A)));
}
DEFINE_PRIM(bi_bitlength, 1);

/** number of bytes to contain bits set in A **/
static value bi_bytelength(value A) {
	val_check_kind(A, k_biginteger);
	return alloc_int(BN_num_bytes(val_biginteger(A)));
}
DEFINE_PRIM(bi_bytelength, 1);

/** Number of bits set in A **/
static value bi_bits_set(value A) {
	val_check_kind(A, k_biginteger);
	BIGNUM *a = val_biginteger(A);
	int n = BN_num_bits(a);
	int c = 0, x;
	for(x=0; x<n; x++) {
		if(BN_is_bit_set(a, x))
			c++;
	}
	return alloc_int(c);
}
DEFINE_PRIM(bi_bits_set,1);

/** Lowest bit # set in A. Returns -1 if none set **/
static value bi_lowest_bit_set(value A) {
	val_check_kind(A, k_biginteger);
	BIGNUM *a = val_biginteger(A);
	int n = BN_num_bits(a);
	int c = -1, x;
	for(x=0; x<n; x++) {
		if(BN_is_bit_set(a, x)) {
			c=x;
			break;
		}
	}
	return alloc_int(c);
}
DEFINE_PRIM(bi_lowest_bit_set,1);

/** Set bit #N **/
static value bi_set_bit(value A, value N) {
	val_check_kind(A, k_biginteger);
	val_check(N, int);
	BIGNUM *a = val_biginteger(A);
	BN_set_bit(a, val_int(N));
	return val_true;
}
DEFINE_PRIM(bi_set_bit, 2);

/** Clear bit #N **/
static value bi_clear_bit(value A, value N) {
	val_check_kind(A, k_biginteger);
	val_check(N, int);
	BIGNUM *a = val_biginteger(A);
	BN_clear_bit(a, val_int(N));
	return val_true;
}
DEFINE_PRIM(bi_clear_bit, 2);

/** Flip bit #N **/
static value bi_flip_bit(value A, value N) {
	val_check_kind(A, k_biginteger);
	val_check(N, int);
	BIGNUM *a = val_biginteger(A);
	int n = val_int(N);
	if(BN_is_bit_set(a, n))
		BN_clear_bit(a, n);
	else
		BN_set_bit(a, n);
	return val_true;
}
DEFINE_PRIM(bi_flip_bit, 2);

/**
	R = A bw_op B
**/
static value bi_bitwise_to(value A, value B, value FUNC, value R) {
	val_check_kind(A, k_biginteger);
	val_check_kind(B, k_biginteger);
	val_check_kind(R, k_biginteger);
	val_check(FUNC, int);
	BIGNUM *a = val_biginteger(A);
	BIGNUM *b = val_biginteger(B);
	BIGNUM *r = val_biginteger(R);

	BN_copy(r, a);
	if (bn_wexpand(a,b->top) == NULL) THROW("a expand error");
	if (bn_wexpand(b,a->top) == NULL) THROW("b expand error");
	if (bn_wexpand(r,a->top) == NULL) THROW("r expand error");

	int f = val_int(FUNC);
	int x = 0;
	BN_ULONG *ptrA = a->d;
	BN_ULONG *ptrB = b->d;
	BN_ULONG *ptrR = r->d;
	if(ptrA == NULL || ptrB == NULL || ptrR == NULL)
		THROW("null pointer");

	assert(a->top == b->top);
	for(x = 0; x < a->top; x++) {
		switch(f) {
		case BW_AND:
			ptrR[x] = ptrA[x] & ptrB[x]; break;
		case BW_AND_NOT:
			ptrR[x] = ptrA[x] & (~ptrB[x]); break;
		case BW_OR:
			ptrR[x] = ptrA[x] | ptrB[x]; break;
		case BW_XOR:
			ptrR[x] = ptrA[x] ^ ptrB[x]; break;
		default:
			THROW("invalid op");
		}
	}
	bn_fix_top(a);
	bn_fix_top(b);
	bn_fix_top(r);
	return val_true;
}
DEFINE_PRIM(bi_bitwise_to,4);

/** R = ~A **/
static value bi_not(value A) {
	val_check_kind(A, k_biginteger);
	value R = bi_new();
	BIGNUM *a = val_biginteger(A);
	BIGNUM *r = val_biginteger(R);
	BN_copy(r, a);
	BN_ULONG *ptrA = a->d;
	BN_ULONG *ptrR = r->d;
	int x;
	for(x = 0; x < a->top; x++)
		ptrR[x] = ~ptrA[x];
	r->neg = (a->neg==0)?1:0;
	return R;
}
DEFINE_PRIM(bi_not,1);

/** true if bit #N set **/
static value bi_test_bit(value A, value N) {
	val_check_kind(A, k_biginteger);
	val_check(N, int);
	BIGNUM *a = val_biginteger(A);
	int n = val_int(N);
	if(BN_is_bit_set(a, n))
		return val_true;
	return val_false;
}
DEFINE_PRIM(bi_test_bit,2);