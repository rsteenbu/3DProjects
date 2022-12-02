//Cross support for PCB 
//
//(C)Lars Christian Nygård - lars@snart.com
// This file is licened under 
// Creative Commons Attribution 4.0 International (CC BY 4.0)
// https://creativecommons.org/licenses/by/4.0/
//
//version 0.2
//0.1 - initial release
//0.2 - fixed dimesional errors for edge distances.
//    - changed show pcb from blue to debug symbol.
//    - some code cleanup
//0.2b - fixed debug sign breaking the lower right base.
// - to do list: Make parameters nice for thingiverse customizer.


Board_holders=true; // [true:show PCB,false:hide PCB]
Show_PCB=true;
Sentral_support=true;
Screw_plate=true;
X=70.00;
Y=90.13;
D=4;
DP=2.5; //peg diameter
SH=0; //Hole in rod for screw
RH=6;//Rod height
PCH=1.5; //PCB thickness
Ex1=1.2; //Distance from edge to hole
Ex2=1.25;
Ey1=1.3;
Ey2=1.4;
BH=2; //Beam height

// Dont change these
R=D/2; //Rod radius
RP=DP/2; //Peg radius

//Cube to visualize board.
if(Show_PCB) {
    translate([0,0,RH+(PCH-(PCH/2))])%cube([X,Y,PCH-0.1], center=true); //color("blue")
}
//Support rods with pegs
translate([-X/2,-Y/2,0])for (y=[RP+Ey1,Y-RP-Ey2])
for(x=[RP+Ex1,X-RP-Ex2])translate ([x,y,0])
    { 
    cylinder(h=RH,d=D,$fn=45);
    difference()
        {
        cylinder(h=RH+PCH,d=DP, $fn=45);
        cylinder(h=RH+PCH+1,d=SH,$fn=45);
        }
    }
   
    
//Sentral support
if (Sentral_support==true) translate([(Ex1-Ex2)/2,(Ey1-Ey2)/2,0])cylinder(h=RH,d=D,$fn=45);

//Screw plate
if(Screw_plate==true) {
    difference(){
        translate([0,0,PCH/2]) cube([25,25,PCH],center=true);
        for(x=[7,-7]) for(y=[-7,7])rotate([0,0,45])translate([x,y,-0.1]) cylinder(h=PCH+1,d=3,$fn=45);
    }
}

//Cross support beams
translate([(Ex1-Ex2)/2,(Ey1-Ey2)/2,BH/2]) rotate([0,0,atan((Y-Ey1-Ey2-DP)/(X-Ex1-Ex2-DP))]) 
cube([sqrt(pow((X-Ex1-Ex2-DP),2)+pow((Y-Ey1-Ey2-DP),2)),D,BH],center=true);
translate([(Ex1-Ex2)/2,(Ey1-Ey2)/2,BH/2])mirror([1,0,0]) rotate([0,0,atan((Y-Ey1-Ey2-DP)/(X-Ex1-Ex2-DP))]) 
cube([sqrt(pow((X-Ex1-Ex2-DP),2)+pow((Y-Ey1-Ey2-DP),2)),D,BH],center= true);

//Board holders
if(Board_holders==true) {
translate([-X/2,-Y/2+RP-R+Ey1,0]){
    cube([Ex1+R,D,BH]);
    translate([-PCH,0,0]) cube([PCH,D,RH+PCH+PCH]);
    translate([-PCH/3,R,RH+PCH+PCH-PCH/2]) rotate([90,0,0])cylinder(h=D,d=PCH*1.2, center=true,$fn=45);
}
translate([-X/2,Y/2-D-Ey2+R-RP,0]){
    cube([Ex1+R,D,BH]);
    translate([-PCH,0,0]) cube([PCH,D,RH+PCH+PCH]);
    translate([-PCH/3,R,RH+PCH+PCH-PCH/2]) rotate([90,0,0])cylinder(h=D,d=PCH*1.2, center=true,$fn=45);
}
    translate([X/2-Ex2-R,-Y/2+RP-R+Ey1,0]){
    cube([Ex2+R,D,BH]);
    translate([Ex2+R,0,0]) cube([PCH,D,RH+PCH+PCH]);
    translate([Ex2+R+PCH/3,R,RH+PCH+PCH-PCH/2]) rotate([90,0,0])cylinder(h=D,d=PCH*1.2, center=true,$fn=45);
}
translate([X/2-Ex2-R,Y/2-D-Ey2+R-RP,0]){
    cube([Ex2+R,D,BH]);
    translate([Ex2+R,0,0]) cube([PCH,D,RH+PCH+PCH]);
    translate([Ex2+R+PCH/3,R,RH+PCH+PCH-PCH/2]) rotate([90,0,0])cylinder(h=D,d=PCH*1.2, center=true,$fn=45);
}
}
