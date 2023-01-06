include <BOSL2/std.scad>;
include <BOSL2/metric_screws.scad>;

2x16_lcd_size=[72,25,8];
4x20_lcd_size=[97,40,8];
pir_size=[24.5,33.2,4];
lip_height=1;
face_depth=5;

module faceplate(size) {
  diff("inside")
  cuboid(size, chamfer=5, edges=[BOTTOM], anchor=BOTTOM) {
    tag("inside") { 
      attach([BOTTOM], overlap=face_depth) {
        inside_space([size.x-wall_width*2,size.y-wall_width*2,size.z-face_depth]);
        
        //backplate screwholes
        // [1,1] [1,-1] [-1,-1] [-1,1]
        //  0      90    180    270
        screwhole_xpos = size.x / 2 - wall_width - 2.5;
        screwhole_ypos = size.y / 2 - 5.5;
	screwhole_zpos = 0;
        //screwhole_zpos = -(size.z - face_depth) - 12;
        //screwhole_zpos = size.z - face_depth;
        move([screwhole_xpos, screwhole_ypos, screwhole_zpos]) rotate(325) backplate_screwholes(size.z-face_depth);
        move([screwhole_xpos * -1, screwhole_ypos, screwhole_zpos]) rotate(125) backplate_screwholes(size.z-face_depth);
        move([screwhole_xpos * -1, screwhole_ypos * -1, screwhole_zpos]) rotate(145) backplate_screwholes(size.z-face_depth);
        move([screwhole_xpos, screwhole_ypos * -1, screwhole_zpos]) rotate(305) backplate_screwholes(size.z-face_depth);
      }
    }
  }
}

module backplate_screwholes(faceplate_depth) {
  cylinder(h=faceplate_depth, r=post_hole_size, anchor=TOP, $fn=45)
    attach([LEFT+FRONT]) {
         fwd(faceplate_depth/2 - (lip_height+2)) down(1) cuboid([5.5,2.1,8]);
        //fwd(faceplate_depth/2 - (wall_width + 11.5)) down(1) cuboid([5.5,2.1,8]);
    }
}

module inside_space(inside_size) {
  diff("screwholes")
  cuboid([inside_size.x, inside_size.y, inside_size.z+overlap], anchor=TOP) 
    attach([TOP], overlap=1) {
      if (enclosure_stuff == "LCD" || enclosure_stuff == "LCD+PIR") { 
        lcd_pos = (inside_size.x / 2 - 2x16_lcd_size.x / 2 - faceplate_component_margin);
        right(lcd_pos) lcd2_16();
        tag("screwholes") {
          for(x = [1, -1]) {
            for(y = [1, -1]) {
              move([lcd_pos + 37.5 * x, 15.5 * y, -4]) screw("M3", length=7, anchor=BOTTOM); 
            }
          }
        }
      }

      if (enclosure_stuff == "PIR" || enclosure_stuff == "LCD+PIR") { 
        pir_pos = (inside_size.x / 2 - pir_size.x / 2 - faceplate_component_margin);
        left(pir_pos) pir();
	tag("screwholes") {
          pcb_height = 1.50;
          // PCB clip
          move([-pir_pos, 17.1, 4]) cuboid([2,1,6]) 
            attach(BACK,FRONT, overlap=.5) clip(); 
          // PCB nub
          move([-pir_pos, -16.5, 3.5 - pcb_height]) cuboid([3,2,1]);
	}
      }

      //Screwposts
      screwhole_xpos = inside_size.x / 2 - 1;
      screwhole_ypos = inside_size.y / 2 - 3;
      for(x = [1, -1]) {
	for(y = [1, -1]) {
	  move([screwhole_xpos * x, screwhole_ypos * y, overlap+tolerance]) 
	    tag("screwholes") 
	    cylinder(h=inside_size.z-lip_height, r=5, anchor=TOP, $fn=45);
	}
      }
    }
}

module lcd2_16() {
  cuboid(2x16_lcd_size, anchor=BOTTOM) 
    attach(RIGHT,BOTTOM, overlap=.1) {
      back(-2.5)  prismoidal([12,3,4]);
    }
    back(16) left(13) cuboid([40,4,5], anchor=BOTTOM);
}

module pir() {
  opening_size=[24.5,24.5,5];
  header_size=[8,2,3.4];
  cuboid(pir_size, anchor=BOTTOM) {
    attach([BACK], overlap=1) cylinder(r=4, h=pir_size.z, spin=[90,0,0], anchor=CENTER);
    attach([TOP], overlap=1)
      cuboid(opening_size, anchor=BOTTOM) {
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


module clip() {
  poly_path=([[.5,.5],[.5,0],[0,-.3],[-.5,0],[-.5,.5]]);
  length=2;
  attachable(CENTER, 0, FRONT, path=poly_path, l=length) {
    down(2.5) yrot(90) linear_extrude(height=length, center=true) polygon(poly_path);
    children();
  } 
}
