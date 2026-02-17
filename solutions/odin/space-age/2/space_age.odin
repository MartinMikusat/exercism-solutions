package space_age

Planet :: enum {
	Mercury,
	Venus,
	Earth,
	Mars,
	Jupiter,
	Saturn,
	Uranus,
	Neptune,
}

EARTH_YEAR_SECONDS :: 31_557_600.0

period := [Planet]f64{
	.Mercury = 0.2408467,
	.Venus   = 0.61519726,
	.Earth   = 1.0,
	.Mars    = 1.8808158,
	.Jupiter = 11.862615,
	.Saturn  = 29.447498,
	.Uranus  = 84.016846,
	.Neptune = 164.79132,
}

/// age returns the age in planet-years given seconds and the target planet.
/// One Earth year = 365.25 days = 31,557,600 seconds.
age :: proc(planet: Planet, seconds: int) -> f64 {
	return f64(seconds) / (EARTH_YEAR_SECONDS * period[planet])
}
