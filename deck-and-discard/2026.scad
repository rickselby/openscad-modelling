// Things to change to alter the size of the holder

// misbehaves = 63 x 89 x 30
// nav = 63 x 89 x 20
// supply = 63 x 89 x 15
// contact = 89 x 63 x 15

// Other things you may want to change

wall_width = 2.4;
floor_depth = wall_width;
front_height = floor_depth * 3;
// corner rounding on cutouts
rounding = wall_width;
// still not happy with the windows. feel free to try them out!
windows = false;
// mm to add to card width/height / deck height
extra_space = 5;

$fs = $preview ? 1 : 0.1;  // Don't generate smaller facets than 0.1 mm
$fa = $preview ? 15 : 2;    // Don't generate larger angles than 5 degrees

////////////////////////////////////////////

// build it!
holder(63, 89, 30);
translate([80, 0, 0]) holder(63, 89, 20);
translate([160, 0, 0]) holder(63, 89, 15);
translate([240, 0, 0]) holder(89, 63, 15);

module holder(card_width, card_length, deck_height)
{
  // Calculated things

  half_wall = wall_width / 2;
  holder_height = max(card_length * 0.45, deck_height + floor_depth + extra_space);

  inner_width = card_width + extra_space;
  total_width = inner_width + (wall_width * 2);

  front_tilted_length = card_length;
  front_length = sqrt((front_tilted_length ^ 2) - ((front_height - floor_depth) ^ 2));
  back_length = deck_height + extra_space;
  total_length = front_length + back_length + (wall_width * 2);

  window_side_edges = wall_width * 2;
  window_top_bottom_edges = wall_width;
  window_width = min(back_length - (window_side_edges * 2), 14);

  // angle of rotation for the wall cutouts
  wall_rotation = atan((holder_height - front_height) / (front_length));

  // base calculations that windows need
  base_rotation = asin((front_height - floor_depth) / front_tilted_length);

  // build the actual holder
  translate([half_wall, 0, 0]) base();
  side_wall();
  translate([total_width - wall_width, 0, 0]) side_wall();
  translate([half_wall, front_length, 0]) join_wall();
  translate([half_wall, total_length - wall_width, 0]) join_wall();

  // rounding between walls
  // front and join wall
  translate([wall_width, front_length, 0])
    rotate([0, 0, -90]) linear_extrude(holder_height) inner_rounding();

  translate([total_width - wall_width, front_length, 0])
    rotate([0, 0, 180]) linear_extrude(holder_height) inner_rounding();

  // back and join wall
  translate([wall_width, front_length + wall_width, 0])
    linear_extrude(holder_height) inner_rounding();

  translate([total_width - wall_width, front_length + wall_width, 0])
    rotate([0, 0, 90]) linear_extrude(holder_height) inner_rounding();

  // back and back wall
  translate([wall_width, total_length - wall_width, 0])
    rotate([0, 0, -90]) linear_extrude(holder_height) inner_rounding();

  translate([total_width - wall_width, total_length - wall_width, 0])
    rotate([0, 0, 180]) linear_extrude(holder_height) inner_rounding();

  module base()
  {
    // base goes halfway into each wall
    base_width = inner_width + wall_width;

    base_edge = extra_space;

    cutouts = 3;
    cutout_width = (inner_width - (base_edge * (cutouts + 1))) / cutouts;
    cutout_x = [for (a = [1 : cutouts]) half_wall + (base_edge * a) + (cutout_width * (a - 1))];

    // base for back
    translate([0, front_length + wall_width, 0])
      difference() {
        cube([base_width, back_length, floor_depth]);

        for (x = cutout_x)
          translate([x, base_edge, 0])
            rounded_cube([cutout_width, back_length - (base_edge * 2), floor_depth]);
      }

