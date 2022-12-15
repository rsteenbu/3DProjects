include <BOSL2/std.scad>;
include <BOSL2/metric_screws.scad>;
include <powersupply-mount.scad>;
include <box-connectors.scad>;
include <pcb-mount.scad>;
include <my-general-libraries.scad>;
include <enclosure-faceplate.scad>;

enclosure_size = [180, 100, 30];

arduino_inside = true;
mounting_tabs = true;
print_pcb = false;
print_psu = false;
print_enclosure = false;
print_faceplate = true;

wall_width = 2;
overlap = 1;
post_hole_size = 1.8;
tolerance = .15;
lip_width = 3;
lip_height = 3;
// LCD, PIR, LCD+PIR, NONE
enclosure_stuff = "NONE";

faceplate_component_margin=10.5;
connector_pos_from_edge = 13;

ydistribute(spacing=120) {
  //if (print_enclosure) lcd2_16_enclosure([x,55,20]); 
  if (print_enclosure)  backplate(enclosure_size); 
  if (print_faceplate)  faceplate(enclosure_size);
}

module backplate(size) {
   inner_lip_height = size.z + lip_height - tolerance;
   screwpost_size = 7;
   
   diff("holes") cuboid([size.x, size.y, wall_width], anchor=BOTTOM) {
      attach([BACK], overlap=1) {
	//cuboid([8,wall_width,8], anchor=BOTTOM);
	//mounting holes
	if (mounting_tabs) {
	  mounting_hole_distance_apart = 80;
	  for(x = [1, -1]) {
	    move([(mounting_hole_distance_apart / 2) * x, 0, -2])
	      prismoidal([16,wall_width,14],BOTTOM)
	      tag("holes")
	      attach([FRONT], overlap=3) back(1) cylinder(h=5, r=2.2, anchor=BOTTOM, $fn=45);
	  }
	}
          
      }

      attach([TOP]) {
        // outer lip
        back(size.y / 2 - (wall_width + tolerance)/2) cuboid([size.x, wall_width+tolerance, size.z], anchor=BOTTOM);
        fwd (size.y / 2 - (wall_width + tolerance)/2) cuboid([size.x, wall_width+tolerance, size.z], anchor=BOTTOM);
        left(size.x / 2 - (wall_width + tolerance)/2) cuboid([wall_width+tolerance, size.y, size.z], anchor=BOTTOM) {
	  attach(RIGHT, overlap=.5) {
	    if (arduino_inside) {
	      tag("holes") { 
		translate([-25, -2, 0]) nema5_15R_female(wall_width*2);
		translate([4, 0, -2]) cylinder(h=5, r=7.75, anchor=BOTTOM, $fn=45);
	      }

              letter_extrude=2.7;
	      connector_xpos = 35;
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
        right(size.x / 2 - (wall_width + tolerance)/2) cuboid([wall_width+tolerance, size.y, size.z], anchor=BOTTOM);

        // inner lip
        back(size.y / 2 + wall_width/2 - (wall_width*2 + tolerance)) cuboid([size.x - 2*(wall_width + tolerance), wall_width, inner_lip_height], anchor=BOTTOM);
        fwd (size.y / 2 + wall_width/2 - (wall_width*2 + tolerance)) cuboid([size.x - 2*(wall_width + tolerance), wall_width, inner_lip_height], anchor=BOTTOM);
        left(size.x / 2 + wall_width/2 - (wall_width*2 + tolerance)) cuboid([wall_width, size.y - 2*(wall_width+tolerance), inner_lip_height], anchor=BOTTOM);
        right(size.x / 2 + wall_width/2 - (wall_width*2 + tolerance)) cuboid([wall_width, size.y - 2*(wall_width+tolerance), inner_lip_height], anchor=BOTTOM);
        
        // Screwposts
        inside_xpos = size.x / 2 - (wall_width+tolerance) - screwpost_size / 2;
        inside_ypos = size.y / 2 - (wall_width+tolerance) - screwpost_size / 2;
        for(x = [1, -1]) {
          for(y = [1, -1]) {
            move([inside_xpos * x, inside_ypos  * y, 0]) cuboid([screwpost_size,screwpost_size,inner_lip_height], anchor=BOTTOM);
          }
        }

        if (arduino_inside) {
	  // PCB mounts for arduino
	  zrot(90) translate([0, -58]) zrot(90) pcb_mounts(70x50_pcb_size, 70x50_hole_distance, 70x50_hole_diameter);
	  zrot(90) translate([-28, 2]) pcb_mounts(beefcake_relay_pcb_size, beefcake_relay_hole_distance, beefcake_relay_hole_diameter, .5);
          translate([-5,18.5]) 5v_psu_mount();

	} //arduino inside
      }

      attach([BOTTOM]) {
        tag("holes") {
          head_hole_size = 3.1;
          screwhole_xpos = (size.x / 2 - wall_width - 2) - .5;
          screwhole_ypos = size.y / 2 - 5.5;
          for(x = [1, -1]) {
            for(y = [1, -1]) {
              move([screwhole_xpos * x, screwhole_ypos * y, - (inner_lip_height + 3)]) cylinder(h=15, r=post_hole_size, anchor=BOTTOM, $fn=45);
              move([screwhole_xpos * x, screwhole_ypos * y, 1]) cylinder(h=size.z+1, r=head_hole_size, anchor=TOP, $fn=45);
            }
          }
        }
      }
  }
}

