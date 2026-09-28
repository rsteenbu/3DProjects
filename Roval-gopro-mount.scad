include <GoPro_Mount.scad>

offset=.5;
diskHeight=3;
$fn = 50; // Smoothness
screw_rad = 3.2 / 2; // M3 clearance
head_rad = 8.0 / 2; // Head diameter + tolerance
head_height = 2.0; // Depth of inset
total_height = 20;


difference() {
    difference() {
      union() {
        translate([0, 0, 13])
            rotate([0, 90, 0])
                    mount3();
        // base
        cylinder(h=diskHeight, r=16);
      }

        for (x = [1, -1]) {
          translate([-7.0, 10.00 * x, diskHeight-2]) {
           rotate([00, -30, -50 * x]) color("LightBlue")
             cylinder(h=10, r=4.3, center=false);
          }
        }
        translate([10,0, -offset])
          cylinder(h=10, r=3.9, center=false);

    }
}
        /*
        translate([-7,-10,-offset]) {
            color("LightBlue") cylinder(h=diskHeight + .75, r=screw_rad);
            translate([0,0,diskHeight - head_height + offset + .1])
             color("LightBlue") cylinder(h=head_height, r1=screw_rad, r2=head_rad);
        }
        translate([-7,10,-offset]) {
            color("LightBlue") cylinder(h=diskHeight + .75, r=screw_rad);
            translate([0,0,diskHeight - head_height + offset + .1])
             color("LightBlue") cylinder(h=head_height, r1=screw_rad, r2=head_rad);
        }
        translate([10,0,-offset]) {
            color("LightBlue") cylinder(h=diskHeight + .75, r=screw_rad);
            translate([0,0,diskHeight - head_height + offset + .1])
              color("LightBlue") cylinder(h=head_height, r1=screw_rad, r2=head_rad);
        }
    }
}

/*
difference() {
  cylinder(h=diskHeight, r=16);
  union() {
    translate([-7,-10,-offset]) {
        color("LightBlue") cylinder(h=diskHeight + .75, r=screw_rad);
        translate([0,0,diskHeight - head_height + offset + .1])
         color("LightBlue") cylinder(h=head_height, r1=screw_rad, r2=head_rad);
    }
    translate([-7,10,-offset]) {
        color("LightBlue") cylinder(h=diskHeight + .75, r=screw_rad);
        translate([0,0,diskHeight - head_height + offset + .1])
         color("LightBlue") cylinder(h=head_height, r1=screw_rad, r2=head_rad);
    }
    translate([10,0,-offset]) {
        color("LightBlue") cylinder(h=diskHeight + .75, r=screw_rad);
        translate([0,0,diskHeight - head_height + offset + .1])
          color("LightBlue") cylinder(h=head_height, r1=screw_rad, r2=head_rad);
    }
}

*/