    // base for front
    difference() {
      cube([base_width, front_length, front_height]);

      front_cutout_radius = (inner_width / 2) - base_edge;

      // rounded cutout at front
      translate([base_width / 2, 0])
        cylinder(front_height, front_cutout_radius, front_cutout_radius);

      // round front corners
      rounding_offset = sqrt((front_cutout_radius ^ 2) - (half_wall ^ 2));
      translate([(base_width / 2) - rounding_offset, 0, 0])
        rotate([0, 0, 90]) linear_extrude(front_height) inner_rounding();
      translate([(base_width / 2) + rounding_offset, 0, 0])
        linear_extrude(front_height) inner_rounding();

      front_cutout_length = front_length - (base_edge * 2);

      // rectangular-ish cutouts to save material
      difference() {
        union() {
          for (x = cutout_x)
            translate([x, base_edge, 0])
              rounded_cube([cutout_width, front_cutout_length, front_height]);
        }

        // cut out the rounded cut out at the front plus the base edge
        translate([base_width / 2, 0])
          cylinder(front_height, front_cutout_radius + base_edge, front_cutout_radius + base_edge);

        // round the front corners
        h = front_cutout_radius + base_edge + rounding;

        for (x = cutout_x) {
          x1_from_left = x + rounding;
          x1 = (base_width / 2) - x1_from_left;
          y1 = sqrt((h ^ 2) - (x1 ^ 2));
          translate([x1_from_left, y1, 0])
            fill_in_corner(h, x1, y1);

          x2_from_left = x + cutout_width - rounding;
          x2 = (base_width / 2) - x2_from_left;
          y2 = sqrt((h^2) - (x2^2));
          translate([x2_from_left, y2, 0])
            mirror([1, 0, 0])
              fill_in_corner(h, x2, y2, xpos = false);
        }
      }

      // slope the base for easy pickup of cards
      translate([0, 0, front_height])
        rotate([-base_rotation, 0, 0])
          cube([base_width, front_tilted_length, front_height]);
    }
  }

  module side_wall()
  {
    difference() {
      linear_extrude(holder_height)
        hull() {
          translate([half_wall, half_wall, 0])
            circle(half_wall);
          translate([half_wall, total_length - half_wall, 0])
            circle(half_wall);
        }

      //    cube([wall_width, total_length, holder_height]);

      // slice out the top to angle it down towards the front
      //    translate([0, (front_length / 2), holder_height - (holder_height - front_height) / 2])
      //      rotate([wall_rotation, 0, 0])
      //        translate([0, -total_length / 2, 0])
      //          cube([wall_width, total_length, holder_height]);

      if (windows) {
        window_z = front_height;
        // window for the back
        translate([0, front_length + wall_width + ((back_length - window_width) / 2), window_z])
          window(window_width);

        // space for windows at front
        window_space = front_length - window_side_edges;
        // how many windows we can fit in the space
        window_count = floor((front_length - window_side_edges) / (window_width + window_side_edges));
        // consistent gap between the windows
        window_gap = (front_length - (window_count * window_width)) / (window_count + 1);

        // windows for the front area
        for (i = [1:(window_count)]) {
          start_point = (window_gap * i) + (window_width * (i - 1));
          translate([0, start_point, window_z])
            window();
        }
      }
    }
  }

  module join_wall()
  {
    // join wall goes half way into the side walls
    join_wall_width = inner_width + wall_width;

    cutout_radius_width = (inner_width / 2) - (extra_space * 1.25);
    cutout_radius = min(
      cutout_radius_width,
      holder_height - floor_depth - (wall_width * 2)
    );

    x_scale = cutout_radius_width / cutout_radius;

    difference() {
      cube([join_wall_width, wall_width, holder_height]);

      translate([join_wall_width / 2, wall_width, holder_height])
        rotate([90, 0, 0])
          scale([x_scale, 1, 1])
            cylinder(wall_width, cutout_radius, cutout_radius);
    }
  }

  module squished_window(start_point)
  {
    radius = rounding;

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

  module window(width = window_width)
  {
    window_height = holder_height - front_height - (wall_width * 2);
    rotate([90, 0, 90])
      difference() {
        rounded_cube([
          width,
          window_height,
          wall_width
        ]);
        offset = width / 2;
        translate([0, window_height - offset, 0])
          rotate([0, 0, 45])
            cube([width, width, wall_width]);

        translate([width / 2, window_height, 0])
          rotate([0, 0, -45])
            cube([width, width, wall_width]);
      }
  }

  module rounded_cube(size = [10, 10, 10], radius = rounding)
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

  module fill_in_corner(h, x, length, xpos = true)
  {
    touch_point_x = (sin(asin(x / h)) * (h - rounding));

    fx = xpos ? x - touch_point_x : touch_point_x - x;
    difference() {
      translate([-rounding, -length, 0])
        cube([fx + rounding, length, front_height]);
      cylinder(front_height, rounding, rounding);
    }
  }

  module inner_rounding()
  {
    difference() {
      square([half_wall, half_wall]);
      translate([half_wall, half_wall, 0]) circle(half_wall);
    }
  }
}
