height = 8;
width = 12;

centerColumn = (6.15 / 2);

union() {
    difference() {
        cylinder(height, width, width, true);
        
        translate([0, 0, -1])
        difference() {
            cylinder(height, centerColumn, centerColumn, true);
            translate([12, 0, 0])
                cube(20, true);
        };
    };

    translate([0, 0, -3.5])
    difference() {
        difference() {
            cylinder(height - 2, centerColumn + 2, centerColumn + 2, true, $fn=45);
            translate([14, 0, 0])
                cube(20, true);
        };
        difference() {
            cylinder(height - 1.9, centerColumn, centerColumn, true);
            translate([12, 0, 0])
                cube(20, true);
        };
    }
}
