include <BOSL2/std.scad>;
include <BOSL2/metric_screws.scad>;
include <BOSL2/screws.scad>;

//faceplate stuff
//enclosure_size = [139.5, 55, 23];
//backplate_depth = 13;
enclosure_size = [139.5, 62, 14];
backplate_depth = 13;
arduino_inside = true;

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
3_pin_connector_size = [10.0, 6.1, support_height+5];
4_pin_connector_size = [12.4, 6.2, support_height+5];

connector_pos_from_edge = 13;
print_enclosure = true;
print_backplate = true;

// LCD, PIR, LCD+PIR
enclosure_stuff = "LCD+PIR";

ydistribute(spacing=65) {
  //if (print_enclosure) lcd2_16_enclosure([x,55,20]); 
  if (print_backplate)  
    if (arduino_inside) backplate([enclosure_size.x,enclosure_size.y,backplate_depth+10]); 
    else backplate([enclosure_size.x,enclosure_size.y,backplate_depth]); 
  if (print_enclosure)  lcd2_16_enclosure(enclosure_size); 
}


module backplate(size) {
   inner_lip_height = size.z + lip_height - tolerance;
   screwpost_size = 7;
   
   diff("holes")
   cuboid([size.x, size.y, wall_width], anchor=TOP) {
      attach([BOTTOM]) {
        // outer lip
        back(size.y / 2 - (wall_width + tolerance)/2) cuboid([size.x, wall_width+tolerance, size.z], anchor=BOTTOM);
        fwd (size.y / 2 - (wall_width + tolerance)/2) cuboid([size.x, wall_width+tolerance, size.z], anchor=BOTTOM);
        left(size.x / 2 - (wall_width + tolerance)/2) cuboid([wall_width+tolerance, size.y, size.z], anchor=BOTTOM)
	  attach(RIGHT) {
	    if (arduino_inside) {
		//sensor connectors
		move([-7,-2,0]) connector(3_pin_connector_size, anchor=FRONT);
		move([-7,-10,0]) connector(3_pin_connector_size, anchor=FRONT);

		//power connectors
		move([7,-2,0]) connector(3_pin_connector_size, anchor=FRONT);
		move([7,-10,0]) connector(3_pin_connector_size, anchor=FRONT);
	    } else {
	      if (enclosure_stuff == "LCD" || enclosure_stuff == "LCD+PIR") {
		left(7) fwd(4) connector(3_pin_connector_size, anchor=FRONT);
	      }
	      if (enclosure_stuff == "PIR" || enclosure_stuff == "LCD+PIR") {
		right(7) fwd(4) connector(4_pin_connector_size, anchor=FRONT);
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
	  // PCB screwposts
	  mounting_hole_xdistance = 61;;
	  mounting_hole_ydistance = 46;
	  for(x = [1, -1]) {
	    for(y = [1, -1]) {
	      move([ (mounting_hole_xdistance / 2) * x, (mounting_hole_ydistance / 2) * y, -1])  
		cylinder(h=4, r=4, anchor=BOTTOM) 
		attach([TOP], overlap=1) screw("M3", length=5, anchor=BOTTOM);
	    }
	  }
	}
      }
      attach([TOP]) {
        tag("holes") {
          head_hole_size = 3.1;
          screwhole_xpos = (size.x / 2 - wall_width - 2) - .5;
          screwhole_ypos = size.y / 2 - 5.5;
          for(x = [1, -1]) {
            for(y = [1, -1]) {
              move([screwhole_xpos * x, screwhole_ypos * y, - (inner_lip_height + 3)]) cylinder(h=15, r=post_hole_size, anchor=BOTTOM);
              move([screwhole_xpos * x, screwhole_ypos * y, 1]) cylinder(h=size.z+1, r=head_hole_size, anchor=TOP);
            }
          }
          inside_xpos = size.x / 2 - (wall_width+tolerance) - 20;
          //mountintg holes
	  mounting_hole_distance_apart = 80;
	  mounting_hole_distance_from_edge = 10;
	  for(x = [1, -1]) {
	    move([ (mounting_hole_distance_apart / 2) * x, size.y / 2 - wall_width - mounting_hole_distance_from_edge , 1])
	      cylinder(h=5, r=2.2, anchor=TOP);
	  }
          
        }
      }

      //if(arduino_inside) {
//	position(BOTTOM+RIGHT) back(0) left(connector_pos_from_edge+5) connector(4_pin_connector_size, anchor=RIGHT+TOP);
      //}
  }
}

module connector(connector_size, anchor) {
  // the support surrounding the connector is depth of the support * 2 to account for both parallel sides
  support_size = [connector_size.x + support_depth * 2, connector_size.y + support_depth * 2, support_height];
  //support frame
  up(2) cuboid(support_size, anchor=anchor)
    attach([BOTTOM], overlap=1)
      tag("holes") cuboid(connector_size);
}

module lcd2_16_enclosure(size) {
  diff("inside")
  cuboid(size, chamfer=5, edges=[TOP], anchor=TOP) {
    tag("inside") { 
      attach([TOP], overlap=5) {
        inside_space([size.x-wall_width*2,size.y-wall_width*2,size.z+5]);
        
        //backplate screwholes
        // [1,1] [1,-1] [-1,-1] [-1,1]
        //  0      90    180    270
        screwhole_xpos = size.x / 2 - wall_width - 2.5;
        screwhole_ypos = size.y / 2 - 5.5;
        screwhole_zpos = size.z - 5.5;
        move([screwhole_xpos, screwhole_ypos, -2]) rotate(325) backplate_screwholes();
        move([screwhole_xpos * -1, screwhole_ypos, -2]) rotate(125) backplate_screwholes();
        move([screwhole_xpos * -1, screwhole_ypos * -1, -2]) rotate(145) backplate_screwholes();
        move([screwhole_xpos, screwhole_ypos * -1, -2]) rotate(305) backplate_screwholes();
      }
    }
  }
}

module backplate_screwholes() {
  cylinder(h=20, r=post_hole_size, anchor=TOP)
    attach([LEFT+FRONT]) {
        fwd(enclosure_size.z - 23) down(1) cuboid([5.5,2.1,8]);
    }
}

module inside_space(inside_size) {
  diff("screwholes")
  cuboid(inside_size, anchor=TOP) 
    attach([TOP], overlap=1) {
      if (enclosure_stuff == "LCD" || enclosure_stuff == "LCD+PIR") { 
        lcd_pos = (inside_size.x / 2 - lcd_size.x / 2 - margin);
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
        pir_pos = (inside_size.x / 2 - pir_size.x / 2 - margin);
        left(pir_pos) pir();
        tag("screwholes") {
          //Screwposts
          screwhole_xpos = inside_size.x / 2 - 1;
          screwhole_ypos = inside_size.y / 2 - 3;
          for(x = [1, -1]) {
            for(y = [1, -1]) {
              move([screwhole_xpos * x, screwhole_ypos * y, 10]) cylinder(h=inside_size.z-(lip_height + 1), r=5, anchor=TOP);
            }
          }
          pcb_height = 1.50;
          // PCB clip
          move([-pir_pos, 17.1, 4]) cuboid([2,1,6]) 
            attach(FRONT,BACK, overlap=.5) clip(); 
          // PCB nub
          move([-pir_pos, -16.5, 3.5 - pcb_height]) cuboid([3,2,1]);
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

module lcd2_16() {
  cuboid(lcd_size, anchor=BOTTOM) 
    attach(RIGHT,BOTTOM, overlap=.1) {
      back(-2.5)  prismoidal([12,3,4]);
    }
    back(16) left(13) cuboid([40,4,5], anchor=BOTTOM);
}

module prismoidal(size) {
    scale=0.5;
    attachable(CENTER, 0, UP, size=size, size2=[size.x, size.y] * scale) {
        hull() {
            up(size.z/2-0.005)
                linear_extrude(height=0.01, center=true)
                    square([size.x*scale,size.y], center=true);
            down(size.z/2-0.005)
                linear_extrude(height=0.01, center=true)
                    square([size.x,size.y], center=true);
        }
        children();
    }
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
