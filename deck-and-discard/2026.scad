// Things to change to alter the size of the holder

// misbehaves = 63 x 89 x 30
// nav = 63 x 89 x 20
// supply = 63 x 89 x 15
// contact = 89 x 63 x 15

card_width = 63;
card_length = 89;
deck_height = 30;

// Other things you may want to change

wall_width = 2;
holder_height = 40;
front_wall_width_percent = 6;
floor_depth = wall_width;
front_height = floor_depth + 10;
rounding = 2;
deck_extra_percent = 15;

$fs = $preview ? 1 : 0.05;  // Don't generate smaller facets than 0.1 mm
$fa = $preview ? 15 : 5;    // Don't generate larger angles than 5 degrees

////////////////////////////////////////////

// Calculated things

discard_length = card_length + 5;
draw_length = deck_height + 5;
total_width = card_width + 10;
inner_width = total_width - (wall_width * 2);
total_length = discard_length + draw_length + (wall_width * 3);

front_wall_width = inner_width / 100 * front_wall_width_percent;

initial_window_width = draw_length - (wall_width * 4);
// can't assign in an if block
large_windows = initial_window_width > (wall_width * 8);
window_width = large_windows ? (draw_length / 2) - (wall_width * 3) : initial_window_width;
deck_windows = large_windows ? 2 : 1;

wall_rotation = atan((holder_height - front_height) / (discard_length));

// base calculations that other things need
titled_length = sqrt((front_height ^ 2) + (discard_length ^ 2) - (floor_depth ^ 2));
base_rotation = atan(front_height / discard_length) - atan(floor_depth / titled_length);

// more window stuff
first_window = ((wall_width * 4) + rounding) / tan(wall_rotation) + tan(base_rotation);

// build it!
holder();

module holder()
{
  base();
  side_wall();
  translate([total_width - wall_width, 0, 0]) side_wall();
  front_wall();
  translate([total_width, 0, 0]) mirror([1, 0, 0]) front_wall();
  translate([0, discard_length + wall_width, 0]) join_wall();
  translate([0, total_length - wall_width, 0]) join_wall();
}

module base()
{
  // width of "edge" on the base
  base_edge = wall_width * 2;

  // setup for rectangular cutouts
  cutout_width = (inner_width / 2) - (base_edge * 2.5);
  cutout_left_x = wall_width + base_edge * 2;
  cutout_right_x = wall_width + (base_edge / 2) + (inner_width / 2);

  // base for deck holder at back
  translate([0, discard_length + (wall_width * 2), 0])
    difference() {
      cube([total_width, draw_length, floor_depth]);

      deck_cutout_length = draw_length - (base_edge * 2);

      translate([cutout_left_x, base_edge, 0])
        rounded_cube([cutout_width, deck_cutout_length, floor_depth]);
      translate([cutout_right_x, base_edge, 0])
        rounded_cube([cutout_width, deck_cutout_length, floor_depth]);
    }

  cutout_radius = (total_width / 2) - front_wall_width - wall_width;
  y_offset = sin(base_rotation) * floor_depth;
  z_offset = cos(base_rotation) * floor_depth;

  // base for discard at front
  translate([0, wall_width, 0])
    difference() {
      cube([total_width, discard_length, front_height]);

      translate([front_wall_width + wall_width, 0, 0])
        cube([total_width - ((front_wall_width + wall_width) * 2), wall_width, front_height]);
      translate([total_width / 2, wall_width, 0])
        cylinder(front_height, cutout_radius, cutout_radius);

      discard_cutout_length = discard_length - cutout_radius - base_edge * 2 - wall_width;
      discard_cutout_y = cutout_radius + base_edge + wall_width;

      translate([cutout_left_x, discard_cutout_y, 0])
        rounded_cube([cutout_width, discard_cutout_length, front_height]);
      translate([cutout_right_x, discard_cutout_y, 0])
        rounded_cube([cutout_width, discard_cutout_length, front_height]);

      translate([0, 0, front_height])
        rotate([-base_rotation, 0, 0])
          cube([total_width, titled_length, front_height]);
    }
}

module side_wall()
{
  window_space = discard_length - first_window;
  window_count = floor(window_space / (window_width + (wall_width * 2)));
  window_gap = (window_space - (window_count * window_width)) / (window_count + 1);

  difference() {
    cube([wall_width, total_length, holder_height]);

    // slice out the top to angle it down towards the front
    translate([0, (discard_length / 2) + wall_width, holder_height - (holder_height - front_height) / 2])
      rotate([wall_rotation, 0, 0])
        translate([0, -total_length / 2, 0])
          cube([wall_width, total_length, holder_height]);

    // window(s) for the deck holder
    for (i = [1:(deck_windows)]) {
      start_point = discard_length + (wall_width * 4) + ((window_width + (wall_width * 2)) * (i - 1));
      translate([0, start_point, floor_depth + wall_width * 2])
        window();
    }

    // windows for the discard area
    for (i = [1:(window_count)]) {
      start_point = wall_width + first_window + (window_gap * i) + (window_width * (i - 1));
      translate([0, start_point, floor_depth + wall_width])
        squished_window(start_point);
    }
  }
}


module join_wall()
{
  cutout_width = (inner_width / 2) - (inner_width / 100 * deck_extra_percent);

  difference() {
    cube([total_width, wall_width, holder_height]);

    translate([total_width / 2, wall_width, holder_height])
      rotate([90, 0, 0])
        cylinder(wall_width, cutout_width, cutout_width);
  }
}

module front_wall()
{
  cube([front_wall_width + wall_width, wall_width, front_height]);
}

module squished_window(start_point)
{
  radius = wall_width;

  start_bottom = front_height - tan(base_rotation) * (start_point + radius);
  end_bottom = front_height - tan(base_rotation) * (start_point + window_width - radius);

  x_max = window_width - radius;
  y_max = front_height - floor_depth - radius - (wall_width * 4);

  start_top = y_max + tan(wall_rotation) * (start_point + radius);
  end_top = y_max + tan(wall_rotation) * (start_point + window_width - radius);

  rotate([90, 0, 90])
    linear_extrude(wall_width)
      hull() {
        translate(v = [radius, radius + start_bottom, 0]) circle(radius);
        translate(v = [radius, start_top, 0]) circle(radius);
        translate(v = [x_max, radius + end_bottom, 0]) circle(radius);
        translate(v = [x_max, end_top, 0]) circle(radius);
      }
}

module window()
{
  rotate([90, 0, 90])
    rounded_cube([
      window_width,
          holder_height - floor_depth - (wall_width * 4),
      wall_width
      ]);
}


module rounded_cube(size = [10, 10, 10], radius = wall_width)
{
  translate_min = radius;
  translate_xmax = size[0] - radius;
  translate_ymax = size[1] - radius;

  linear_extrude(size[2])
    rounded_rect([size[0], size[1]], radius);
}

module rounded_rect(size = [5, 5], radius = rounding)
{
  hull()
    for (translate_x = [radius, size[0] - radius])
    for (translate_y = [radius, size[1] - radius])
    translate(v = [translate_x, translate_y, 0])
      circle(radius);
}
