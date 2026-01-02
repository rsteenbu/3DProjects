include <BOSL2/std.scad>;
include <BOSL2/screws.scad>;
include <powersupply-mount.scad>;
include <box-connectors.scad>;
include <pcb-mount.scad>;
include <my-general-libraries.scad>;

use_mounting_tabs = true;
use_outdoor_connectors = true;
// not sure- it moves the connector openings over for JST sizes.
led_connector = "JST";

wall_width = 3;
overlap = 1;
post_hole_size = 1.8;
tolerance = .15;
lip_width = 3;
lip_height = 2;
lcd_enabled = false;
pir_enabled = true;
encoder_enabled = false;
vents_enabled = false;
screwhead_faceplate = true;

// faceplate stuff
face_depth=12;
screwpost_diameter = 5;
screwpost_hole_size = 1.8;

faceplate_component_margin=10.5;
connector_pos_from_edge = 13;
faceplate_depth = 18;
 
    //zrot(180) translate([3.3,-10,0]) pcb_mount("wasatch8", pcb_height=4);
// 15w, 50w, 50w-2, 100w, 150w, RACM90, none, wasatch8, ssr, 8x-irrigation
enclosure_type = "ssr";

size_index = 1;
pcb_details = 2;
pcb_name = 0;
pcb_position = 1;
pcb_rotx = 2;
pcb_height = 3;

enclosure_configs = [
//   type_name,       [size],         [[pcb,     pcb position] rot, height]
    ["none",          [100, 100, 30], [["70x50",    [0,0],       0,  7]]],
    ["RACM90",        [145, 180, 35], [["70x50",    [0,-40],     90, 7]]],
    ["15w",           [100, 180, 32], [["70x50",    [0,60],      90, 7], 
                              ["beefcake_relay",    [30,-20],    0,  7]]],
    ["50w",           [145, 180, 35], [["70x50",    [-31,-45],   0,  7],
                                       ["70x50",    [31,-45],    0,  7]]],
    ["100w",          [175, 200, 35], [["70x50",    [-50,-30],   0,  7],
                              ["beefcake_relay",    [-45,70],   90,  7]]],
    ["150w",          [175, 210, 35], [["70x50",    [-52,-32],   0,  7],
                              ["beefcake_relay",    [-45,80],   90,  7]]],
    ["wasatch8",      [150, 150, 35], [["wasatch8", [3.3,-10,0], 0,  4]]],
    ["ssr",           [57, 95, 50],   [["70x50",    [0,0],       0,  35]]],
    ["8x-irrigation", [82, 120, 55],  [["70x50",    [0,0],       0,  7]]]
];

// Function to get configuration for a given enclosure type
function get_enclosure_config(type, configs=enclosure_configs) =
    let(matches = [for(c=configs) if(c[0]==type) c])
    len(matches) > 0 ? matches[0] : undef;

// Get current configuration
config = get_enclosure_config(enclosure_type);
enclosure_size = config[1];
spacing = enclosure_size.x + 20;

//pcb_size      = get_pcb_size(config[3]);

print_enclosure = false;
print_faceplate = true;
print_faceplate_seal = true;

// Generate enclosure parts
xdistribute(spacing=spacing) {
    if (print_enclosure) backplate(enclosure_size);
    if (print_faceplate) faceplate([enclosure_size.x, enclosure_size.y, faceplate_depth]);
// need to change the logic so they are close together no matter what's being printed
    if (print_faceplate_seal) color("grey") faceplate_seal([enclosure_size.x, enclosure_size.y]);
}

module faceplate_seal(size) {
  seal_height = 1;
  for(n = [1, -1]) {
    // y lips
    translate([0, (size.y/2 - wall_width/2) * n, 0])
      cuboid([size.x - 2,  1, seal_height], anchor=BOTTOM);
    // x lips
    translate([(size.x/2 - wall_width/2) * n, 0, 0])
      cuboid([1, size.y - 2, seal_height], anchor=BOTTOM);
  }
}

module mounting_tabs(mounting_hole_distance_apart) {
  for(x = [1, -1]) {
    move([(mounting_hole_distance_apart / 2) * x, 0, -2])
      diff("screwhole") prismoidal([16,wall_width,14],BOTTOM)
          attach([FRONT], overlap=3) back(1) tag("screwhole") cylinder(h=5, r=2.2, anchor=BOTTOM, $fn=45);
  }
}

