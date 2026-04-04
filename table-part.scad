// Piece measurements

full_length = 19.6;
full_width = 9.3;
full_height = 4;
indent_bottom_length = 4.5;
indent_bottom_width = 3.2;
indent_top_width = 7.0;

// Calculations

bottom_edge = (full_width - indent_bottom_width) / 2;
echo(bottom_edge);
offset = (full_length / 2) - (bottom_edge) - (indent_bottom_length / 2);

$fn = $preview ? 32 : 32;

difference() {
  long_cylinder(full_length, full_width, full_height);

  translate([-offset, 0, 0]) {
    indent();
  }
  translate([offset, 0, 0]) {
    indent();
  }
}

module indent()
{
  each_height = (full_height / 2);

  union() {
    long_cylinder(indent_bottom_length, indent_bottom_width, each_height);
    translate([0, 0, 2]) {
      long_flared_cylinder(indent_bottom_length, indent_bottom_width, indent_top_width, each_height);
    }
  }
}

module long_cylinder(length, width, height)
{
  long_flared_cylinder(length, width, width, height);
}

module long_flared_cylinder(length, width_bottom, width_top, height)
{
  radius_bottom = width_bottom / 2;
  radius_top = width_top / 2;
  cube_length = length - width_bottom;

  union() {
    translate([length / 2 - radius_bottom, 0, 0]) {
      cylinder(height, radius_bottom, radius_top);
    }

    translate([-(length / 2 - radius_bottom), 0, 0]) {
      union() {
        cylinder(height, radius_bottom, radius_top);
        translate([0, -radius_bottom, 0]) {
          trapezoid(cube_length, width_bottom, width_top, height);
        }
      }
    }
  }
}

module trapezoid(length, width_bottom, width_top, height)
{
  diff = width_top - width_bottom;
  offset = diff / 2;

  points = [
    [0, 0, 0],
    [length, 0, 0],
    [length, width_bottom, 0],
    [0, width_bottom, 0],
    [0, -offset, height],
    [length, -offset, height],
    [length, width_top - offset, height],
    [0, width_top - offset, height]
  ];
  faces = [
    [0,1,2,3],
    [4,5,1,0],
    [7,6,5,4],
    [5,6,2,1],
    [6,7,3,2],
    [7,4,0,3]
  ];
  polyhedron(points, faces);
}
