$fn=50;
difference() {
  translate([1,1]) color("green", 0.5) minkowski() {
    cube([18,18,2.5]);
    cylinder(1);
  }
  translate([6.75,5,-1])    cylinder(h=5, r=1.5/2);
  translate([4.5,10,-1]) oblongHole(6);

  translate([13.25,5,-1]) cylinder(h=5, r=1.5/2);
  translate([15,10,-1])  oblongHole(6);
}

module oblongHole(len) {
      union() {
//	//outer hole
//	translate([0,0,1+6.5-3]) {
//	  cylinder(h=4, r=5.5/2);
//	  translate([-5.5/2,0]) cube([5.5,len,4]);
//	  translate([0,len]) cylinder(h=4, r=5.5/2);
//	}	

	//inner hole
	cylinder(h=8, r=3/2);
	translate([-3/2,0]) cube([3,len,8]);
	translate([0,len]) cylinder(h=8, r=3/2);
      }


}
