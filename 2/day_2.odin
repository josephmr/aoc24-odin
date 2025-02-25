package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:testing"

@(test)
test :: proc(t: ^testing.T) {
	reports := read_input("example.txt")
	defer {
		for report in reports {delete(report)}
		delete(reports)
	}

	testing.expect_value(t, len(reports), 6)
}

read_input :: proc(path: string) -> [dynamic][dynamic]int {
	raw_input := os.read_entire_file_from_filename(path) or_else panic("failed to read input file")
	defer delete(raw_input)
	input := string(raw_input)

	reports := make([dynamic][dynamic]int)
	for line in strings.split_lines_iterator(&input) {
		levels := make([dynamic]int)
		fields := strings.fields(line)
		defer delete(fields)
		for field in fields {
			append(&levels, strconv.atoi(field))
		}
		append(&reports, levels)
	}
	return reports
}

execute :: proc(reports: [dynamic][dynamic]int) -> int {
	is_safe :: proc(report: [dynamic]int) -> bool {
		gt := report[0] > report[1]
		for i in 0 ..< len(report) - 1 {
			first, second := report[i], report[i + 1]
			diff := abs(first - second)
			if diff < 1 || diff > 3 {
				return false
			}
			if gt && first <= second {
				return false
			} else if !gt && first >= second {
				return false
			}
		}
		return true
	}
	safe := 0
	for report, i in reports {
		// If not safe, remove the unsafe index and check if safe again
		if is_safe(report) {
			safe += 1
		}
	}
	return safe
}

main :: proc() {
	reports := read_input("input.txt")
	part1 := execute(reports)
	fmt.printfln("Part1: %d", part1)
}
