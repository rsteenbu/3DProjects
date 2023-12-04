include <my-general-libraries.scad>;
include <pcb-mount.scad>;
include <BOSL2/screws.scad>;

cuboid([60, 80, 2], anchor=BOTTOM)
  attach(TOP, overlap=1) ssr_mount();

//translate([50, 0, 0]) 
////  for (y=[0,20]) translate([0,y,0]) ssr_nut();


