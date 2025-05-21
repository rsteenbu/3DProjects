difference() {
  color("green", 0.5) cube([20,20,6.5]);
  translate([5,3,6.5-4])  { 
    cylinder(h=5, r=4.5/2, $fn=100);
    translate([0,7,-3.5]) oblongHole(6);

    translate([9.5,0]) { 
      cylinder(h=5, r=4.5/2, $fn=100);
      translate([0,7,-3.5]) oblongHole(6);
    }
  }
  //translate([5,10,-1]) oblongHole(6);
}


module oblongHole(len) {
      union() {
	//outer hole
	translate([0,0,1+6.5-3]) {
	  cylinder(h=4, r=5.5/2, $fn=100);
	  translate([-5.5/2,0]) cube([5.5,len,4]);
	  translate([0,len]) cylinder(h=4, r=5.5/2, $fn=100);
	}	

	//inner hole
	cylinder(h=8, r=3/2, $fn=100);
	translate([-3/2,0]) cube([3,len,8]);
	translate([0,len]) cylinder(h=8, r=3/2, $fn=100);
      }


}
