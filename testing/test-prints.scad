//use </Users/rsteenbu/3D_Prints/repots/MCAD/involute_gears.scad>;
//use </Users/rsteenbu/3D_Prints/repots/MCAD/servos.scad>;
//use <utility.scad>;
include <BOSL2/std.scad>;
include <BOSL2/metric_screws.scad>;
include <BOSL2/screws.scad>;

//generic_screw(screwsize=3,screwlen=10,headsize=6,headlen=2, anchor="countersunk");
//metric_nut(size=10, hole=true, pitch=1.5);
//metric_nut(size=10, hole=true, pitch=1.5, flange=3, details=true, anchor=BOTTOM);

xdistribute(spacing=150){

   lcd2_16_enclosure([130,55,20], 5); 
  
   //pir([33,25,4]);
}

module backplate_screwholes() {
  cylinder(15, r=1.5)
    attach([LEFT+FRONT]) {
        back(3) down(0) cuboid([3.2,1.6,6]);
    }
}

module lcd2_16_enclosure(size=[100,100,100], wall_width=100) {
  diff("lcd")
  cuboid(size, chamfer=5, edges=[TOP], anchor=BOTTOM)
    attach([TOP], overlap=21) {
      tag("lcd") { 
        inside_space([size.x-wall_width,size.y-wall_width,15]);
        
        //backplate screwholes
        move([59.5,22.5,-2]) rotate(0) backplate_screwholes();
        move([-59.5,22.5,-2]) rotate(90) backplate_screwholes();
        move([-59.5,-22.5,-2]) rotate(180) backplate_screwholes();
        move([59.5,-22.5,-2]) rotate(270) backplate_screwholes();
      }
    }
}

module inside_space(inside_size=[100,100,100], lcd_size=[72,25,8]) {
  diff("screwholes")
  cuboid(inside_size, anchor=BOTTOM) show_anchors(3)
    right(16)
    attach([TOP], overlap=1) {
      cuboid(lcd_size, anchor=BOTTOM) 
        attach(RIGHT,BOTTOM) {
        back(-2.5) prismoidal([12,3,4], scale=.5);
        }
      back(16) left(13) cuboid([40,4,5], anchor=BOTTOM);

      left(65) rotate(90) pir([33,25,4]);

      tag("screwholes") {
        //Backplate
        back(23) left(76) down(7.9) cylinder(10, r=4);
        back(-23) left(76) down(7.9) cylinder(10, r=4);
        back(23) right(44) down(7.9) cylinder(10, r=4);
        back(-23) right(44) down(7.9) cylinder(10, r=4);

        //LCD
        back(15.5) right(37.5) down(7.9) screw("M3", length=9);
        back(-15.5) right(37.5) down(7.9) screw("M3", length=9); 
        back(15.5) left(37.5) down(7.9) screw("M3", length=9);
        back(-15.5) left(37.5) down(7.9) screw("M3", length=9);

        //PIR
        //back(0) left(40.5) down(2) screw("M2", length=9);
        //back(0) left(69.5) down(2) screw("M2", length=9);
        back(14.5) left(65) down(2) screw("M2", length=9);
        back(-14.5) left(65) down(2) screw("M2", length=9);
      }
    }
}

module lcd_2_16() {
  
}

module pir(size=[35,25,4], header_pos=[14,9], header_size=[5,7,2]) {
  cuboid(size, anchor=BOTTOM)
    attach([TOP], overlap=1) {
      //cylinder(5,r=11.6);
      cuboid([25,25,5], anchor=BOTTOM);

      //back(9) left(14) cuboid([5,7,2], anchor=BOTTOM);
      for(x=[1,-1])
        for(y=[1,-1])
          move([header_pos.x*x,header_pos.y*y]) cuboid(header_size, anchor=BOTTOM);
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
    
/*
  diff("hole")
  cube(10, anchor=TOP)
    tag("hole")screw("M6", length=11, thread="fine", anchor=TOP,  head="none");

    
  minkowski() {
    union() {
	    cube([100,33,33], center=true);
	    cube([33,100,33], center=true);
	    cube([33,33,100], center=true);
    }
    sphere(r=8);
  }

    
  diff("hole1", "keep")
  tag("keep")cube(100, center=true)
    attach([RIGHT,TOP]) {
        tag("") cylinder(d=95, h=25);
        tag("hole1") cylinder(d=50, h=51, anchor=CTR);
    }

  //this is equivalent?
  diff("hole2")
  cube(100, center=true)
    attach([RIGHT,TOP]) {
        cylinder(d=95, h=25);
        tag("hole2") cylinder(d=50, h=51);
    }

  diff("hole3")
  cube(100, center=true)
     attach([FRONT,TOP], overlap=20)
         tag("hole3") {
             cylinder(h=20.1, d1=0, d2=95);
             down(10) cylinder(h=30, d=30);
         };

  diff("hole4")
  cuboid(50)
    attach(TOP)
      force_tag("hole4")
        rotate_extrude(angle=360)
          right(15)
          square(15, center=true);

  diff("hole5")
  cube(50, 50, 100)
    attach(TOP)
      force_tag("hole5")
        rotate_extrude(angle=270)
          left(15)
          rectangle(15, 30, anchor=TOP);
*/



//nutHole(4, proj=1);
//boltHole(4, length=30, proj=1);
//roundedCube(200, 20, true, true);
/*
gear (circular_pitch=300,
  gear_thickness = 12,
  rim_thickness = 80,
  hub_thickness = 30,
  circles=8);
*/