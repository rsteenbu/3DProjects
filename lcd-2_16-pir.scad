//use </Users/rsteenbu/3D_Prints/repots/MCAD/involute_gears.scad>;
//use </Users/rsteenbu/3D_Prints/repots/MCAD/servos.scad>;
//use <utility.scad>;
include <BOSL2/std.scad>;
include <BOSL2/metric_screws.scad>;
include <BOSL2/screws.scad>;

//generic_screw(screwsize=3,screwlen=10,headsize=6,headlen=2, anchor="countersunk");
//metric_nut(size=10, hole=true, pitch=1.5);
//metric_nut(size=10, hole=true, pitch=1.5, flange=3, details=true, anchor=BOTTOM);

post_hole_size = 1.8;

ydistribute(spacing=90){
   lcd2_16_enclosure([140,55,20], 2); 
   //down(1) xrot(180) backplate([140,55,20], 2); 
   //inside_space([130,55,20]);
   //lcd2_16([72,25,8]);
   //pir([24,33,4]);
}

module backplate(size=[100,100,100], wall_width=100) {
   tolerance = .2;
   lip_width = 3;
   lip_height = 6;
   inner_lip_height = lip_height + 3 - tolerance;
   screwpost_size = 7;
   
   diff("holes")
   cuboid([size.x, size.y, wall_width]) {
      attach([TOP]) {
        // outer lip
        back(size.y / 2 - (wall_width + tolerance)/2) cuboid([size.x, wall_width+tolerance, lip_height], anchor=BOTTOM);
        fwd (size.y / 2 - (wall_width + tolerance)/2) cuboid([size.x, wall_width+tolerance, lip_height], anchor=BOTTOM);
        left(size.x / 2 - (wall_width + tolerance)/2) cuboid([wall_width+tolerance, size.y, lip_height], anchor=BOTTOM);
        right(size.x / 2 - (wall_width + tolerance)/2) cuboid([wall_width+tolerance, size.y, lip_height], anchor=BOTTOM);
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
      }
      attach([BOTTOM]) {
        tag("holes") {
          head_hole_size = 3;
          screwhole_xpos = (size.x / 2 - wall_width - 2) - .5;
          screwhole_ypos = size.y / 2 - 5.5;
          for(x = [1, -1]) {
            for(y = [1, -1]) {
              move([screwhole_xpos * x, screwhole_ypos * y, - (inner_lip_height + 3)]) cylinder(h=15, r=post_hole_size, anchor=BOTTOM);
              move([screwhole_xpos * x, screwhole_ypos * y, - 3]) cylinder(h=4, r=head_hole_size, anchor=BOTTOM);
            }
          }
          // electrical hole
          inside_xpos = size.x / 2 - (wall_width+tolerance) - 20;
          right(inside_xpos) up(1) cylinder(h=5, r=2, anchor=TOP);
          right(inside_xpos - 80) up(1) cylinder(h=5, r=2, anchor=TOP);
          right(inside_xpos - 30) up(1) cylinder(h=5, r=6, anchor=TOP);
          
          //mountintg holes
        }
      }
   }
 }

module backplate_screwholes() {
  cylinder(h=20, r=post_hole_size, anchor=BOTTOM)
    attach([LEFT+FRONT]) {
        fwd(0) down(1) cuboid([5.4,2,8]);
    }
}

module lcd2_16_enclosure(size=[100,100,100], wall_width=100) {
  diff("lcd")
  cuboid(size, chamfer=5, edges=[TOP], anchor=TOP) {
    tag("lcd") { 
      attach([TOP], overlap=21) {
        inside_space([size.x-wall_width*2,size.y-wall_width*2,15]);
        
        //backplate screwholes
        // [1,1] [1,-1] [-1,-1] [-1,1]
        //  0      90    180    270
        screwhole_xpos = size.x / 2 - wall_width - 2.5;
        screwhole_ypos = size.y / 2 - 5.5;
        move([screwhole_xpos, screwhole_ypos, -2]) rotate(0) backplate_screwholes();
        move([screwhole_xpos, screwhole_ypos * -1, -2]) rotate(270) backplate_screwholes();
        move([screwhole_xpos * -1, screwhole_ypos * -1, -2]) rotate(180) backplate_screwholes();
        move([screwhole_xpos * -1, screwhole_ypos, -2]) rotate(90) backplate_screwholes();
      }
    }
  }
}

module inside_space(inside_size=[100,100,100], lcd_size=[72,25,8], pir_size=[24,33,4], margin=10.5) {
  lcd_pos = (inside_size.x / 2 - lcd_size.x / 2 - margin);
  pir_pos = (inside_size.x / 2 - pir_size.x / 2 - margin);
  diff("screwholes")
  cuboid(inside_size, anchor=BOTTOM) 
    attach([TOP], overlap=1) {
      right(lcd_pos) lcd2_16(lcd_size);

      left(pir_pos) pir(pir_size);

      tag("screwholes") {
        //Screwposts
        screwhole_xpos = inside_size.x / 2 - 1;
        screwhole_ypos = inside_size.y / 2 - 3;
        for(x = [1, -1]) {
          for(y = [1, -1]) {
            move([screwhole_xpos * x, screwhole_ypos * y, -10]) cylinder(h=13, r=5);

          }
        }

        //LCD
        for(x = [1, -1]) {
          for(y = [1, -1]) {
            move([lcd_pos + 37.5 * x, 15.5 * y, -4]) screw("M3", length=7, anchor=BOTTOM); 
          }
        }

        //PIR
        for(y = [1, -1]) {
          move([-pir_pos, 14.5*y, 0]) screw("M2", length=6, anchor=BOTTOM);
        }
      }
    }
}

module lcd2_16(lcd_size) {
  cuboid(lcd_size, anchor=BOTTOM) 
    attach(RIGHT,BOTTOM) {
      back(-2.5) prismoidal([12,3,4], scale=.5);
    }
    back(16) left(13) cuboid([40,4,5], anchor=BOTTOM);
}

module pir(size=[100,100,100], opening_size=[24.5,24.5,5], header_size=[8,2,5.5]) {
  cuboid(size, anchor=BOTTOM) {
    attach([BACK], overlap=1) cylinder(r=4, h=size.z, spin=[90,0,0], anchor=CENTER);
    attach([FRONT], overlap=1) cylinder(r=4, h=size.z, spin=[90,0,0], anchor=CENTER);
    attach([TOP], overlap=1)
      cuboid(opening_size, anchor=BOTTOM) {
          attach([FRONT], overlap=1) {
            left(opening_size.x / 2 - header_size.x / 2) back(-1) cuboid(header_size, anchor=BOTTOM);
            right(opening_size.x / 2 - header_size.x / 2) back(-1) cuboid(header_size, anchor=BOTTOM);
          }
          attach([BACK], overlap=1) {
            left(opening_size.x / 2 - header_size.x / 2) back(-1) cuboid(header_size, anchor=BOTTOM);
            right(opening_size.x / 2 - header_size.x / 2) back(-1) cuboid(header_size, anchor=BOTTOM);
          }
        }
  }
}

module prismoidal(size=[100,100,100], scale=0.5, anchor=CENTER, spin=0, orient=UP) {
    attachable(anchor,spin,orient, size=size, size2=[size.x, size.y]*scale) {
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