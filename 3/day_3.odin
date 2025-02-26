package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:testing"
import "core:text/regex"

@(test)
test :: proc(t: ^testing.T) {
	input := read_input("example.txt")
	defer delete(input)

	part1, part2 := execute(input)
	testing.expect_value(t, part1, 161)
	testing.expect_value(t, part2, 48)
}

read_input :: proc(path: string) -> string {
	raw_input := os.read_entire_file_from_filename(path) or_else panic("failed to read input")
	return string(raw_input)
}

multiply :: proc(expression: string) -> (result: int) {
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
		result += strconv.atoi(capture.groups[1]) * strconv.atoi(capture.groups[2])
		_, success = regex.match(r, expression[start:], &capture)
	}
	return
}

execute :: proc(expression: string) -> (part1: int, part2: int) {
	part1 = multiply(expression)

	return
}

// TODO is usage of string here resulting in copies?
Tokenizer_Iterator :: struct {
	data:  string,
	index: int,
}

make_tokenizer_iterator :: proc(data: string) -> Tokenizer_Iterator {
	return Tokenizer_Iterator{data = data}
}

tokenizer_iterator :: proc(it: ^Tokenizer_Iterator) -> (val: string, idx: int, cond: bool) {
	fmt.println("iterating")
	if index := strings.index(it.data[it.index:], "don't()"); index != -1 {
		fmt.printfln("Found don't() at [%v]: %v", index, it.data[it.index + index:])
		dont_end := it.index + index + len("don't()")
		val = it.data[it.index:dont_end]
		next_do_index := strings.index(it.data[dont_end:], "do()")

		if next_do_index == -1 {
			fmt.println("No more do()s")
			return val, 0, false
		} else {
			fmt.printfln(
				"Found another do() at [%v]: %v",
				next_do_index,
				it.data[dont_end + next_do_index:],
			)
			it.index = dont_end + next_do_index + len("do()")
			return val, 0, true
		}
	}
	fmt.println("no don't()", it.index, it.data)
	return it.data[it.index:], 0, false
}

main :: proc() {
	expression := read_input("example.txt")
	defer delete(expression)
	part1, part2 := execute(expression)
	fmt.println("Part1:", part1)
	fmt.println("Part2:", part2)

	it := make_tokenizer_iterator(expression)
	for val in tokenizer_iterator(&it) {
		fmt.println(val)
	}
}
