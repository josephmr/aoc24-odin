package main

import "core:fmt"
import "core:math"
import "core:os"
import "core:strconv"
import "core:strings"

RuleSet :: map[string]struct {}
Page :: struct {
	// 75,47,61,53,29
	data:  [dynamic]int,
	// { 75: 0, 47: 1, 61: 2, 53: 3, 29: 4}
	index: map[int]int,
}

make_rule_set :: proc(rules_str: ^string) -> RuleSet {
	rule_set := make(map[string]struct {})
	for rule in strings.split_lines_iterator(rules_str) {
		rule_set[strings.clone(rule)] = {}
	}
	return rule_set
}

make_pages :: proc(pages_str: ^string) -> (pages: [dynamic]Page) {
	is_comma :: proc(r: rune) -> bool {
		return r == ','
	}
	for page_str in strings.split_lines_iterator(pages_str) {
		fields := strings.fields_proc(page_str, is_comma)
		page := Page{}
		for num_str, i in fields {
			num := strconv.atoi(num_str)
			append(&page.data, num)
			page.index[num] = i
		}
		append(&pages, page)
	}
	return
}

read_input :: proc(path: string) -> (rule_set: RuleSet, pages: [dynamic]Page) {
	input := os.read_entire_file(path) or_else panic("failed to read input file")
	defer delete(input)
	str_input := string(input)

	empty_line := strings.index(str_input, "\n\n")
	assert(empty_line != -1, "expected empty line separating input chunks")
	slice := str_input[:empty_line]
	rule_set = make_rule_set(&slice)

	slice = str_input[empty_line + len("\n\n"):]
	pages = make_pages(&slice)

	return
}

rule_key :: proc(nums: [2]int) -> string {
	return fmt.aprintf("%d|%d", nums[0], nums[1])
}

check_page :: proc(page: Page, rule_set: RuleSet) -> bool {
	for num, i in page.data {
		for anum in page.data[i + 1:] {
			bad_rule := rule_key({anum, num})
			if _, ok := rule_set[bad_rule]; ok {
				return false
			}
		}
	}
	return true
}

execute :: proc(rule_set: RuleSet, pages: []Page) -> (part1, part2: int) {
	for page in pages {
		if check_page(page, rule_set) {
			part1 += page.data[len(page.data) / 2]
		}
	}
	return
}

main :: proc() {
	rule_set, pages := read_input("input.txt")
	part1, part2 := execute(rule_set, pages[:])
	fmt.println("Part1:", part1)
}
