overlap = .1;


difference() {
  cube([9,20,3], center=true);
  translate([0,4,0]) cylinder(h=5, r=1.75, center=true, $fn=100);
  translate([0,4,2]) sphere(3.5, $fn=100);
}
translate([0,-5.5,-5]) cube([9,3,10], center=true);
translate([0,-10.5,.5]) cube([9,3,4], center=true);

