package all_your_base

import "core:slice"

/*
	Solution reasoning
	-----------------
	Convert digits in input_base to digits in output_base in two steps:

	1. Input → value: Horner's method: value = ((d₀×b + d₁)×b + d₂)×b + ...
	   One pass, O(n) multiplications; no explicit exponentiation.

	2. Value → output: Repeatedly divide by output_base; each remainder is an output
	   digit (LSB first). Reverse to get MSB-first digit order.

	Still collapses to a single machine int, so can overflow on very large inputs.
*/

Error :: enum {
	None,
	Invalid_Input_Digit,
	Input_Base_Too_Small,
	Output_Base_Too_Small,
	Unimplemented,
}

/// rebase converts a sequence of digits in input_base to the same number in output_base.
/// Uses Horner's method for input→value, then repeated division for value→output. Validates
/// bases (≥2) and digit ranges (0 ≤ d < input_base). Returns (digits, error).
rebase :: proc(input_base: int, digits: []int, output_base: int) -> ([]int, Error) {
	// Validate bases first: positional notation requires base ≥ 2 (we need at least digits 0 and 1).
	// Motivation: base 0 or 1 is undefined; negative bases are invalid.
	if input_base < 2 do return nil, .Input_Base_Too_Small
	if output_base < 2 do return nil, .Output_Base_Too_Small

	// Step 1: Convert input digits to value using Horner's method: value = ((d₀×b + d₁)×b + d₂)×b + ...
	// Motivation: equivalent to Σ(digit_i × b^exponent_i) but O(n) instead of O(n²); validate each digit as we go.
	value: int
	for d in digits {
		if d < 0 || d >= input_base do return nil, .Invalid_Input_Digit
		value = value * input_base + d
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
