stone_width = 20;
support_length = stone_width + 90;

//the width, actually
side_length = 5;
side_height = 20;
side_width = 10;

base_height=6;
base_width=stone_width;
base_length=23;

base_support_size=30;

union() {
  // base
  cube([base_length,base_width,base_height], true);
  // side supports for stone
  translate([-side_length/2, -(stone_width/2 + side_width), base_height/2-1]) prism(side_length, side_width, side_height);
  translate([side_length/2, stone_width/2 + side_width, base_height/2-1]) rotate([0,0,180]) prism(side_length, side_width, side_height);
  // base extrusion for stability
  cube([side_length, support_length, base_height], true);

  // base triangles to support extrusion
   for (x = [0,180]) { 
     rotate ([x,0,0]) union() {
       translate([side_length/2-1,base_support_size+stone_width/2-0,-base_height/2]) rotate([180,270,0]) prism(base_height, base_support_size, side_width);
       translate([-side_length/2+1,base_support_size+stone_width/2,base_height/2]) rotate([180,90,0]) prism(base_height, base_support_size, side_width);
     }
   }  
}

module prism(l, w, h){
      polyhedron(//pt 0        1        2        3        4        5
              points=[[0,0,0], [l,0,0], [l,w,0], [0,w,0], [0,w,h], [l,w,h]],
              faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]
              );
      
      }
  
