package armstrong_numbers

/// int_pow computes base^exp for non-negative integers using binary exponentiation.
/// Motivation: core:math provides only floating-point pow; Armstrong needs exact integer exponentiation for u128.
int_pow :: proc(base: u128, exp: int) -> u128 {
	if exp == 0 do return 1
	result: u128 = 1
	b := base
	e := exp
	// Binary exponentiation: when e is odd, multiply result by b; square b and halve e each iteration.
	// Motivation: O(log exp) multiplications instead of O(exp); avoids overflow for large exponents.
	for e > 0 {
		if e & 1 != 0 do result *= b
		b *= b
		e >>= 1
	}
	return result
}

/// is_armstrong_number returns true if n equals the sum of its digits each raised to the power of the digit count.
/// Examples:
///   - 9 is Armstrong: 9 = 9^1 = 9
///   - 10 is not: 10 != 1^2 + 0^2 = 1
///   - 153 is Armstrong: 153 = 1^3 + 5^3 + 3^3 = 1 + 125 + 27 = 153
///   - 154 is not: 154 != 1^3 + 5^3 + 4^3 = 1 + 125 + 64 = 190
/// Motivation: Armstrong numbers (narcissistic numbers) are a mathematical curiosity; the algorithm extracts digits,
/// counts them, and sums digit^count—returning true iff that sum equals n.
is_armstrong_number :: proc(n: u128) -> bool {
	// Zero is Armstrong: 0 = 0^1.
	// Motivation: digit-extraction loop yields no digits; special-case avoids empty-digits edge case.
	if n == 0 do return true

	// Extract base-10 digits (LSB first) via repeated division.
	// Motivation: n % 10 gives least significant digit; n / 10 shifts right.
	digits: [dynamic]u128
	defer delete(digits)
	m := n
	for m > 0 {
		append(&digits, m % 10)
		m /= 10
	}
	// Exponent for Armstrong formula: each digit is raised to the number of digits.
	num_digits := len(digits)

	// Sum each digit raised to the power of the digit count; bail early if sum exceeds n.
	// Motivation: early exit avoids unnecessary work and potential overflow for non-Armstrong numbers.
	sum: u128 = 0
	for d in digits {
		sum += int_pow(d, num_digits)
		if sum > n do return false
	}
	return sum == n
}
