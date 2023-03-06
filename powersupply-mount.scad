
include <BOSL2/std.scad>;
include <BOSL2/metric_screws.scad>;
include <BOSL2/screws.scad>;

print_psu = false;;

wall_width = 3;
tolerance = .25;
overlap = 1;
PSU_Type = "RACM90";
//PSU_Type = "MW_LRS150_12";
//PSU_Type = "RACM90";

MW_RS15_psu_size = [63.1, 51.3, 28.5];
MW_RS15_screw_height = [16, 16];
MW_RS15_screw_distance = 39.25;
MW_RS15_screw_distance_from_back = 12;

MW_LRS50_psu_size = [99, 83, 30];
MW_LRS50_screw_height = [15, 15];
MW_LRS50_screw_distance = 74;
MW_LRS50_screw_distance_from_back = 15;

MW_LRS100_psu_size = [129, 97, 30];
MW_LRS100_screw_height = [15, 6, 18];
MW_LRS100_screw_distance = 77;
MW_LRS100_screw_distance_from_back = 20;

MW_LRS150_psu_size = [159, 97, 30];
MW_LRS150_screw_height = [15, 6, 18];
MW_LRS150_screw_distance = 117;
MW_LRS150_screw_distance_from_back = 20;

RACM90_psu_size = [110.9, 64, 38.7];
RACM90_screw_distance = 44.5;

mount_height = 4;
pcb_thickness = 1.6;
top_anchor_overhang = 2;

plate_size=[120, 70, 4];
//cuboid(plate_size, anchor=BOTTOM) attach(TOP, overlap=overlap) RACM90_psu_mount();
//cuboid([MW_LRS50_psu_size.x+10, MW_LRS50_psu_size.y+10, 2], anchor=BOTTOM) attach(TOP, overlap=overlap) MW_LRS50_psu_mount();

module RACM90_psu_mount() {
  for (x = [-1,1]) {
    translate([RACM90_psu_size.x/2 * x, 0]) cuboid([5, RACM90_psu_size.y, mount_height+overlap], anchor=BOTTOM) {
      for (y = [0,-1,1]) {
	attach(TOP, overlap=overlap) translate([0,RACM90_screw_distance/2*y]) screw("M3", length=6, anchor=BOTTOM); 
      }
    }
  }
}

module MW_RS15_psu_mount() {
  psu_mount(MW_RS15_psu_size, MW_RS15_screw_height, MW_RS15_screw_distance, MW_RS15_screw_distance_from_back);
}

module MW_LRS50_psu_mount() {
  psu_mount(MW_LRS50_psu_size, MW_LRS50_screw_height, MW_LRS50_screw_distance, MW_LRS50_screw_distance_from_back);
}

module MW_LRS100_psu_mount() {
  psu_mount(MW_LRS100_psu_size, MW_LRS100_screw_height, MW_LRS100_screw_distance, MW_LRS100_screw_distance_from_back);
}

module MW_LRS150_psu_mount() {
  psu_mount(MW_LRS150_psu_size, MW_LRS150_screw_height, MW_LRS150_screw_distance, MW_LRS150_screw_distance_from_back);
}


module psu_mount(psu_size, screw_height, screw_distance, screw_distance_from_back) {
  diff("screwholes") {
    // lengthwise base mounts
    back(psu_size.y / 2 + wall_width / 2 + tolerance) {
      cuboid([psu_size.x+tolerance*2, wall_width, mount_height+overlap], anchor=BOTTOM);
      right(psu_size.x / 2 - screw_distance_from_back) { 
	// top anchor bracket
	cuboid([8, wall_width, psu_size.z+overlap+overlap], anchor=BOTTOM);
	up(psu_size.z+overlap+tolerance) fwd((top_anchor_overhang)/2) cuboid([8, wall_width+top_anchor_overhang,  wall_width], anchor=BOTTOM);
      }
    }
    fwd(psu_size.y / 2 + wall_width / 2 + tolerance) {
      cuboid([psu_size.x+tolerance*2, wall_width, mount_height+overlap], anchor=BOTTOM);

      // screw hole mount posts
      right(psu_size.x / 2 - screw_distance_from_back) {
	cuboid([8, wall_width, psu_size.z+overlap], anchor=BOTTOM) 
	  tag("screwholes") 
	    attach([FRONT], overlap=-overlap) 
	      fwd(psu_size.z / 2 - overlap) { 
		back(screw_height[1]) cylinder(r=1.5+tolerance, h=wall_width+2*overlap, $fn=45, anchor=TOP);
		if (len(screw_height) == 3) {
		  back(screw_height[2]) cylinder(r=1.5+tolerance, h=wall_width+2*overlap, $fn=45, anchor=TOP);
		}
	      }

	left(screw_distance) {
	  cuboid([8, wall_width, screw_height[0]+4], anchor=BOTTOM)
	    tag("screwholes") 
	      attach([FRONT], overlap=-overlap)
	      fwd((screw_height[0]+4)/ 2 - overlap) 
	        back(screw_height[0]) cylinder(r=1.5+tolerance, h=wall_width+2*overlap, $fn=45, anchor=TOP);

	  if (print_psu) color("lightgreen") fwd(1.8) cuboid([.1, .1, screw_height[0]], anchor=BOTTOM);
	}
      }
    }

    // back base mount
    right(psu_size.x / 2 + wall_width / 2 + tolerance) {
      cuboid([wall_width, psu_size.y+wall_width*2+tolerance*2, mount_height+overlap], anchor=BOTTOM)
        if (print_psu) attach([LEFT]) {
	  color("red") right(psu_size.y/2 + wall_width + .5) back(screw_height - mount_height/2) up(tolerance) cuboid([8,.1,12], anchor=BOTTOM);
	  color("lightblue") right(psu_size.y/2 + wall_width + .4) back(screw_height - mount_height/2) up(tolerance) cuboid([.1,.1,12+screw_distance], anchor=BOTTOM);
	}
    }

    if (print_psu) {
      color("lightgreen") cuboid(psu_size, anchor=BOTTOM);
    }
  }
}
