// Remix of http://www.thingiverse.com/thing:806093

//Clip thickness
CLIP_H = 8;
// Holes diameter
HOLE_DIAMETER = 2.9;
// Distance between the 2 holes
//PILLAR_PITCH = 62.23;
PILLAR_PITCH = 45.00;

// Height of the mounting bar
MOUNT_H = 5;
// Height of pillars
PILLAR_H = 2;

PILLAR_1_Y_OFFSET = PILLAR_PITCH/2;
PILLAR_2_Y_OFFSET = -PILLAR_PITCH/2;

bolt_hole = [2,5.6,8];

module shape()
{
    p = [
    [9.40,21.09], // back top of flex clip nose
    [9.58,20.85],
    [9.59,20.55],
    [9.43,20.31],

    [5.76-.6,17.15], // nose of flex clip
    [5.50-.6,17.12],
    [5.35-.6,17.35],
    [5.35-.6,19.25],

    [-5.30,19.25], // dip of flex clip
    [-5.65,19.10],
    [-5.77,18.76],
    [-5.65,18.42],
    [-5.30,18.26],

    [2.87,18.26], // inside of flex clip
    [3.25,18.19],
    [3.57,17.98],
    [3.78,17.66],
    [3.85,17.28],

    [3.85,-16.05], //inside back for solid clip
    [5.35-.6,-16.05],

    [6.38-.6,-12.50], //nose of solid clip
    [6.75-.6,-12.09],
    [7.27-.6,-11.94],
    [7.82-.6,-11.94],

    [8.17,-12.08],

    [8.31,-12.43],
    
    [8.31,-16.21],
    [8.16,-18.97],
    [7.74,-19.61],
    [7.10,-20.03],
    [6.34,-20.18],
    [-9.59,-21.18],
    [-9.59,21.18],
    [9.12,21.18]];
    
    xm = min([ for (x=p) x[0] ]);
    ym = min([ for (x=p) x[1] ]); 
    echo([xm, ym]);
    translate([0,22.183,0]) // This offset is know by displaying 
                            // DXF file a CAD software
        rotate([180,0,0])
            translate([-xm, -ym])
                polygon(p);
}

module din_clip() {

	difference() {
		
	union() {
            linear_extrude(height=CLIP_H, center=true, convexity=5) {
                //import(file="PCB_din_clip.dxf", $fn=64);
		shape();
            }
		      
            translate([-MOUNT_H/2, 0, 0]) {
                cube([MOUNT_H,PILLAR_PITCH+10,CLIP_H], center=true);
            }
            
            translate([-PILLAR_H/2-MOUNT_H, PILLAR_1_Y_OFFSET, 0]) {
				rotate([0, 0, 0]) {
					cube([PILLAR_H,10,CLIP_H], center = true);
				}
            }

            translate([-PILLAR_H/2-MOUNT_H, PILLAR_2_Y_OFFSET, 0]) {
				rotate([0, 0, 0]) {
					cube([PILLAR_H,10,CLIP_H], center = true);
				}
            }
	}

	union() {
		translate([-PILLAR_H-MOUNT_H-0.5, PILLAR_2_Y_OFFSET, 0]) {
			rotate([0, 90, 0]) {
				cylinder(h= PILLAR_H+MOUNT_H+1, r = HOLE_DIAMETER / 2, $fn = 16);
			}
		}
		translate([-PILLAR_H-MOUNT_H+2.5, PILLAR_2_Y_OFFSET-bolt_hole.y/2, -(bolt_hole.z-4.4)]) {
			cube(bolt_hole);
		}

		translate([-PILLAR_H-MOUNT_H-0.5, PILLAR_1_Y_OFFSET, 0]) {
			rotate([0, 90, 0]) {
				cylinder(h= PILLAR_H+MOUNT_H+1, r = HOLE_DIAMETER / 2, $fn = 16);
			}
		}
		translate([-PILLAR_H-MOUNT_H+2.5, PILLAR_1_Y_OFFSET-bolt_hole.y/2, -(bolt_hole.z-4.4)]) {
			cube(bolt_hole);
		}
	}
    }
}

din_clip();


