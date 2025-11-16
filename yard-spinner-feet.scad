foot_insert_height=3;
foot_insert_depth=3;
foot_height=3;
overlap = .1;

translate([0, 0, foot_height/2]) 
	cylinder(foot_height, d=35, center=true, $fn=100);


translate([0, 0, foot_height-overlap + foot_insert_height/2]) 
	difference() {
	  cylinder(foot_insert_height, d=26.5, center=true, $fn=100);
	  translate([0,0,-overlap]) cylinder(foot_insert_height+(overlap*3), d=26.5 - foot_insert_depth, center=true, $fn=100);
	}
