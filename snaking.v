module main

import rand
import term.ui as tui

struct Game {
mut:
	tui       &tui.Context = 0
	direction Direction    = Direction.right
	points    []Point      = []Point{len: 5, init: Point{1, 1}}
	fruit     Point
}

struct Pos {
mut:
	x int
	y int
}

struct Point {
	x int
	y int
}

enum Direction {
	up
	down
	left
	right
}

fn event(e &tui.Event, x voidptr) {
	mut app := &Game(x)

	match e.code {
		.up {
			if app.direction != Direction.down {
				app.direction = Direction.up
			}
		}
		.down {
			if app.direction != Direction.up {
				app.direction = Direction.down
			}
		}
		.left {
			if app.direction != Direction.right {
				app.direction = Direction.left
			}
		}
		.right {
			if app.direction != Direction.left {
				app.direction = Direction.right
			}
		}
		.escape {
			exit(0)
		}
		else {}
	}
}

fn frame(game_ptr voidptr) {
	mut game := &Game(game_ptr)

	mut width := game.tui.window_width
	mut height := game.tui.window_height

	head := game.points[0]

	if head != game.fruit {
		game.points.delete_last()
	} else {
		game.fruit = Point{
			x: rand.intn(width) or { 1 }
			y: rand.intn(height) or { 1 }
		}
	}

	mut x := head.x
	mut y := head.y

	if x == 0 || x == width {
		exit(0)
	}

	if y == 0 || y == height {
		exit(0)
	}

	new_point := match game.direction {
		.up { Point{x, y - 1} }
		.down { Point{x, y + 1} }
		.left { Point{x - 1, y} }
		.right { Point{x + 1, y} }
	}

	if new_point in game.points {
		exit(0)
	}

	game.points.prepend(new_point)

	game.tui.clear()

	game.tui.set_bg_color(r: 174, g: 30, b: 90)
	game.tui.draw_point(game.fruit.x, game.fruit.y)
	game.tui.set_cursor_position(0, 0)

	game.tui.set_bg_color(r: 63, g: 81, b: 181)

	for point in game.points {
		game.tui.draw_point(point.x, point.y)
		game.tui.set_cursor_position(0, 0)
	}

	game.tui.reset()
	game.tui.flush()
}

fn main() {
	mut game := &Game{}

	game.tui = tui.init(
		user_data: game
		event_fn: event
		frame_fn: frame
		hide_cursor: true
		frame_rate: 10
	)

	width := game.tui.window_width
	height := game.tui.window_height

	game.fruit = Point{
		x: rand.intn(width) or { 1 }
		y: rand.intn(height) or { 1 }
	}

	game.tui.run() ?
}
