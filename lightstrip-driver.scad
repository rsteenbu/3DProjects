include <BOSL2/std.scad>;
include <BOSL2/metric_screws.scad>;
include <powersupply-mount.scad>;
include <box-connectors.scad>;
include <pcb-mount.scad>;
include <my-general-libraries.scad>;
include <enclosure-faceplate.scad>;

arduino_inside = true;
use_mounting_tabs = true;
print_pcb = false;
print_enclosure = false;
print_faceplate = true;
// 15w, 50w, 100w, 150w, RACM90
psu_type = "50w";
relay_type = "pcb";

wall_width = 2;
overlap = 1;
post_hole_size = 1.8;
tolerance = .15;
lip_width = 3;
lip_height = 2;
pcb_height=6;
// LCD, PIR, LCD+PIR, NONE
enclosure_stuff = "LCD+PIR";

faceplate_component_margin=10.5;
connector_pos_from_edge = 13;
//faceplate_depth = 14;
faceplate_depth = 18;

  //if (print_enclosure) lcd2_16_enclosure([x,55,20]); 
//  translate([0,140]) yrot(180) backplate_screwholes(faceplate_depth - 4);
if (psu_type == "RACM90") {
  enclosure_size = [145, 180, 35];
  ydistribute(spacing=220) {
    if (print_enclosure)  backplate(enclosure_size); 
    if (print_faceplate)  faceplate([enclosure_size.x, enclosure_size.y, faceplate_depth]);
  }
}
if (psu_type == "15w") {
  enclosure_size = [100, 180, 30];
  ydistribute(spacing=220) {
    if (print_enclosure)  backplate(enclosure_size); 
    if (print_faceplate)  faceplate([enclosure_size.x, enclosure_size.y, faceplate_depth]);
  }
}
if (psu_type == "50w") {
  if (relay_type == "pcb") {
    enclosure_size = [145, 180, 35];
    ydistribute(spacing=220) {
      if (print_enclosure)  backplate(enclosure_size); 
      if (print_faceplate)  faceplate([enclosure_size.x, enclosure_size.y, faceplate_depth]);
    }
  } else {
    enclosure_size = [145, 180, 35];
    ydistribute(spacing=220) {
      if (print_enclosure)  backplate(enclosure_size); 
      if (print_faceplate)  faceplate([enclosure_size.x, enclosure_size.y, faceplate_depth]);
    }
  }
}
if (psu_type == "50w-2") {
  enclosure_size = [160, 180, 35];
  ydistribute(spacing=220) {
    if (print_enclosure)  backplate(enclosure_size); 
    if (print_faceplate)  faceplate([enclosure_size.x, enclosure_size.y, faceplate_depth]);
  }
}
if (psu_type == "100w") {
  enclosure_size = [175, 200, 35];
  ydistribute(spacing=70) {
    if (print_enclosure)  backplate(enclosure_size); 
    if (print_faceplate)  yrot(0) faceplate([enclosure_size.x, enclosure_size.y, faceplate_depth]);
  }
}
if (psu_type == "150w") {
  enclosure_size = [175, 210, 35];
  ydistribute(spacing=220) {
    if (print_enclosure)  backplate(enclosure_size); 
    if (print_faceplate)  faceplate([enclosure_size.x, enclosure_size.y, faceplate_depth]);
  }
}
//  xrot(180) inside_space([enclosure_size.x-wall_width*2, enclosure_size.y-wall_width*2, faceplate_depth-5]);

module mounting_tabs(mounting_hole_distance_apart) {
  for(x = [1, -1]) {
    move([(mounting_hole_distance_apart / 2) * x, 0, -2])
      diff("screwhole") prismoidal([16,wall_width,14],BOTTOM)
          attach([FRONT], overlap=3) back(1) tag("screwhole") cylinder(h=5, r=2.2, anchor=BOTTOM, $fn=45);
  }
}

module backplate(size) {
   inner_lip_height = size.z + lip_height - tolerance + overlap;
   screwpost_size = 7;
   
