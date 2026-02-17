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

/// orbital_period returns the planet's orbital period in Earth years.
orbital_period :: proc(planet: Planet) -> f64 {
	switch planet {
	case .Mercury: return 0.2408467
	case .Venus:   return 0.61519726
	case .Earth:   return 1.0
	case .Mars:    return 1.8808158
	case .Jupiter: return 11.862615
	case .Saturn:  return 29.447498
	case .Uranus:  return 84.016846
	case .Neptune: return 164.79132
	}
	return 0.0 // unreachable; all Planet variants handled above
}

/// age returns the age in planet-years given seconds and the target planet.
/// One Earth year = 365.25 days = 31,557,600 seconds.
age :: proc(planet: Planet, seconds: int) -> f64 {
	return f64(seconds) / (EARTH_YEAR_SECONDS * orbital_period(planet))
}
