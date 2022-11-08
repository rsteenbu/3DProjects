include <BOSL2/std.scad>;
include <BOSL2/metric_screws.scad>;
include <BOSL2/screws.scad>;

post_hole_size = 1.8;
wall_width = 2;
margin=10.5;
gap=22;
lcd_size=[72,25,8];
pir_size=[25,34,4];

print_enclosure = true;
print_backplate = true;

// LCD, PIR, LCD+PIR
enclosure_stuff = "LCD+PIR";
x = (enclosure_stuff == "LCD+PIR") ? lcd_size.x + pir_size.x + gap + margin * 2:
    (enclosure_stuff == "LCD")     ? lcd_size.x + gap + margin * 2:
    (enclosure_stuff == "PIR")     ? pir_size.x + gap + margin * 2:140;


ydistribute(spacing=90) {
  if (print_enclosure) lcd2_16_enclosure([x,55,20]); 
  if (print_backplate) down(1) backplate([x,55,2]); 
}

module backplate(size) {
   tolerance = .15;
   lip_width = 3;
   lip_height = 3;
   inner_lip_height = size.z + lip_height - tolerance;
   screwpost_size = 7;
   
   diff("holes")
   cuboid([size.x, size.y, wall_width]) {
      attach([BOTTOM]) {
        // outer lip
        back(size.y / 2 - (wall_width + tolerance)/2) cuboid([size.x, wall_width+tolerance, size.z], anchor=BOTTOM);
        fwd (size.y / 2 - (wall_width + tolerance)/2) cuboid([size.x, wall_width+tolerance, size.z], anchor=BOTTOM);
        left(size.x / 2 - (wall_width + tolerance)/2) cuboid([wall_width+tolerance, size.y, size.z], anchor=BOTTOM);
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
      }
      attach([TOP]) {
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

module lcd2_16_enclosure(size) {
  diff("inside")
  cuboid(size, chamfer=5, edges=[TOP], anchor=TOP) {
    tag("inside") { 
      attach([TOP], overlap=21) {
        inside_space([size.x-wall_width*2,size.y-wall_width*2,15]);
        
        //backplate screwholes
        // [1,1] [1,-1] [-1,-1] [-1,1]
        //  0      90    180    270
        screwhole_xpos = size.x / 2 - wall_width - 2.5;
        screwhole_ypos = size.y / 2 - 5.5;
        move([screwhole_xpos, screwhole_ypos, -2]) rotate(0) backplate_screwholes();
        move([screwhole_xpos * -1, screwhole_ypos, -2]) rotate(90) backplate_screwholes();
        move([screwhole_xpos * -1, screwhole_ypos * -1, -2]) rotate(180) backplate_screwholes();
        move([screwhole_xpos, screwhole_ypos * -1, -2]) rotate(270) backplate_screwholes();
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

module inside_space(inside_size) {
  diff("screwholes")
  cuboid(inside_size, anchor=BOTTOM) 
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
              move([screwhole_xpos * x, screwhole_ypos * y, -10]) cylinder(h=13, r=5);
            }
          }
          for(y = [1, -1]) {
            move([-pir_pos, 14.5*y, 0]) screw("M2", length=6, anchor=BOTTOM);
          }
        }
      }
    }
}

module lcd2_16() {
  cuboid(lcd_size, anchor=BOTTOM) 
    attach(RIGHT,BOTTOM) {
      back(-2.5) prismoidal([12,3,4]);
    }
    back(16) left(13) cuboid([40,4,5], anchor=BOTTOM);
}

module pir() {
  opening_size=[24.5,24.5,5];
  header_size=[8,2,5.5];
  cuboid(pir_size, anchor=BOTTOM) {
    attach([BACK], overlap=1) cylinder(r=4, h=pir_size.z, spin=[90,0,0], anchor=CENTER);
    attach([FRONT], overlap=1) cylinder(r=4, h=pir_size.z, spin=[90,0,0], anchor=CENTER);
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