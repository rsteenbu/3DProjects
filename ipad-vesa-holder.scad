SHOW_IPAD = false;
SHOW_VESA_MOUNT = false;

//IPAD_SIZE = [248,179,6.5];
IPAD_SIZE = [248,179,6.5];
MINKOWSKI_SIZE = 20;
IPAD_COORDINATES = [IPAD_SIZE.x - MINKOWSKI_SIZE*2, IPAD_SIZE.y - MINKOWSKI_SIZE*2, IPAD_SIZE.z];

VESA_PLATE_SIZE = [100,100,3];
VESA_MOUNT_SIZE = [75,75];

LIP_SIDE_HEIGHT = 18;
LIP_HEIGHT = 8;
LIP_DEPTH = 4;
DEPTH=7;
WIDTH=30;

LIP_SIZE = [IPAD_SIZE.z + LIP_DEPTH, 5];
BACK_SIZE = [IPAD_SIZE.x + LIP_SIZE.y * 2, IPAD_SIZE.y + LIP_SIZE.y, IPAD_SIZE.z];
$fn=50;

if (SHOW_IPAD) {
  translate([MINKOWSKI_SIZE, MINKOWSKI_SIZE, LIP_DEPTH]) color("grey") minkowski()
  {
    cube(IPAD_COORDINATES);
    cylinder(r=MINKOWSKI_SIZE,h=1);
  }
}


if (SHOW_VESA_MOUNT) {
  difference() {
    translate([(IPAD_SIZE.x / 2) - (VESA_PLATE_SIZE.x / 2), IPAD_SIZE.y / 2 - VESA_PLATE_SIZE.y / 2, -VESA_PLATE_SIZE.z]) 
      color("red") cube(VESA_PLATE_SIZE);

    translate([IPAD_SIZE.x/2, IPAD_SIZE.y/2, 0])
      for(x=[1,-1]) for(y=[1,-1]) 
	translate([(VESA_MOUNT_SIZE.x/2) * x, (VESA_MOUNT_SIZE.y/2) * y, -10]) 
	  cylinder(r=3.5/2, h=25);
  }
}


translate([IPAD_SIZE.x/2, IPAD_SIZE.y/2, 0]) { 
  ipad_arm();
  if (!SHOW_IPAD) 
    translate([30,0,0]) mirror([1,0,0]) ipad_arm();
  if (SHOW_IPAD) 
    mirror([1,0,0]) ipad_arm();
}

module ipad_arm() {
  
      X_OFFSET=VESA_MOUNT_SIZE.x/2-WIDTH/2;
  
      difference() {
        union() {
          translate([0,0,3]) { 
            polyhedron(
              points = [
                [X_OFFSET, -45, 0],                                              //0
                [X_OFFSET, 45, 0],                                               //1
                [IPAD_SIZE.x/2-WIDTH, IPAD_SIZE.y/2, 0],                         //2
                [IPAD_SIZE.x/2, IPAD_SIZE.y/2, 0],                               //3
                [X_OFFSET + WIDTH, 20, 0],                                       //4
                [X_OFFSET + WIDTH, -40, 0],                                      //5
                [IPAD_SIZE.x/2-50, -IPAD_SIZE.y/2, 0],                           //6
                [IPAD_SIZE.x/2-50-WIDTH, -IPAD_SIZE.y/2, 0],                     //7

                [IPAD_SIZE.x/2-50-WIDTH, -IPAD_SIZE.y/2, DEPTH],                 //8 (7)
                [X_OFFSET, -45, DEPTH],                                          //9 (0)
                [X_OFFSET, 45, DEPTH],                                           //10 (1)
                [IPAD_SIZE.x/2-WIDTH,    IPAD_SIZE.y/2, DEPTH],                  //11 (2)
                [IPAD_SIZE.x/2, IPAD_SIZE.y/2, DEPTH],                           //12 (3)
                [X_OFFSET + WIDTH, 20, DEPTH],                                   //13 (4)
                [X_OFFSET + WIDTH, -40, DEPTH],                                  //14 (5)
                [IPAD_SIZE.x/2-50, -IPAD_SIZE.y/2, DEPTH],                       //15 (6)

                [IPAD_SIZE.x/2, IPAD_SIZE.y/2-LIP_SIDE_HEIGHT, 0],                    //16 
                [IPAD_SIZE.x/2, IPAD_SIZE.y/2-LIP_SIDE_HEIGHT, DEPTH],                //17
              ], faces = [
                [7,6,5,4,16,3,2,1,0],
                [8,9,10,11,12,17,13,14,15],
                [0,9,8,7],
                [0,1,10,9],
                [1,2,11,10],
                [2,3,12,11],
                [13,17,16,4],
                [17,12,3,16],
                [14,13,4,5],
                [15,14,5,6],
                [6,7,8,15],
              ]
           );

           // upper lip
           translate([IPAD_SIZE.x/2-50-WIDTH, -IPAD_SIZE.y/2-LIP_DEPTH, 0]) cube([WIDTH, LIP_DEPTH, DEPTH+IPAD_SIZE.z]);
           // lower lip
           translate([IPAD_SIZE.x/2-WIDTH, IPAD_SIZE.y/2, 0]) cube([WIDTH, LIP_DEPTH, DEPTH+IPAD_SIZE.z]);
           translate([IPAD_SIZE.x/2-WIDTH, IPAD_SIZE.y/2-LIP_HEIGHT, (DEPTH+IPAD_SIZE.z)]) cube([WIDTH, LIP_HEIGHT+LIP_DEPTH, LIP_DEPTH]);
           translate([IPAD_SIZE.x/2, IPAD_SIZE.y/2-LIP_SIDE_HEIGHT, 0]) cube([LIP_DEPTH, LIP_SIDE_HEIGHT+LIP_DEPTH, LIP_DEPTH+DEPTH+IPAD_SIZE.z]);

         } //translate [0,0,3]
       } //union

       for(y=[1,-1]) {
         translate([(VESA_MOUNT_SIZE.x/2), (VESA_MOUNT_SIZE.y/2) * y, -8]) cylinder(r=3.5/2, h=25);
         translate([(VESA_MOUNT_SIZE.x/2), (VESA_MOUNT_SIZE.y/2) * y, 4]) cylinder(r=7/2, h=7);
       }
     } //difference

}


