holesize=4;				// Size of holes in walls, in mm
holespace=1.5;			//	Spacing between holes, in mm
thickness=1.5;			// Thickness of walls, in mm
lipThickness = 0.8;	// Thickness of wall at lip, in mm (adjust for nozzle)
gap=0.3;					// Gap around lip for lid to slide in
lidSpacing = 10;		// Spacing between box and lid

//		[80, [60,80]],	// Width of row, followed by lengths of sections
//		[60, [30,58.5,50]]

tray(
	[
		[80, [80]],	// Width of row, followed by lengths of sections
	],			
	25			// Height of Tray
);

/****************************************
 * Put together boxes into a tray
 ****************************************/
module tray(sizes, height)
{
	fullLength = sumVector(sizes[0][1], len(sizes[0][1])-1) + (thickness * (len(sizes[0][1])+1));
	fullWidth = sumWidths(sizes, len(sizes)-1) + (thickness * (len(sizes) + 1));

	// Move the design so it is around centre
	translate([-fullLength/2, 0, 0]) {

		// Move the box so the whole design is around the centre
		translate([0, -fullWidth-(lidSpacing/2), 0]) {

			for(j=[0:(len(sizes)-1)])
			{
				for(i=[0:(len(sizes[j][1])-1)])
				{
					translate([sumVector(sizes[j][1], (i-1)) + (thickness * i),
									sumWidths(sizes, j-1) + (thickness * j),
									0])
						box(sizes[j][1][i], sizes[j][0], height);
				}
				if (j==0)
				{
					echo("first row");
					singleWalls(sizes[j][1], height, sumWidths(sizes, j-1) + (thickness * j));
				} else {
					echo("middle line");
					multiWalls(sizes[j-1][1], sizes[j][1], height, sumWidths(sizes, j-1) + (thickness * j));
				}

				if (j==(len(sizes)-1))
				{
					echo("last row");
					singleWalls(sizes[j][1], height, sumWidths(sizes, j) + (thickness * (j+1)));
				}
			}

			// Add the lip for the lid
			translate([0,0,height+thickness])
				lidLip(fullLength, fullWidth, height);
		}

		// Move the lid so the whole design is around the centre
		translate([0, (lidSpacing/2), 0]) {
			lid(
				fullLength - (lipThickness + gap),
				fullWidth - ((lipThickness + gap) * 2),
				thickness
			);
		}
		echo("Lip Thickness:", lipThickness);
		echo("Wall Thickness:", thickness);
		echo("Gap:", gap);

	}
}

function sumVector(v, i) = (i < 0 ? 0 : (i == 0 ? v[i] : v[i] + sumVector(v, i-1)));

function sumWidths(v, i) = (i < 0 ? 0 : (i == 0 ? v[i][0] : v[i][0] + sumWidths(v, i-1)));

//function makeVectorTotal(v, i, o=[]) =
//	(i < 0 ? 0 : 

module singleWalls(lengths, height, yOffset)
{
	for(i=[0:(len(lengths)-1)])
	{
		echo(lengths[i], height, yOffset);

		translate([sumVector(lengths, (i-1)) + (thickness * i)
						, yOffset + thickness, 0])
			rotate([90,0,0]) 
		wall(lengths[i], height, thickness, [thickness, thickness, thickness, 0]);

/*					translate([sumVector(sizes[j][1], (i-1)) + (thickness * i),
									sumWidths(sizes, j-1) + (thickness * j),
									0])
*/
	}

}


/****************************************
 * Generate the lid
 ****************************************/
module lid(length, width, thickness)
{
	border = thickness - lipThickness;
	// Half thickness borders around 
	wall(
		length - (border + thickness), 	// full thickness border at front only
		width - (border * 2), 
		thickness, 
		[thickness, border, border, border]
	);

	echo("Lid Length / Width:", length, width);

	translate([thickness + (holespace * 0.5), width * 0.25, thickness*3/4]) {
		lidBump();
		translate([0, width * 0.5, 0]) {
			lidBump();
		}
	}
}

module lidBump()
{
	sphere(r=(thickness*3/4),$fa=5, $fs=0.1);
}

/****************************************
 * Add a lip to take a lid
 ****************************************/
module lidLip(length, width, height)
{
	echo("Lip Length / Width:", length, width);
	lipHeight = thickness + (gap * 2);

	threeSides(length, width, lipThickness, lipHeight);

	// Regular-thickness lip on top
	translate([0,0,lipHeight])
	{
		threeSides(length, width, thickness, thickness);
	}
}

module threeSides(length, width, thickness, height)
{
	cube([length, thickness, height]);
	translate([length-thickness, 0, 0])
		cube([thickness, width, height]);
	translate([0, width-thickness, 0])
		cube([length, thickness, height]);
}


/****************************************
 * Put together walls to make a single box
 ****************************************/
module box(width, depth, height, yAxisWalls)
{
	// Base
	wall(width, depth, thickness, [thickness, thickness, thickness, thickness]);

	// Walls on y axis
	for (x=[thickness, width+(thickness*2)]) {
		translate([x, 0, 0]) {
			rotate([0,-90,0]) {
				wall(height, depth, thickness, [thickness, thickness, 0, thickness]);
			}
		}
	}

	// Walls on x axis
/*	for (y=[thickness, depth+(thickness*2)]) {
		translate([0, y, 0]) {
			rotate([90,0,0]) {
				wall(width, height, thickness, [thickness, thickness, thickness, 0]);
			}
		}
	}
*/

	// Curves
	translate([thickness, thickness, thickness])
		curve(depth);

	translate([thickness+width, thickness+depth, thickness])
		rotate([0,0,180])
			curve(depth);

	translate([thickness+width, thickness, thickness])
		rotate([0,0,90])
			curve(width);

	translate([thickness, thickness+depth, thickness])
		rotate([0,0,270])
			curve(width);

}

/****************************************
 * Create a wall with holes in it, evenly spaced
 ****************************************/
module wall(width, depth, height, border=[0,0,0,0])
{
	holewidth=width-(holespace*2);
	holedepth=depth-(holespace*2);

	holesWide = floor((holewidth+holespace)/(holesize+holespace));
	holesDeep = floor((holedepth+holespace)/(holesize+holespace));

	widthOffset = (width-(holesize*holesWide)-(holespace*(holesWide-1)))/2;
	depthOffset = (depth-(holesize*holesDeep)-(holespace*(holesDeep-1)))/2;

	difference() {

		cube([width + border[0] + border[2], depth + border[1] + border[3], height]);

		// Only take out holes if we need to
		if (holesWide > 0 && holesDeep > 0)
		{
			for(i=[1:holesWide])
			{
				for(j=[1:holesDeep])
				{
					translate([
						widthOffset + ((holespace+holesize) * (i-1)) + border[0],
						depthOffset + ((holespace+holesize) * (j-1)) + border[1],
						-0.1])
					cube([holesize, holesize, height+0.2]);
				}
			}
		}
	}
}

module curve(length)
{
	difference()
	{
		translate([-0.1,0,-0.1])
			cube([holespace+0.1, length, holespace+0.1]);
		translate([holespace, -0.1, holespace])
			rotate([-90,0,0])
				cylinder(h=length+0.2, r=holespace, $fa=5, $fs=0.1);
	}
}


function sumVector(v, i) = (i < 0 ? 0 : (i == 0 ? v[i] : v[i] + sumVector(v, i-1)));

function makeVectorTotal(v, i=0) = 
	(i == len(v) ? [] : concat(sumVector(v, i), makeVectorTotal(v, i+1)));

