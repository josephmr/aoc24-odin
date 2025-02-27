package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:testing"
import "core:unicode"

@(test)
test :: proc(t: ^testing.T) {
	grid := read_input("example.txt")
	defer destroy_grid(grid)

	part1, part2 := execute(grid)
	testing.expect_value(t, part1, 18)
	testing.expect_value(t, part2, 9)
}

destroy_grid :: proc(grid: Grid) {
	for arr in grid {
		delete(arr)
	}
	delete(grid)
}

read_input :: proc(path: string) -> (result: Grid) {
	input := os.read_entire_file(path) or_else panic("failed to read input")
	defer delete(input)

	str := string(input)

	for line in strings.split_lines_iterator(&str) {
		runes := make([dynamic]rune, strings.rune_count(line))
		for char, i in line {
			runes[i] = char
		}
		append(&result, runes)
	}

	return result
}

Grid :: [dynamic][dynamic]rune

Direction :: enum {
	N,
	NE,
	E,
	SE,
	S,
	SW,
	W,
	NW,
}

Direction_Vectors := [Direction][2]int {
	.N  = {0, -1},
	.NE = {1, -1},
	.E  = {1, 0},
	.SE = {1, 1},
	.S  = {0, 1},
	.SW = {-1, 1},
	.W  = {-1, 0},
	.NW = {-1, -1},
}

get_pos :: proc(grid: Grid, position: [2]int) -> rune {
	return grid[position.y][position.x]
}

get_word :: proc(grid: Grid, position: [2]int, direction: Direction, length := 4) -> string {
	dir_vec := Direction_Vectors[direction]
	end_position := position + dir_vec * (length - 1)
	out_of_bounds :: proc(grid: Grid, position: [2]int) -> bool {
		return(
			position.x < 0 ||
			position.x >= len(grid[0]) ||
			position.y < 0 ||
			position.y >= len(grid) \
		)
	}
	if out_of_bounds(grid, end_position) || out_of_bounds(grid, position) {
		return ""
	}
	result := strings.builder_make_len_cap(0, length)
	defer strings.builder_destroy(&result)
	for i := 0; i < length; i += 1 {
		strings.write_rune(&result, get_pos(grid, position + dir_vec * i))
	}
	return strings.clone(strings.to_string(result))
}

check_xmas :: proc(grid: Grid, position: [2]int) -> bool {
	is_mas :: proc(s: string) -> bool {
		return strings.compare(s, "MAS") == 0 || strings.compare(s, "SAM") == 0
	}
	word := get_word(grid, position, .SE, 3)
	defer delete(word)
	if is_mas(word) {
		xword := get_word(grid, position + Direction_Vectors[.E] * 2, .SW, 3)
		defer delete(xword)
		return is_mas(xword)
	}
	return false
}

execute :: proc(grid: Grid) -> (part1: int, part2: int) {
	for i := 0; i < len(grid); i += 1 {
		for j := 0; j < len(grid[i]); j += 1 {
			for dir in Direction {
				word := get_word(grid, {i, j}, dir)
				defer delete(word)
				if strings.compare(word, "XMAS") == 0 {
					part1 += 1
				}
			}
			if check_xmas(grid, {i, j}) {
				part2 += 1
			}
		}
	}
	return
}

main :: proc() {
	grid := read_input("input.txt")
	part1, part2 := execute(grid)
	fmt.println("Part1:", part1)
	fmt.println("Part2:", part2)
}
