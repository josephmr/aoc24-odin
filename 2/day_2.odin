package main

import "core:fmt"
import "core:os"
import "core:slice"
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

	part1, part2 := execute(reports)
	testing.expect_value(t, part1, 2)
	testing.expect_value(t, part2, 4)
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

execute :: proc(reports: [dynamic][dynamic]int) -> (part1: int, part2: int) {
	is_safe :: proc(report: [dynamic]int, retry: bool) -> bool {
		gt := report[0] > report[1]
		for i in 0 ..< len(report) - 1 {
			first, second := report[i], report[i + 1]
			diff := abs(first - second)
			if (diff < 1 || diff > 3) || (gt && first <= second) || (!gt && first >= second) {
				if (!retry) {
					return false
				}
				without_first := slice.clone_to_dynamic(report[:])
				without_second := slice.clone_to_dynamic(report[:])
				without_prev := slice.clone_to_dynamic(report[:])
				defer {
					delete(without_first)
					delete(without_second)
					delete(without_prev)
				}
				ordered_remove(&without_first, i)
				ordered_remove(&without_second, i + 1)
				if i > 0 {
					ordered_remove(&without_prev, i - 1)
				}
				return(
					is_safe(without_first, false) ||
					is_safe(without_second, false) ||
					is_safe(without_prev, false) \
				)
			}
		}
		return true
	}
	for report, i in reports {
		if is_safe(report, false) {
			part1 += 1
		}
		if is_safe(report, true) {
			part2 += 1
		}
	}
	return
}

main :: proc() {
	reports := read_input("input.txt")
	part1, part2 := execute(reports)
	fmt.printfln("Part1: %d", part1)
	fmt.printfln("Part2: %d", part2)
}
