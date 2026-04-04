spacing = 19.15;
diameter = 1;
halfDia = diameter/2;
grid=5;

translate([-spacing*(grid/2), -spacing*(grid/2), 0])
{
	for (x=[0:(grid-1)]) {
		for (y=[0:(grid-1)])	{
			translate([spacing*x, spacing*y, 0])
				square();
		}
	}
}

module square() {

	difference() {
		cube([spacing+diameter, spacing+diameter, diameter]);
		translate([diameter,diameter,-0.1])
			cube([spacing-diameter, spacing-diameter, diameter + 0.2]);
	}

}