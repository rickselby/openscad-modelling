// Other things you may want to change

wall_width = 2.4;
floor_depth = wall_width;
front_height = floor_depth * 3;
// corner rounding on cutouts
rounding = wall_width;
// mm to add to card width/height / deck height
extra_space = 5;

$fs = $preview ? 1 : 0.1;  // Don't generate smaller facets than 0.1 mm
$fa = $preview ? 15 : 2;    // Don't generate larger angles than 5 degrees

////////////////////////////////////////////

// misbehaves = 63 x 89 x 30
// nav = 63 x 89 x 20
// supply = 63 x 89 x 15
// contact = 89 x 63 x 15

// build it!
holder(89, 63, 5);
//translate([80, 0, 0]) holder(63, 89, 20);
//translate([160, 0, 0]) holder(63, 89, 15);
//translate([240, 0, 0]) holder(89, 63, 15);

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
  total_length = back_length + (wall_width * 2);

  front_lip_height = floor_depth + (wall_width * 2);

  // build the actual holder
  translate([half_wall, 0, 0]) base();
  side_wall();
  translate([total_width - wall_width, 0, 0]) side_wall();
  translate([half_wall, 0, 0]) front_lip();
  translate([half_wall, total_length - wall_width, 0]) join_wall();

  // rounding between walls

  // back and join wall
  translate([wall_width, wall_width, 0])
    linear_extrude(front_lip_height) inner_rounding();

  translate([total_width - wall_width, wall_width, 0])
    rotate([0, 0, 90]) linear_extrude(front_lip_height) inner_rounding();

  // back and back wall
  translate([wall_width, total_length - wall_width, 0])
    rotate([0, 0, -90]) linear_extrude(holder_height) inner_rounding();

  translate([total_width - wall_width, total_length - wall_width, 0])
    rotate([0, 0, 180]) linear_extrude(holder_height) inner_rounding();

  module base()
  {
    // base goes halfway into each wall
    base_width = inner_width + wall_width;

    cutouts = 3;
    cutout_width = (inner_width - (extra_space * (cutouts + 1))) / cutouts;
    cutout_x = [for (a = [1 : cutouts]) half_wall + (extra_space * a) + (cutout_width * (a - 1))];

    translate([0, wall_width, 0])
      difference() {
        cube([base_width, back_length, floor_depth]);

        for (x = cutout_x)
          translate([x, 0, 0])
            rounded_cube([cutout_width, back_length, floor_depth]);
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

      // round the front corner of the wall
      wall_rounding = min((holder_height) / 2, back_length + wall_width);
      translate([0, wall_rounding, holder_height - wall_rounding])
        rotate([180, -90, 0])
          difference() {
            cube([wall_rounding + 1, wall_rounding + 1, wall_width]);
            cylinder(wall_width, wall_rounding, wall_rounding);
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

  module front_lip()
  {
    cube([inner_width + wall_width, wall_width, front_lip_height]);
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
