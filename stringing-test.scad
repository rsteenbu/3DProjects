

/*
translate([0,0,0]) {
  cube([38,10,1.5], center=true);
  translate([13, 0, 0]) cylinder(h=20, r1=2.5, r2=.5, $fn=45);
  translate([-13, 0, 0]) cylinder(h=20, r1=2.5, r2=.5, $fn=45);
}
*/

translate([0,20,0]) {
  cube([38,10,1], center=true);
  translate([13, 0, 0]) cylinder(h=8, r=2, $fn=45);
  translate([-13, 0, 0]) cylinder(h=8, r=2, $fn=45);
}

