include <BOSL2/std.scad>;
include <BOSL2/metric_screws.scad>;
include <powersupply-mount.scad>;
include <box-connectors.scad>;
include <pcb-mount.scad>;
include <my-general-libraries.scad>;
//include <enclosure-faceplate.scad>;

arduino_inside = true;
use_mounting_tabs = true;
use_outdoor_connectors = true;
print_pcb = false;
print_enclosure = true;
print_faceplate = true;
// 15w, 50w, 50w-2, 100w, 150w, RACM90, 200w, none, wasatch
enclosure_type = "wasatch";
relay_type = "pcb";
led_connector = "JST";

wall_width = 2;
overlap = 1;
post_hole_size = 1.8;
tolerance = .15;
lip_width = 3;
lip_height = 2;
pcb_height=6.0;
lcd_enabled = false;
pir_enabled = false;
encoder_enabled = false;
vents_enabled = true;
screwhead_faceplate = false;

// faceplate stuff
face_depth=5;
screwpost_diameter = 5;
screwpost_hole_size = 1.8;

faceplate_component_margin=10.5;
connector_pos_from_edge = 13;
faceplate_depth = 18;

  //if (print_enclosure) lcd2_16_enclosure([x,55,20]); 
//  translate([0,140]) yrot(180) backplate_screwholes(faceplate_depth - 4);
if (enclosure_type == "none") {
  enclosure_size = [100, 100, 30];
  ydistribute(spacing=220) {
    if (print_enclosure)  backplate(enclosure_size); 
    if (print_faceplate)  faceplate([enclosure_size.x, enclosure_size.y, faceplate_depth]);
  }
}
if (enclosure_type == "RACM90") {
  enclosure_size = [145, 180, 35];
  ydistribute(spacing=220) {
    if (print_enclosure)  backplate(enclosure_size); 
    if (print_faceplate)  faceplate([enclosure_size.x, enclosure_size.y, faceplate_depth]);
  }
}
if (enclosure_type == "15w") {
  enclosure_size = [100, 180, 30];
  ydistribute(spacing=220) {
    if (print_enclosure)  backplate(enclosure_size); 
    if (print_faceplate)  faceplate([enclosure_size.x, enclosure_size.y, faceplate_depth]);
  }
}
if (enclosure_type == "50w") {
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
if (enclosure_type == "50w-2") {
  enclosure_size = [160, 180, 35];
  ydistribute(spacing=220) {
    if (print_enclosure)  backplate(enclosure_size); 
    if (print_faceplate)  faceplate([enclosure_size.x, enclosure_size.y, faceplate_depth]);
  }
}
if (enclosure_type == "100w") {
  enclosure_size = [175, 200, 35];
  ydistribute(spacing=70) {
    if (print_enclosure)  backplate(enclosure_size); 
    if (print_faceplate)  yrot(0) faceplate([enclosure_size.x, enclosure_size.y, faceplate_depth]);
  }
}
if (enclosure_type == "150w") {
  enclosure_size = [175, 210, 35];
  ydistribute(spacing=220) {
    if (print_enclosure)  backplate(enclosure_size); 
    if (print_faceplate)  faceplate([enclosure_size.x, enclosure_size.y, faceplate_depth]);
  }
}
if (enclosure_type == "200w") {
  enclosure_size = [175, 280, 35];
  ydistribute(spacing=220) {
    if (print_enclosure)  backplate(enclosure_size); 
    if (print_faceplate)  faceplate([enclosure_size.x, enclosure_size.y, faceplate_depth]);
  }
}
if (enclosure_type == "wasatch") {
  enclosure_size = [150, 150, 35];
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
      attach([FRONT], overlap=1) 
	if (use_mounting_tabs) mounting_tabs(size.x - 60);
      attach([BACK], overlap=1) 
	if (use_mounting_tabs) mounting_tabs(size.x - 60);

      //left wall
      attach([TOP], overlap=overlap) {
	// outer lip
	back(size.y / 2 - (wall_width + tolerance)/2) cuboid([size.x, wall_width+tolerance, size.z+overlap], anchor=BOTTOM)
	   if (enclosure_type == "100w" )
	     attach(FRONT, overlap=4) {
	       tag("holes") { 
		 translate([size.x/2-35, 0, -2]) { 
		   c14_plug_v2([27,19,9]);
		   left(40) cylinder(h=9, r=6.25, anchor=BOTTOM);
		 }
	       }
	     }

	//right wall
	fwd(size.y / 2 - (wall_width + tolerance)/2) cuboid([size.x, wall_width+tolerance, size.z+overlap], anchor=BOTTOM) {
	    if (enclosure_type == "50w" || enclosure_type == "100w")
	      attach(BACK, overlap=.5) {
		translate([size.y/2 - 33, 6, 0]) connector(3_pin_connector_size, anchor=FRONT);
		translate([size.y/2 - 53, 6, 0]) connector(3_pin_connector_size, anchor=FRONT);
	      }
	    if ( enclosure_type == "15w" && arduino_inside ) {
	      attach(BACK, overlap=.5) {
		tag("holes") { 
		  translate([size.x/2-25, -2, 0]) nema5_15R_female(wall_width*2);
		  translate([10, 0, -2]) cylinder(h=5, r=7.75, anchor=BOTTOM, $fn=45);
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

	      if ( enclosure_type == "none" && arduino_inside ) {
		tag("holes") { 
		  translate([27, 0, -2]) cylinder(h=5, r=7.75, anchor=BOTTOM, $fn=45);
		  translate([0, 0, -2]) cylinder(h=5, r=7.75, anchor=BOTTOM, $fn=45);
	          translate([-27, 0, -2]) cylinder(h=9, r=6, anchor=BOTTOM, $fn=45);

		}
	      }
	    }
	    if ( enclosure_type == "wasatch" ) {
		// power switch
		//tag("holes") translate([-60, 0, 0]) cuboid([10.5, 7, 28.6]);
		//tag("holes") translate([-60, -.5, 0]) cuboid([10.5, 7, 28.6]);
		tag("holes") translate([-60, 0, 0]) cuboid([10.5, 7, 28.6]);
	    }
	  }

	//back wall
	left(size.x / 2 - (wall_width + tolerance)/2) cuboid([wall_width+tolerance, size.y, size.z+overlap], anchor=BOTTOM) {
	  if (enclosure_type == "50w") attach(RIGHT, overlap=2)
	      tag("holes") translate([size.y/2-33, 0, -2]) c14_plug_v2([27,19,7]); 

	  if (enclosure_type == "RACM90") attach(RIGHT, overlap=2)
	      tag("holes") translate([(-size.y/2) + 33 , 0, -2]) c14_plug_v2([27,19,7]); 

	  if (enclosure_type == "wasatch") attach(RIGHT, overlap=2)
	      // Power cord
	      tag("holes") { 
		//ethernet
		//translate([0, -5.5, 2]) cuboid([16,15,7]); 
		translate([0, -5, 2]) cuboid([16,14,7]); 
		//Power
		translate([-27.5, 0, 2]) {
		  for(y = [1, -1]) translate([0, 12.5*y, -3]) cylinder(r=1.5, h=6, $fn=20);
		  cuboid([12,19,6]); 
		}
	      }
	}
 
	//front wall
	right(size.x / 2 - (wall_width + tolerance)/2) cuboid([wall_width+tolerance, size.y, size.z+overlap], anchor=BOTTOM) {
	    if (enclosure_type == "50w") attach(LEFT, overlap=.5)
		translate([size.y/2 - 23, 6, 0]) connector(3_pin_connector_size, anchor=FRONT);
	    if (enclosure_type == "wasatch") attach(LEFT, overlap=-1.5) {
	      // LED connections
	      for(y = [0, 1]) {
		for(x = [1:1:4]) {
		  xpos = -size.y/2 + (size.y/5 * x);
		  fwd(10) 
		    if (led_connector == "JST") { 
		      translate([xpos, (16*y)+1, -2]) {
			tag("holes") jst_connector(pins=3);  
			back(5) yrot(180) linear_extrude(2) 
			  text(str((9-4*y) - x), size=4, anchor=FRONT);
		      }
		    // pigtails
		    } else { 
		      tag("holes") translate([xpos+8-(16*y), (16*y)+1, -2]) down(2) cylinder(r=6, h=7, $fn=40);
		    } 
		}
	      }
	    }
	}

	// inner lip
	back(size.y / 2 + wall_width/2 - (wall_width*2 + tolerance)) cuboid([size.x - 2*(wall_width + tolerance), wall_width, inner_lip_height], anchor=BOTTOM);
	fwd (size.y / 2 + wall_width/2 - (wall_width*2 + tolerance)) cuboid([size.x - 2*(wall_width + tolerance), wall_width, inner_lip_height], anchor=BOTTOM);
	left(size.x / 2 + wall_width/2 - (wall_width*2 + tolerance)) cuboid([wall_width, size.y - 2*(wall_width+tolerance), inner_lip_height], anchor=BOTTOM);
	right(size.x / 2 + wall_width/2 - (wall_width*2 + tolerance)) cuboid([wall_width, size.y - 2*(wall_width+tolerance), inner_lip_height], anchor=BOTTOM);


	if (! screwhead_faceplate ) {
	  // Screwposts
	  screwhole_xpos = size.x / 2 - (wall_width+tolerance) - screwpost_size / 2;
	  screwhole_ypos = size.y / 2 - (wall_width+tolerance) - screwpost_size / 2;
	  for(x = [1, -1]) {
	    for(y = [1, -1]) {
	      move([screwhole_xpos * x, screwhole_ypos  * y, 0]) cuboid([screwpost_size,screwpost_size,inner_lip_height], anchor=BOTTOM);
	    }
	  }
	}

	// PCB mounts for arduino
	if (enclosure_type == "wasatch") {
	  pcb_wall_distance=21.5;
	  translate([-size.x/2, -size.y/2]) {
	    translate([wasatch8_pcb_size.y/2 + pcb_wall_distance, size.x/2]) 
	      pcb_mounts(wasatch8_pcb_size, wasatch8_hole_distance, wasatch8_hole_diameter);
	  }
	}

	if (enclosure_type == "RACM90") {
	  translate([size.x/2 - 15, size.y/2 - 14]) {
	    translate([-RACM90_psu_size.x/2, -RACM90_psu_size.y/2]) RACM90_psu_mount();
	    if (arduino_inside) {
	      fwd(RACM90_psu_size.y + 10) {
		translate([-70x50_pcb_size.x/2, -70x50_pcb_size.y/2]) 
		  pcb_mounts(70x50_pcb_size, 70x50_hole_distance, 70x50_hole_diameter);
		left(70x50_pcb_size.x + 5)
		  translate([-70x50_pcb_size.x/2, -70x50_pcb_size.y/2]) 
		  pcb_mounts(70x50_pcb_size, 70x50_hole_distance, 70x50_hole_diameter);
	      }
	    }
	  }
	}

	if (enclosure_type == "15w") {
	  back(44) translate([-size.x/2+6, -size.y/2+6]) {
	    translate([+MW_RS15_psu_size.y/2, MW_RS15_psu_size.x/2]) zrot(90) MW_RS15_psu_mount();
	    if (arduino_inside) {
	      right(MW_RS15_psu_size.y + 6)
		translate([beefcake_relay_pcb_size.x/2, beefcake_relay_pcb_size.y/2]) 
		pcb_mounts(beefcake_relay_pcb_size, beefcake_relay_hole_distance, beefcake_relay_hole_diameter);
	      back(MW_RS15_psu_size.x + 10) 
		translate([70x50_pcb_size.y/2+10, 70x50_pcb_size.x/2]) 
		zrot(90) pcb_mounts(70x50_pcb_size, 70x50_hole_distance, 70x50_hole_diameter);
	    }
	  }
	}

	if (enclosure_type == "none") {
	  back(0) translate([-size.x/2, -size.y/2]) {
	    if (arduino_inside) {
		translate([70x50_pcb_size.y/2+15, 70x50_pcb_size.x/2+40]) 
		zrot(90) pcb_mounts(70x50_pcb_size, 70x50_hole_distance, 70x50_hole_diameter);
	    }
	  }
	}

	if (enclosure_type == "50w") {
	  if (relay_type == "pcb") {
	    translate([size.x/2 - 10, size.y/2 - 6]) {
	      translate([-MW_LRS50_psu_size.x/2, -MW_LRS50_psu_size.y/2]) MW_LRS50_psu_mount();
	      if (arduino_inside) {
		fwd(MW_LRS50_psu_size.y + 10) {
		  translate([-70x50_pcb_size.x/2, -70x50_pcb_size.y/2]) 
		    pcb_mounts(70x50_pcb_size, 70x50_hole_distance, 70x50_hole_diameter);
		  left(70x50_pcb_size.x + 10)
		    translate([-70x50_pcb_size.x/2, -70x50_pcb_size.y/2]) 
		    pcb_mounts(70x50_pcb_size, 70x50_hole_distance, 70x50_hole_diameter);
		}
	      }
	    }
	  } else { 
	    translate([size.x/2 - 10, size.y/2 - 6]) {
	      translate([-MW_LRS50_psu_size.x/2, -MW_LRS50_psu_size.y/2]) MW_LRS50_psu_mount();
	      if (arduino_inside) {
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
	}

	if (enclosure_type == "50w-2") {
	  translate([size.x/2 - 10, size.y/2 - 6]) {
	    translate([-MW_LRS50_psu_size.x/2, -MW_LRS50_psu_size.y/2]) MW_LRS50_psu_mount();
	      if (arduino_inside) {
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
	}

	if (enclosure_type == "100w") {
	  translate([size.x/2 - 6, -size.y/2 + 15]) {
	    translate([-MW_LRS100_psu_size.y/2, MW_LRS100_psu_size.x/2]) zrot(270) MW_LRS100_psu_mount();
	    if (arduino_inside) {
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
	}

	if (enclosure_type == "150w") {
	  translate([size.x/2 - 6, -size.y/2 + 15]) {
	    translate([-MW_LRS150_psu_size.y/2, MW_LRS150_psu_size.x/2]) zrot(270) MW_LRS150_psu_mount();

	    if (arduino_inside) {
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
	}

	if (enclosure_type == "200w") {
	  translate([size.x/2 - 6, -size.y/2 + 15]) {
	    translate([-MW_LRS200_psu_size.y/2, MW_LRS200_psu_size.x/2]) zrot(270) MW_LRS200_psu_mount();
	  }
	}
      } //attach

	if ( ! screwhead_faceplate ) {
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
}



module faceplate(size) {
  diff("components", "clip") cuboid([size.x, size.y, 4], chamfer=3, edges=[BOTTOM], anchor=BOTTOM) {
    attach([TOP], overlap=overlap) {
      for(n = [1, -1]) {
	translate([0, (size.y/2 - wall_width/2) * n, 0]) cuboid([size.x, wall_width, size.z - face_depth + overlap], anchor=BOTTOM);
	translate([(size.x/2 - wall_width/2) * n, 0, 0]) cuboid([wall_width, size.y, size.z - face_depth + overlap], anchor=BOTTOM);
      }
    }
    attach([TOP], overlap=overlap) {
      screwhole_xpos = size.x / 2 - wall_width * 2 - 1;
      screwhole_ypos = size.y / 2 - wall_width * 2 - 1;
      screwhole_zpos = 0;
      move([screwhole_xpos,      screwhole_ypos,      screwhole_zpos])
        rotate(325) backplate_screwholes(size.z-face_depth+overlap);
      move([screwhole_xpos * -1, screwhole_ypos,      screwhole_zpos])
        rotate(125) backplate_screwholes(size.z-face_depth+overlap);
      move([screwhole_xpos * -1, screwhole_ypos * -1, screwhole_zpos])
        rotate(145) backplate_screwholes(size.z-face_depth+overlap);
      move([screwhole_xpos,      screwhole_ypos * -1, screwhole_zpos])
        rotate(305) backplate_screwholes(size.z-face_depth+overlap);

    }
    attach([TOP], overlap=overlap) {
//      right(50) back(20) zrot(90) lcd_4x20();
      if (lcd_enabled) right(45) back(20) zrot(90) lcd_2x16();
      if (pir_enabled) right(45) fwd(60) xrot(180) pir();

      tag("components") {
        if (encoder_enabled) back(15) right(10) cuboid([15, 34, 3])
	  attach(BOTTOM, overlap=1)  {
	    fwd(6) cuboid([2,1,2], anchor=BOTTOM);
	    cylinder(h=7, r=7.1/2, $fn=45, anchor=BOTTOM);
	  }
	// vents
	if (vents_enabled) {
	  //fwd(45) left(20) down(4) 
	  left(25) down(4) 
	    for (x=[0:3:45]) {
//	    for (x=[0,5,10,15,20,25,30,35]) {
	      left(x) cuboid([1, 50, 6], anchor=BOTTOM);
	    }
	}
      }
    }
  }
}

module pir() {
  pir_size=[24.5,32.7,4];
  opening_size=[24.5,24.5,5];
  header_size=[8,2,3.4];
  pir_inset_depth=6;
  pcb_height = 1.50;
  clip_cylinder_radius = .5;

  nub_size = [7,2,.5];
  pcb_base_plane_position = pir_inset_depth-5;

  down(pir_size.z+opening_size.z) {
    up(pir_inset_depth) tag("components") cuboid(pir_size, anchor=BOTTOM) {
//      attach([BACK], overlap=1) cylinder(r=4, h=pir_size.z, spin=[90,0,0], anchor=CENTER);
      attach([TOP], overlap=1)
	cuboid(opening_size, anchor=BOTTOM) {
	  // 4 header cavities
	  attach([FRONT], overlap=0) {
	    up(.7) left(opening_size.x / 2 - header_size.x / 2) back(-1) cuboid(header_size, anchor=BOTTOM);
	    up(.7) right(opening_size.x / 2 - header_size.x / 2) back(-1) cuboid(header_size, anchor=BOTTOM);
	  }
	  attach([BACK], overlap=0) {
	    up(.7) left(opening_size.x / 2 - header_size.x / 2) back(-1) cuboid(header_size, anchor=BOTTOM);
	    up(.7) right(opening_size.x / 2 - header_size.x / 2) back(-1) cuboid(header_size, anchor=BOTTOM);
	  }
	}
    }
  }

  tag("clip") {
    up(pcb_base_plane_position-pcb_height-tolerance)  {
      up(3)  {
	// PCB clip
	back(pir_size.y/2+clip_cylinder_radius) { 
	  fwd(.3) down(1.4+pcb_height) left(nub_size.x/2) yrot(90) cylinder(h=nub_size.x, r=clip_cylinder_radius, $fn=45);
	}
      }
      // PCB nub
      move([0, -pir_size.y/2, -nub_size.z/2 ] ) cuboid(nub_size);
    }
  }
}

module clip() {
  poly_path=([[.5,.5],[.5,0],[0,-.3],[-.5,0],[-.5,.5]]);
  length=2;
  attachable(CENTER, 0, FRONT, path=poly_path, l=length) {
    down(2.5) yrot(90) linear_extrude(height=length, center=true) polygon(poly_path);
    children();
  } 
}

module lcd_2x16() {
  size=[72,25,8];
  header_size = [40,4,5];
  tag("components") down(5.0) {
    cuboid(size, anchor=BOTTOM) 
    attach(RIGHT,BOTTOM, overlap=.1) {
      back(1.5) prismoidal([12,4,4]);
    }
    translate([-(size.x/2 - header_size.x/2 - 3), -(size.y/2 + header_size.y/2 + 1.5), 3]) cuboid(header_size, anchor=BOTTOM);
    //translate([-13,-16, 3]) cuboid([40,4,5], anchor=BOTTOM);
  }
  fwd(1.4)
  for(x = [1, -1]) {
    for(y = [1, -1]) {
      //move([37.5 * x, 15.5 * y]) screw("M3", length=6, anchor=BOTTOM); 
      move([(size.x/2 + 1.5) * x, (size.y/2 + 3) * y]) screw("M3", length=6, anchor=BOTTOM); 
    }
  }
}

module lcd_4x20() {
  size=[97,40,8];
  header_size = [42,4,5];
  tag("components") down(5.0) {
    cuboid(size, anchor=BOTTOM);
    translate([-size.x/2 + header_size.x/2 + 7, -size.y/2 - header_size.y/2 - 6, 3]) cuboid(header_size, anchor=BOTTOM);
  }
  for(x = [1, -1]) {
    for(y = [1, -1]) {
      //move([(size.x/2 - 2) * x, (size.y/2 + 8) * y]) screw("M3", length=6, anchor=BOTTOM); 
      move([(size.x/2 - 1.75) * x, (size.y/2 + 7.75) * y]) screw("M3", length=6, anchor=BOTTOM); 
    }
  }
}

module backplate_screwholes(faceplate_inside_depth) {
  diff("screwholes") {
    cylinder(h=faceplate_inside_depth-lip_height, r=screwpost_diameter, anchor=BOTTOM, $fn=45);

    tag("screwholes") cylinder(h=faceplate_inside_depth, r=screwpost_hole_size, $fn=45, anchor=BOTTOM)
      attach([LEFT+FRONT]) {
	fwd(faceplate_inside_depth/2 - 8) down(1) cuboid([5.5,2.1,9]);
      }
  }
}



