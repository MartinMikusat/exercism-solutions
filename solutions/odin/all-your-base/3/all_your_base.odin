package all_your_base

import "core:slice"

/*
	Solution reasoning
	-----------------
	Digit-array algorithm: no intermediate machine int, so no overflow for arbitrary-length inputs.

	Repeatedly divide the digit array by output_base. Each remainder is an output digit (LSB first).
	Division: for each digit, carry = carry×input_base + digit; quotient_digit = carry/output_base;
	carry = carry%output_base. Carry stays < output_base, so intermediates are bounded by
	input_base×output_base. That avoids overflow for typical bases, but input_base×output_base
	can still overflow if both bases are very large (e.g. near 2³²); not completely safe.
*/

Error :: enum {
	None,
	Invalid_Input_Digit,
	Input_Base_Too_Small,
	Output_Base_Too_Small,
	Unimplemented,
}

/// rebase converts a sequence of digits in input_base to the same number in output_base.
/// Uses digit-array division (no intermediate int) to reduce overflow risk; intermediates bounded by input_base×output_base.
/// Validates bases (≥2) and digit ranges (0 ≤ d < input_base). Returns (digits, error).
rebase :: proc(input_base: int, digits: []int, output_base: int) -> ([]int, Error) {
	// Validate bases first: positional notation requires base ≥ 2 (we need at least digits 0 and 1).
	// Motivation: base 0 or 1 is undefined; negative bases are invalid.
	if input_base < 2 do return nil, .Input_Base_Too_Small
	if output_base < 2 do return nil, .Output_Base_Too_Small

	// Validate each digit is in range [0, input_base).
	// Motivation: a digit ≥ base would be ambiguous; negative digits are never valid.
	for d in digits {
		if d < 0 || d >= input_base do return nil, .Invalid_Input_Digit
	}

	// Copy digits into a working buffer we can mutate.
	// Motivation: we repeatedly divide and replace; need a mutable copy.
	working: [dynamic]int
	defer delete(working)
	append(&working, ..digits)

	// Zero: empty or all zeros → [0].
	// Motivation: division loop would produce no output digits for zero.
	if len(working) == 0 {
		result := make([]int, 1)
		result[0] = 0
		return result, .None
	}

	// Repeatedly divide working by output_base; each remainder is an output digit (LSB first).
	// Motivation: carry stays < output_base, so intermediates bounded by input_base×output_base.
	// Note: input_base×output_base can still overflow for very large bases; not completely safe.
	digits_out: [dynamic]int
	defer delete(digits_out)
	for {
		all_zero := true
		for d in working do if d != 0 { all_zero = false; break }
		if all_zero do break

		carry: int
		quotient: [dynamic]int
		leading := true

		for d in working {
			carry = carry * input_base + d
			q := carry / output_base
			carry = carry % output_base
			if !leading || q != 0 {
				append(&quotient, q)
				leading = leading && q == 0
			}
		}
		append(&digits_out, carry)

		clear(&working)
		for q in quotient do append(&working, q)
		// Motivation: free quotient now so we hold only one allocation per iteration; defer would stack N deletes.
		delete(quotient)
	}

	// All zeros → input was 0.
	if len(digits_out) == 0 {
		result := make([]int, 1)
		result[0] = 0
		return result, .None
	}

	// Reverse: remainders were collected LSB-first.
	// Motivation: we need MSB-first to match the input convention (e.g. [4, 2] for forty-two).
	slice.reverse(digits_out[:])

	// Copy dynamic array into a slice for the return value.
	// Motivation: callers expect []int; a slice is the idiomatic return type.
	result := make([]int, len(digits_out))
	for d, i in digits_out do result[i] = d
	return result, .None
}
