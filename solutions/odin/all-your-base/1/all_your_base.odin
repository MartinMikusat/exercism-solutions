package all_your_base

import "core:slice"

/*
	Solution reasoning
	-----------------
	Convert digits in input_base to digits in output_base in two steps:

	1. Input → value: Evaluate the polynomial value = Σ(digit_i × input_base^exponent_i).
	   Each digit is multiplied by its positional weight (a power of the base).

	2. Value → output: Repeatedly divide the value by output_base; each remainder is an
	   output digit (LSB first). Reverse to get MSB-first digit order.

	This is the most naive approach: we use the explicit polynomial form with repeated
	exponentiation (pow_int) instead of Horner's method, and we collapse the entire
	number into a single machine int. That makes the logic easy to follow but is
	inefficient (O(n²) multiplications for n digits) and can overflow on large inputs.
*/

Error :: enum {
	None,
	Invalid_Input_Digit,
	Input_Base_Too_Small,
	Output_Base_Too_Small,
	Unimplemented,
}

/// pow_int returns base^exp for non-negative exp. Used for explicit polynomial evaluation.
/// Motivation: we need positional weights (b^0, b^1, b^2, ...) when summing digit × weight.
pow_int :: proc(base: int, exp: int) -> int {
	result := 1
	// Multiply base by itself exp times; exp=0 yields 1 (empty loop).
	for _ in 0..<exp {
		result *= base
	}
	return result
}

/// rebase converts a sequence of digits in input_base to the same number in output_base.
/// Uses positional notation: value = Σ(digit_i × input_base^i). Validates bases (≥2) and
/// digit ranges (0 ≤ d < input_base). Returns (digits, error).
rebase :: proc(input_base: int, digits: []int, output_base: int) -> ([]int, Error) {
	// Validate bases first: positional notation requires base ≥ 2 (we need at least digits 0 and 1).
	// Motivation: base 0 or 1 is undefined; negative bases are invalid.
	if input_base < 2 do return nil, .Input_Base_Too_Small
	if output_base < 2 do return nil, .Output_Base_Too_Small

	// Validate each digit is in range [0, input_base).
	// Motivation: a digit ≥ base would be ambiguous (e.g. "2" in base 2 is invalid); negative digits are never valid.
	for d in digits {
		if d < 0 || d >= input_base do return nil, .Invalid_Input_Digit
	}

	// Step 1: Convert input digits to a single numeric value using the explicit polynomial.
	// Motivation: value = d₀×b^(n-1) + d₁×b^(n-2) + ... + dₙ×b⁰; digit at index i has weight b^(len-1-i).
	value: int
	for i in 0..<len(digits) {
		exponent := len(digits) - 1 - i
		value += digits[i] * pow_int(input_base, exponent)
	}

	// Special-case zero: the division loop below would produce no digits for value=0.
	// Motivation: we must return [0], not an empty slice.
	if value == 0 {
		result := make([]int, 1)
		result[0] = 0
		return result, .None
	}

	// Step 2: Convert value to output base by repeated division. Each remainder is a digit (LSB first).
	// Motivation: value = q×output_base + r ⇒ r is the least significant digit; repeat with q.
	// Use dynamic array because we don't know the output length upfront; defer delete frees it on return.
	digits_out: [dynamic]int
	defer delete(digits_out)
	for value > 0 {
		append(&digits_out, value % output_base)
		value /= output_base
	}

	// Reverse: remainders were collected LSB-first (rightmost digit first).
	// Motivation: we need MSB-first to match the input convention (e.g. [4, 2] for forty-two, not [2, 4]).
	slice.reverse(digits_out[:])

	// Copy dynamic array into a slice for the return value.
	// Motivation: callers expect []int; dynamic arrays own memory and have different semantics; a slice is the idiomatic return type.
	result := make([]int, len(digits_out))
	for d, i in digits_out do result[i] = d
	return result, .None
}