// ============================================================================
// WALL FEATURES - Enclosure-specific connectors and holes for each wall
// ============================================================================

module back_wall_features(size) {
  if (enclosure_type == "100w") attach(FRONT, overlap=4) {
    tag("holes") {
      translate([size.x/2-35, 0, -2]) {
        c14_plug_v2([27,19,9]);
        left(40) cylinder(h=9, r=6.25, anchor=BOTTOM);
      }
    }
  }
  if (enclosure_type == "ssr") {
    attach(BACK, overlap=1)
    tag("holes") {
      translate([0, 0, 0]) nema5_15R_female(wall_width*2+1);
    }
  }
}

module front_wall_features(size) {
  if (enclosure_type == "50w" || enclosure_type == "100w") {
    attach(BACK, overlap=.5) {
      translate([size.y/2 - 33, 6, 0]) connector(3_pin_connector_size, anchor=FRONT);
      translate([size.y/2 - 53, 6, 0]) connector(3_pin_connector_size, anchor=FRONT);
    }
  }

  if (enclosure_type == "15w") {
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
  }

  if (enclosure_type == "none") {
    tag("holes") {
      translate([27, 0, -2]) cylinder(h=5, r=7.75, anchor=BOTTOM, $fn=45);
      translate([0, 0, -2]) cylinder(h=5, r=7.75, anchor=BOTTOM, $fn=45);
      translate([-27, 0, -2]) cylinder(h=9, r=6, anchor=BOTTOM, $fn=45);
    }
  }

  if (enclosure_type == "ssr") {
    attach(BACK, overlap=1)
    tag("holes") {
      translate([0, 0, -3]) zrot(0) c14_plug_v2();
    }
  }
}

module left_wall_features(size) {
  if (enclosure_type == "50w") {
    attach(RIGHT, overlap=2)
    tag("holes") translate([size.y/2-33, 0, -2]) c14_plug_v2();
  }

  if (enclosure_type == "RACM90") {
    attach(RIGHT, overlap=2)
    tag("holes") translate([(-size.y/2) + 33 , 0, -2]) c14_plug_v2([27,19,7]);
  }

  if (enclosure_type == "wasatch8") {
    attach(RIGHT, overlap=2)
    // Power cord
    tag("holes") {
      //ethernet
      //translate([0, -5, 2]) cuboid([16,14,7]);
      translate([10, -5, 2]) cuboid([16,14,7]);
      //Switch
      //translate([-37, 0, 2]) cuboid([10.5, 7, 28.6]);
      translate([-57, 0, 2]) cuboid([10.5, 28.6, 7]);
      //Power
      translate([-37.5, 0, 1]) {
        for(y = [1, -1]) translate([0, 12.5*y, -3]) cylinder(r=1.5, h=6, $fn=20);
        cuboid([12,19,6]);
      }
    }
  }
}

module right_wall_features(size) {
  if (enclosure_type == "50w") {
    attach(LEFT, overlap=.5)
    translate([size.y/2 - 23, 6, 0]) connector(3_pin_connector_size, anchor=FRONT);
  }

