package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:testing"
import "core:text/regex"

@(test)
test :: proc(t: ^testing.T) {
	input := read_input("example.txt")
	defer delete(input)

	part1 := execute(input)
	testing.expect_value(t, part1, 161)
}

read_input :: proc(path: string) -> string {
	raw_input := os.read_entire_file_from_filename(path) or_else panic("failed to read input")
	return string(raw_input)
}

execute :: proc(expression: string) -> (part1: int) {
	r :=
		regex.create(`mul\((\d+),(\d+)\)`, {.Global, .Multiline}) or_else panic(
			"failed to create regex",
		)
	defer regex.destroy(r)

	start := 0
	capture := regex.preallocate_capture()
	defer regex.destroy(capture)
	for _, success := regex.match(r, expression, &capture); success; {
		start += capture.pos[0][1]
		part1 += strconv.atoi(capture.groups[1]) * strconv.atoi(capture.groups[2])
		_, success = regex.match(r, expression[start:], &capture)
	}
	return part1
}

main :: proc() {
	expression := read_input("input.txt")
	defer delete(expression)
	part1 := execute(expression)
	fmt.println("Part1:", part1)
}