   diff("holes") cuboid([size.x, size.y, wall_width], anchor=BOTTOM) {
      attach([LEFT], overlap=1) 
	if (use_mounting_tabs) mounting_tabs(size.x - 40);
      attach([RIGHT], overlap=1) 
	if (use_mounting_tabs) mounting_tabs(size.x - 40);

      attach([TOP], overlap=overlap) {
	// outer lip
	back(size.y / 2 - (wall_width + tolerance)/2) cuboid([size.x, wall_width+tolerance, size.z+overlap], anchor=BOTTOM)
	   if (psu_type == "100w" )
	     attach(FRONT, overlap=4) {
	       tag("holes") { 
		 translate([size.x/2-35, 0, -2]) { 
		   c14_plug_v2([27,19,9]);
		   left(40) cylinder(h=9, r=6.25, anchor=BOTTOM);
		 }
	       }
	     }

	fwd(size.y / 2 - (wall_width + tolerance)/2) cuboid([size.x, wall_width+tolerance, size.z+overlap], anchor=BOTTOM) {
	    if (psu_type == "50w" || psu_type == "100w")
	      attach(BACK, overlap=.5) {
		translate([size.y/2 - 33, 6, 0]) connector(3_pin_connector_size, anchor=FRONT);
		translate([size.y/2 - 53, 6, 0]) connector(3_pin_connector_size, anchor=FRONT);
	      }
	    attach(BACK, overlap=.5) {
	      if ( psu_type == "15w" && arduino_inside ) {
		tag("holes") { 
		  translate([size.x/2-25, -2, 0]) nema5_15R_female(wall_width*2);
		  translate([-5, 0, -2]) cylinder(h=5, r=7.75, anchor=BOTTOM, $fn=45);
		}

		letter_extrude=2.7;
		connector_xpos = -size.x/2 + 25;
		translate([connector_xpos, 10]) yrot(180) linear_extrude(letter_extrude) text("1", size=4, anchor=FRONT);
		translate([connector_xpos, 0]) connector(2_pin_connector_size, anchor=FRONT);

		translate([connector_xpos-10, 10]) yrot(180) linear_extrude(letter_extrude) text("2", size=4, anchor=FRONT);
		translate([connector_xpos-10, 0]) connector(2_pin_connector_size, anchor=FRONT);

		translate([connector_xpos, -9]) connector(2_pin_connector_size, anchor=FRONT);
		translate([connector_xpos, -12]) yrot(180) linear_extrude(letter_extrude) text("3", size=4, anchor=FRONT);

		translate([connector_xpos-10, -9]) connector(2_pin_connector_size, anchor=FRONT);
		translate([connector_xpos-10, -12]) yrot(180) linear_extrude(letter_extrude) text("4", size=4, anchor=FRONT);
	      }
	    }
	  }

	left(size.x / 2 - (wall_width + tolerance)/2) cuboid([wall_width+tolerance, size.y, size.z+overlap], anchor=BOTTOM) {

	  if (psu_type == "50w" || psu_type == "RACM90")
	    attach(RIGHT, overlap=2)
	      tag("holes") {
		if (psu_type == "RACM90") { translate([(-size.y/2) + 33 , 0, -2]) c14_plug_v2([27,19,7]); }
		else { translate([size.y/2-33, 0, -2]) c14_plug_v2([27,19,7]); }
	      }
	}

 
	right(size.x / 2 - (wall_width + tolerance)/2) cuboid([wall_width+tolerance, size.y, size.z+overlap], anchor=BOTTOM) {
	    if (psu_type == "50w")
	      attach(LEFT, overlap=.5)
		translate([size.y/2 - 23, 6, 0]) connector(3_pin_connector_size, anchor=FRONT);
	}

	// inner lip
	back(size.y / 2 + wall_width/2 - (wall_width*2 + tolerance)) cuboid([size.x - 2*(wall_width + tolerance), wall_width, inner_lip_height], anchor=BOTTOM);
	fwd (size.y / 2 + wall_width/2 - (wall_width*2 + tolerance)) cuboid([size.x - 2*(wall_width + tolerance), wall_width, inner_lip_height], anchor=BOTTOM);
	left(size.x / 2 + wall_width/2 - (wall_width*2 + tolerance)) cuboid([wall_width, size.y - 2*(wall_width+tolerance), inner_lip_height], anchor=BOTTOM);
	right(size.x / 2 + wall_width/2 - (wall_width*2 + tolerance)) cuboid([wall_width, size.y - 2*(wall_width+tolerance), inner_lip_height], anchor=BOTTOM);

	// Screwposts
	screwhole_xpos = size.x / 2 - (wall_width+tolerance) - screwpost_size / 2;
	screwhole_ypos = size.y / 2 - (wall_width+tolerance) - screwpost_size / 2;
	for(x = [1, -1]) {
	  for(y = [1, -1]) {
	    move([screwhole_xpos * x, screwhole_ypos  * y, 0]) cuboid([screwpost_size,screwpost_size,inner_lip_height], anchor=BOTTOM);
	  }
	}

	if (arduino_inside) {
	  // PCB mounts for arduino
	  if (psu_type == "RACM90") {
	    translate([size.x/2 - 15, size.y/2 - 14]) {
	      translate([-RACM90_psu_size.x/2, -RACM90_psu_size.y/2]) RACM90_psu_mount();
	      fwd(RACM90_psu_size.y + 10) {
		translate([-70x50_pcb_size.x/2, -70x50_pcb_size.y/2]) 
		  pcb_mounts(70x50_pcb_size, 70x50_hole_distance, 70x50_hole_diameter);
		left(70x50_pcb_size.x + 5)
		  translate([-70x50_pcb_size.x/2, -70x50_pcb_size.y/2]) 
		    pcb_mounts(70x50_pcb_size, 70x50_hole_distance, 70x50_hole_diameter);
	      }
	    }
	  }

	  if (psu_type == "15w") {
	    back(44) translate([-size.x/2+6, -size.y/2+6]) {
	      translate([+MW_RS15_psu_size.y/2, MW_RS15_psu_size.x/2]) zrot(90) MW_RS15_psu_mount();
	      right(MW_RS15_psu_size.y + 6)
		translate([beefcake_relay_pcb_size.x/2, beefcake_relay_pcb_size.y/2]) 
		pcb_mounts(beefcake_relay_pcb_size, beefcake_relay_hole_distance, beefcake_relay_hole_diameter);
	      back(MW_RS15_psu_size.x + 10) 
		translate([70x50_pcb_size.y/2+10, 70x50_pcb_size.x/2]) 
		zrot(90) pcb_mounts(70x50_pcb_size, 70x50_hole_distance, 70x50_hole_diameter);
	    }
	  }

	  if (psu_type == "50w") {
	    if (relay_type == "pcb") {
	      translate([size.x/2 - 10, size.y/2 - 6]) {
		translate([-MW_LRS50_psu_size.x/2, -MW_LRS50_psu_size.y/2]) MW_LRS50_psu_mount();
		fwd(MW_LRS50_psu_size.y + 10) {
		  translate([-70x50_pcb_size.x/2, -70x50_pcb_size.y/2]) 
		    pcb_mounts(70x50_pcb_size, 70x50_hole_distance, 70x50_hole_diameter);
		  left(70x50_pcb_size.x + 10)
		    translate([-70x50_pcb_size.x/2, -70x50_pcb_size.y/2]) 
		    pcb_mounts(70x50_pcb_size, 70x50_hole_distance, 70x50_hole_diameter);
		}
	      }
	    } else { 
	      translate([size.x/2 - 10, size.y/2 - 6]) {
		translate([-MW_LRS50_psu_size.x/2, -MW_LRS50_psu_size.y/2]) MW_LRS50_psu_mount();
		fwd(MW_LRS50_psu_size.y + 10) {
		  translate([-70x50_pcb_size.x/2, -70x50_pcb_size.y/2]) 
		    pcb_mounts(70x50_pcb_size, 70x50_hole_distance, 70x50_hole_diameter);
		  left(70x50_pcb_size.x + 30)
		    translate([-beefcake_relay_pcb_size.x/2, -beefcake_relay_pcb_size.y/2]) 
		    pcb_mounts(beefcake_relay_pcb_size, beefcake_relay_hole_distance, beefcake_relay_hole_diameter);
		}
	      }
	    }
	  }

	  if (psu_type == "50w-2") {
	    translate([size.x/2 - 10, size.y/2 - 6]) {
	      translate([-MW_LRS50_psu_size.x/2, -MW_LRS50_psu_size.y/2]) MW_LRS50_psu_mount();
	      fwd(MW_LRS50_psu_size.y + 10) {
		translate([-70x50_pcb_size.x/2, -70x50_pcb_size.y/2]) 
		  pcb_mounts(70x50_pcb_size, 70x50_hole_distance, 70x50_hole_diameter);
		left(70x50_pcb_size.x + 5)
		  translate([-70x50_pcb_size.x/2, -70x50_pcb_size.y/2]) 
		    pcb_mounts(70x50_pcb_size, 70x50_hole_distance, 70x50_hole_diameter);
		left(70x50_pcb_size.x*2 + 10)
		  translate([-beefcake_relay_pcb_size.x/2, -beefcake_relay_pcb_size.y/2]) 
		  pcb_mounts(beefcake_relay_pcb_size, beefcake_relay_hole_distance, beefcake_relay_hole_diameter);
	      }
	    }
	  }

	  if (psu_type == "100w") {
	    translate([size.x/2 - 6, -size.y/2 + 15]) {
	      translate([-MW_LRS100_psu_size.y/2, MW_LRS100_psu_size.x/2]) zrot(270) 
		MW_LRS100_psu_mount();

	      left(MW_LRS100_psu_size.y + 10) {
		translate([-70x50_pcb_size.x/2, 70x50_pcb_size.y/2]) 
		  pcb_mounts(70x50_pcb_size, 70x50_hole_distance, 70x50_hole_diameter);
		back(70x50_pcb_size.y+10) {
		  if (relay_type == "pcb") {
		    translate([-70x50_pcb_size.x/2, 70x50_pcb_size.y/2]) 
		      pcb_mounts(70x50_pcb_size, 70x50_hole_distance, 70x50_hole_diameter);
		  } else {
		    translate([-beefcake_relay_pcb_size.x/2, beefcake_relay_pcb_size.y/2]) 
		      pcb_mounts(beefcake_relay_pcb_size, beefcake_relay_hole_distance, beefcake_relay_hole_diameter, .5);
		  }
		}
	      }
	    }
	  }

	  if (psu_type == "150w") {
	    translate([size.x/2 - 6, -size.y/2 + 15]) {
	      translate([-MW_LRS150_psu_size.y/2, MW_LRS150_psu_size.x/2]) zrot(270) 
		MW_LRS150_psu_mount();

	      left(MW_LRS150_psu_size.y + 10) {
		translate([-70x50_pcb_size.x/2, 70x50_pcb_size.y/2]) 
		  pcb_mounts(70x50_pcb_size, 70x50_hole_distance, 70x50_hole_diameter);
		back(70x50_pcb_size.y+10) {
		  translate([-beefcake_relay_pcb_size.x/2, beefcake_relay_pcb_size.y/2]) 
		    pcb_mounts(beefcake_relay_pcb_size, beefcake_relay_hole_distance, beefcake_relay_hole_diameter, .5);
		}
	      }
	    }
	  }
	} //arduino inside
      } //attach

	attach([BOTTOM]) {
	  tag("holes") {
	    head_hole_size = 3.1;
	    screwhole_xpos = size.x / 2 - wall_width * 2 - 1;
	    screwhole_ypos = size.y / 2 - wall_width * 2 - 1;
	    for(x = [1, -1]) {
	      for(y = [1, -1]) {
		translate([screwhole_xpos * x, screwhole_ypos * y, -(inner_lip_height + 3)]) cylinder(h=15, r=post_hole_size, anchor=BOTTOM, $fn=45);
		translate([screwhole_xpos * x, screwhole_ypos * y, 1]) cylinder(h=size.z+1, r=head_hole_size, anchor=TOP, $fn=45);
	      }
	    }
	  }
      }
  }
}

