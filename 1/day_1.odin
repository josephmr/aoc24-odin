package main

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:testing"

@(test)
test :: proc(t: ^testing.T) {
	left, right := read_input("example.txt") or_else panic("failed to read test file")
	defer delete(left)
	defer delete(right)
	testing.expect_value(t, len(left), 6)
	left_values := [6]int{3, 4, 2, 1, 3, 3}
	for value, i in left_values {
		testing.expect_value(t, left[i], value)
	}
	testing.expect_value(t, len(right), 6)
	right_values := [6]int{4, 3, 5, 3, 9, 3}
	for value, i in right_values {
		testing.expect_value(t, right[i], value)
	}
	part1, part2 := execute(left[:], right[:])
	testing.expect_value(t, part1, 11)
	testing.expect_value(t, part2, 31)
}

read_input :: proc(path: string) -> (left: [dynamic]int, right: [dynamic]int, ok: bool) {
	data := os.read_entire_file_from_filename(path) or_return
	defer delete(data)
	it := string(data)

	for line in strings.split_lines_iterator(&it) {
		fields := strings.fields(line)
		defer delete(fields)
		assert(len(fields) == 2, "input must have two numbers per line")

		append(&left, strconv.atoi(fields[0]))
		append(&right, strconv.atoi(fields[1]))
	}
	return left, right, true
}

execute :: proc(left, right: []int) -> (part1: int, part2: int) {
	slice.sort(left)
	slice.sort(right)

	right_map := make(map[int]int)
	defer delete(right_map)
	for value in right {
		right_map[value] += 1
	}

	for _, i in left {
		part1 += abs(right[i] - left[i])
		part2 += left[i] * right_map[left[i]]
	}
	return
}


main :: proc() {
	left, right := read_input("input.txt") or_else panic("failed to parse input")
	defer {
		delete(left)
		delete(right)
	}
	part1, part2 := execute(left[:], right[:])
	fmt.printfln("Part1: %d\nPart2: %d", part1, part2)
}
