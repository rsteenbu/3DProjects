include <BOSL2/std.scad>;
include <BOSL2/screws.scad>;
include <BOSL2/metric_screws.scad>;
include <my-general-libraries.scad>;

lip_height=1;
face_depth=5;


enclosure_size = [145, 80, 35];
//faceplate_height = 18;
wall_width = 2;
overlap = 1;
enclosure_stuff = "LCD+PIR";
faceplate_component_margin=10.5;
tolerance = .15;
screwpost_hole_size = 1.8;
screwpost_diameter = 5;


//faceplate_v2(enclosure_size);

/*
diff("components", "clip") cuboid([120, 70, 4], edges=[BOTTOM], anchor=BOTTOM)
  attach([TOP], overlap=overlap) {
//      xrot(180) pir();
//      fwd(30) lcd_2x16();
      back(0) lcd_4x20();
  }
*/

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
      right(45) back(20) zrot(90) lcd_2x16();
      right(45) fwd(60) xrot(180) pir();
      tag("components") {
        back(15) right(10) cuboid([15, 34, 3])
	  attach(BOTTOM, overlap=1)  {
	    fwd(6) cuboid([2,1,2], anchor=BOTTOM);
	    cylinder(h=7, r=7.1/2, $fn=45, anchor=BOTTOM);
	  }
        fwd(45) left(20) down(4) 
	for (x=[0,5,10,15,20,25,30,35]) {
	  left(x) cuboid([1, 50, 6], anchor=BOTTOM);
	}
        back(65) right(15) down(4) 
	  for (x=[0,5,10]) {
	    left(x) cuboid([1, 25, 6], anchor=BOTTOM);
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