  if (enclosure_type == "wasatch8") {
    attach(LEFT, overlap=-1.5) {
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
}

module place_pcbs(config) {
    for (pcb_details_index = [ 0 : len(config[pcb_details]) - 1])
      translate(config[pcb_details][pcb_details_index][pcb_position]) 
	zrot(config[pcb_details][pcb_details_index][2]) 
	  pcb_mount(config[pcb_details][pcb_details_index][pcb_name], 
	            config[pcb_details][pcb_details_index][pcb_height]);
}         
          
// ============================================================================
// COMPONENT MOUNTING - PCB and PSU mounts for different enclosure types
// ============================================================================
module component_mounts_for_enclosure(size) {
  place_pcbs(config);

  if (enclosure_type == "ssr") {
    // solid state relay on the bottom
    ssr_mount("EARU-ssr");
  }

  if (enclosure_type == "RACM90") {
    translate([2,44]) RACM90_psu_mount();
  }

  if (enclosure_type == "15w") {
    translate([-18.1, 0]) zrot(90) MW_RS15_psu_mount();
  }

  if (enclosure_type == "50w") {
      translate([13,43]) MW_LRS50_psu_mount();
  }

  if (enclosure_type == "100w") {
      translate([33,-30]) zrot(270) MW_LRS100_psu_mount();
  }

  if (enclosure_type == "150w") {
    translate([33,-20]) zrot(270) MW_LRS150_psu_mount();
  }
}

// ============================================================================
// INNER LIPS - Creates the lip structure around the inner perimeter
// ============================================================================

module create_inner_lips(size, inner_lip_height) {
//  back(size.y / 2 + wall_width/2 - (wall_width*2 + tolerance))
//    cuboid([size.x - 2*(wall_width + tolerance), wall_width, inner_lip_height], anchor=BOTTOM);
//  fwd (size.y / 2 + wall_width/2 - (wall_width*2 + tolerance))
//    cuboid([size.x - 2*(wall_width + tolerance), wall_width, inner_lip_height], anchor=BOTTOM);
//  left(size.x / 2 + wall_width/2 - (wall_width*2 + tolerance))
//    cuboid([wall_width, size.y - 2*(wall_width+tolerance), inner_lip_height], anchor=BOTTOM);
//  right(size.x / 2 + wall_width/2 - (wall_width*2 + tolerance))
//    cuboid([wall_width, size.y - 2*(wall_width+tolerance), inner_lip_height], anchor=BOTTOM);
}

// ============================================================================
// BACKPLATE - Main enclosure backplate with walls, mounting features, and components
// ============================================================================

module backplate(size) {
  inner_lip_height = size.z + lip_height - tolerance + overlap;

  diff("holes") cuboid([size.x, size.y, wall_width], anchor=BOTTOM) {
    // Mounting tabs on left and right edges
    attach([LEFT], overlap=1)
      if (use_mounting_tabs) mounting_tabs(size.y - 60);
    attach([RIGHT], overlap=1)
      if (use_mounting_tabs) mounting_tabs(size.y - 60);

    attach([TOP], overlap=overlap) {
      // Back wall (outer lip)
      back(size.y / 2 - (wall_width + tolerance)/2) {
        cuboid([size.x, wall_width + tolerance, size.z+overlap], anchor=BOTTOM)
          back_wall_features(size);
        up(size.z+1) cuboid([size.x - 2 - tolerance, 1, 1+overlap]);
      }

      // Front wall (outer lip)
      fwd(size.y / 2 - (wall_width + tolerance)/2) {
        cuboid([size.x, wall_width+tolerance, size.z+overlap], anchor=BOTTOM)
          front_wall_features(size);
        up(size.z+1) cuboid([size.x - 2 - tolerance, 1, 1+overlap]);
      }

      // Left wall
      left(size.x / 2 - (wall_width + tolerance)/2) {
        cuboid([wall_width+tolerance, size.y, size.z+overlap], anchor=BOTTOM)
          left_wall_features(size);
        up(size.z+1) cuboid([1, size.y - 2 - tolerance, 1+overlap]);
      }

      // Right wall
      right(size.x / 2 - (wall_width + tolerance)/2) {
        cuboid([wall_width+tolerance, size.y, size.z+overlap], anchor=BOTTOM)
          right_wall_features(size);
        up(size.z+1) cuboid([1, size.y - 2 - tolerance, 1+overlap]);
      }

      // Inner lip around perimeter
      create_inner_lips(size, inner_lip_height);

      // Screwposts in four corners
      four_screwposts(size, inner_lip_height, screwhead_faceplate, BOTTOM);

      // Enclosure-specific component mounts (PSUs, PCBs, etc.)
      component_mounts_for_enclosure(size);
    }
  }
}


module faceplate(size) {
  diff("holes") cuboid([size.x, size.y, 4], chamfer=1, edges=[BOTTOM], anchor=BOTTOM) {
    attach([TOP], overlap=overlap) {
      for(n = [1, -1]) {
	translate([0, (size.y/2 - wall_width/2) * n, 0]) {
	    cuboid([size.x, wall_width, size.z - face_depth + overlap], anchor=BOTTOM);
            // sealing lip
	    up(size.z - face_depth - 1 ) tag("holes") 
	      cuboid([size.x - wall_width/2 - tolerance, 
	              1 + tolerance * 2, 
		      1 + overlap + .9], 
		     anchor=BOTTOM);
	}
	translate([(size.x/2 - wall_width/2) * n, 0, 0]) {
	  cuboid([wall_width, size.y, size.z - face_depth + overlap], anchor=BOTTOM);
	  // sealing lip
	  up(size.z - face_depth - 1 ) tag("holes") 
	    cuboid([1 + tolerance * 2 + .05, 
	            size.y - wall_width/2 - .5, 
		    1 + overlap + .9],
		   anchor=BOTTOM);
	}
      }
    }
    attach([TOP], overlap=overlap) {
      four_screwposts(size, size.z-face_depth+overlap, !screwhead_faceplate, TOP);
    }
    attach([TOP], overlap=overlap) {
      if (lcd_enabled) right(45) back(20) zrot(90) lcd_2x16();
      //if (pir_enabled) right(45) fwd(60) xrot(180) pir();
      if (pir_enabled) xrot(180) pir();

      tag("holes") {
        if (encoder_enabled) back(15) right(10) cuboid([15, 34, 3])
	  attach(BOTTOM, overlap=1)  {
	    fwd(6) cuboid([2,1,2], anchor=BOTTOM);
	    cylinder(h=7, r=7.1/2, $fn=45, anchor=BOTTOM);
	  }
	// vents
	if (vents_enabled) {
	  left(25) down(4) 
	    for (x=[0:3:45]) {
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
    up(pir_inset_depth) tag("holes") cuboid(pir_size, anchor=BOTTOM) {
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
  tag("holes") down(5.0) {
    cuboid(size, anchor=BOTTOM) 
    attach(RIGHT,BOTTOM, overlap=.1) {
      back(1.5) prismoidal([12,4,4]);
    }
    translate([-(size.x/2 - header_size.x/2 - 3), -(size.y/2 + header_size.y/2 + 1.5), 3]) cuboid(header_size, anchor=BOTTOM);
  }
  fwd(1.4)
  for(x = [1, -1]) {
    for(y = [1, -1]) {
      move([(size.x/2 + 1.5) * x, (size.y/2 + 3) * y]) screw("M3", length=6, anchor=BOTTOM); 
    }
  }
}

module lcd_4x20() {
  size=[97,40,8];
  header_size = [42,4,5];
  tag("holes") down(5.0) {
    cuboid(size, anchor=BOTTOM);
    translate([-size.x/2 + header_size.x/2 + 7, -size.y/2 - header_size.y/2 - 6, 3]) cuboid(header_size, anchor=BOTTOM);
  }
  for(x = [1, -1]) {
    for(y = [1, -1]) {
      move([(size.x/2 - 1.75) * x, (size.y/2 + 7.75) * y]) screw("M3", length=6, anchor=BOTTOM); 
    }
  }
}

module four_screwposts(size, inside_depth, nut_hole, anchor) {
      screwhole_xpos = size.x / 2 - (wall_width+tolerance) - wall_width  - 0;
      screwhole_ypos = size.y / 2 - (wall_width+tolerance) - wall_width  - 0;
      screwpost_positions = [ [screwhole_xpos, screwhole_ypos, 0],
                              [-screwhole_xpos, screwhole_ypos, 90],
                              [-screwhole_xpos, -screwhole_ypos, 180],
                              [screwhole_xpos, -screwhole_ypos, 270] ];
      for (a = [ 0 : len(screwpost_positions) - 1 ]) {
	point=screwpost_positions[a];
	translate([point[0],point[1],0]) {
	  rotate(point[2]) screwposts(inside_depth, nut_hole);
	  if (!nut_hole) tag("holes") { 
	      up(5) cylinder(h=10, r=screwpost_hole_size, $fn=45, anchor=anchor);
	      if (anchor == TOP) 
	       cylinder(h=inside_depth-3, r=screwpost_hole_size+2, $fn=45, anchor=anchor);
	      if (anchor == BOTTOM) 
	       up(-2) cylinder(h=inside_depth-3, r=screwpost_hole_size+2, $fn=45, anchor=anchor);
	  }
	}
      }
}

module screwposts(inside_depth, nut_hole) {
  diff("screwholes") {
    if (nut_hole) { 
      up(inside_depth-lip_height-7)
        cylinder(h=7+tolerance, r=screwpost_diameter, anchor=BOTTOM, $fn=45);
    } else {
        cylinder(h=inside_depth-lip_height, r=screwpost_diameter, anchor=BOTTOM, $fn=45);
    }

    tag("screwholes") cylinder(h=inside_depth, r=screwpost_hole_size, $fn=45, anchor=BOTTOM)
      if ( nut_hole ) {
      attach([LEFT+FRONT]) {
	fwd(-inside_depth/2 + 4.9) down(1) cuboid([5.5,2.1,9]);
      }
    }
  }
}



