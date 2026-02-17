package two_fer

import "core:fmt"

/// two_fer returns "One for X, one for me." where X is the given name, or "you" if no name is provided.
/// Uses a default argument so callers can omit the name when they don't know it.
two_fer :: proc(name: string = "") -> string {
	recipient := name if len(name) != 0 else "you"
	return fmt.tprintf("One for %s, one for me.", recipient)
}
