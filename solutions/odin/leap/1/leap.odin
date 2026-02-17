package leap

/// is_leap_year returns true if year is a leap year in the Gregorian calendar.
/// Leap year: divisible by 4, and either not divisible by 100 or divisible by 400.
is_leap_year :: proc(year: int) -> bool {
	return year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)
}
