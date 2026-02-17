package two_fer

import "core:fmt"

/// two_fer returns "One for X, one for me." where X is the given name, or "you" if no name is provided.
/// Uses Maybe(string) so callers can pass nil when they don't know the name.
two_fer :: proc(name: Maybe(string) = nil) -> string {
	recipient := name.? or_else "you"
	return fmt.tprintf("One for %s, one for me.", recipient)
}
