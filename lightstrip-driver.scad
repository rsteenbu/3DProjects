include <BOSL2/std.scad>;
include <BOSL2/metric_screws.scad>;
include <BOSL2/screws.scad>;
include <test-powersupply-mount.scad>;
include <test-connector-mount.scad>;
include <test-pcb-mount.scad>;

//faceplate stuff
enclosure_size = [180, 100, 14];
backplate_depth = 30;
arduino_inside = true;
mounting_tabs = true;
print_pcb = false;
print_psu = false;

wall_width = 2;
post_hole_size = 1.8;
margin=10.5;
gap=22;

lcd_size=[72,25,8];
pir_size=[24.5,33.2,4];

//backplate stuff
tolerance = .15;
lip_width = 3;
lip_height = 3;

//connector stuff
support_depth = 2;
support_height = wall_width + 3;
2_pin_connector_size = [7.45, 5.95, support_height+5];
3_pin_connector_size = [9.95, 5.95, support_height+5];
4_pin_connector_size = [12.45, 5.95, support_height+5];
connector_pos_from_edge = 13;

// nema plug
base_nema5_15_size=[18.3,16, wall_width+4];
nema_clip_width=4;  //size to edge is 4.235

// psu stuff
psu_size = [63.1, 51.3, 28];
screw_height = 16;
screw_distance = 39.25;
mount_height = 4;
top_anchor_overhang = 2;

print_enclosure = false;
print_backplate = true;

// LCD, PIR, LCD+PIR, NONE
enclosure_stuff = "NONE";

// 70x50 PCB mounting stuff
70x50_pcb_size = [50, 70]; 
70x50_hole_diameter = 2;
70x50_hole_distance=[46,66];

beefcake_relay_pcb_size = [30.5, 62.3];
beefcake_relay_hole_diameter = 3.25;
beefcake_relay_hole_distance=[25.50,50.76];

overlap = 1;
pcb_clip_size=[1.5,4.5];
pcb_height = 4;
pcb_thickness = 1.6;


diff("box") {
ydistribute(spacing=35) {
  //if (print_enclosure) lcd2_16_enclosure([x,55,20]); 
  if (print_backplate)  backplate([enclosure_size.x,enclosure_size.y,backplate_depth]); 
  if (print_enclosure)  lcd2_16_enclosure(enclosure_size);

  //nema5_15R_female(wall_width*2);
}

//  move([-15,-20,10]) tag("box") cuboid([80,80,50], anchor=TOP);
}


module backplate(size) {
   inner_lip_height = size.z + lip_height - tolerance;
   screwpost_size = 7;
   
   diff("holes")
   cuboid([size.x, size.y, wall_width], anchor=TOP) {
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

      attach([BOTTOM]) {
        // outer lip
        back(size.y / 2 - (wall_width + tolerance)/2) cuboid([size.x, wall_width+tolerance, size.z], anchor=BOTTOM);
        fwd (size.y / 2 - (wall_width + tolerance)/2) cuboid([size.x, wall_width+tolerance, size.z], anchor=BOTTOM);
        left(size.x / 2 - (wall_width + tolerance)/2) cuboid([wall_width+tolerance, size.y, size.z], anchor=BOTTOM) {
	  attach(RIGHT, overlap=.5) {
 	    //tag("holes") right(10) fwd(2) nema5_15R_female(wall_width*2);
	    if (arduino_inside) {
	      tag("holes") { 
		translate([-22, -2, 0]) nema5_15R_female(wall_width*2);
		translate([6, 0, -2]) cylinder(h=5, r=6, anchor=BOTTOM, $fn=45);
	      }

              letter_extrude=2.5;
	      translate([34,10]) yrot(180) linear_extrude(letter_extrude) text("1", size=4, anchor=FRONT);
              translate([34,0]) connector(2_pin_connector_size, anchor=FRONT);

	      translate([24,10]) yrot(180) linear_extrude(letter_extrude) text("2", size=4, anchor=FRONT);
              translate([24,0]) connector(2_pin_connector_size, anchor=FRONT);

              translate([34,-9]) connector(2_pin_connector_size, anchor=FRONT);
	      translate([34,-12]) yrot(180) linear_extrude(letter_extrude) text("3", size=4, anchor=FRONT);

              translate([24,-9]) connector(2_pin_connector_size, anchor=FRONT);
	      translate([24,-12]) yrot(180) linear_extrude(letter_extrude) text("4", size=4, anchor=FRONT);

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
	  zrot(90) translate([0,-50]) zrot(90) pcb_mounts(70x50_pcb_size, 70x50_hole_distance, 70x50_hole_diameter);
	  zrot(90) translate([-28,20]) pcb_mounts(beefcake_relay_pcb_size, beefcake_relay_hole_distance, beefcake_relay_hole_diameter, .5);
          translate([-15,18.5]) 5v_psu_mount(psu_size);

	} //arduino inside
      }

      attach([TOP]) {
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

module prismoidal(size, anchor=CENTER) {
    scale=0.5;
    attachable(anchor, 0, UP, size=size, size2=[size.x, size.y] * scale) {
        hull() {
            up(size.z/2-0.005)                                                                                                    linear_extrude(height=0.01, center=true)
                    square([size.x*scale,size.y], center=true);                                                               down(size.z/2-0.005)
                linear_extrude(height=0.01, center=true)                                                                              square([size.x,size.y], center=true);
        }
        children();
    }
}


