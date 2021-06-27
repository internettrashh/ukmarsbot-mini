// Micromouse wheel & gear train

use <pd-gears/pd-gears.scad>
//////////////////////////////////////////////////////////////////////////////////////////////
//        .__                          
//  ______|__|________  ____    ______ 
// /  ___/|  |\___   /_/ __ \  /  ___/ 
// \___ \ |  | /    / \  ___/  \___ \  
///____  >|__|/_____ \ \___  >/____  > 
//     \/           \/     \/      \/  
//     
//////////////////////////////////////////////////////////////////////////////////////////////

board_length = 45;
board_width_min = 28;
board_width_max = 35;

motor_body_length = 12;
motor_body_diameter = 6;
motor_shift_protrude_length = 4;
motor_shift_diameter = 1;

motor_seperation = 3;

// motor gear definitions
motor_gear_teeth = 6;
motor_gear_mm_per_tooth = 1.29;
motor_gear_hole = 0.8;
motor_gear_thickness = 2.85;
motor_gear_outside_radius = outer_radius(motor_gear_mm_per_tooth, motor_gear_teeth, 0);

// other wheel specific items
wheel_shaft_diameter = 1;
wheel_shaft_length = 15;

// wheel gear sizes
wheel_gear_teeth = 20;
wheel_gear_mm_per_tooth = 1.5555;
wheel_gear_thickness = 1.4;
wheel_diameter = 9;
wheel_thickness = 3;
wheel_hole = wheel_thickness-wheel_gear_thickness;

//////////////////////////////////////////////////////////////////////////////////////////////
//             ____                          
//  ___  ___  / ___\   ____  _____  _______  
//  \  \/  / / /_/  >_/ __ \ \__  \ \_  __ \ 
//   >    <  \___  / \  ___/  / __ \_|  | \/ 
//  /__/\_ \/_____/   \___  >(____  /|__|    
//        \/              \/      \/         
//   
// Saves generating full gears when prototyping
//////////////////////////////////////////////////////////////////////////////////////////////
replace_cylinder = false;
cylinder_segments = 40;

module xgear(mm_per_tooth, teeth, thickness, hole_diameter, center = false)
{
    if (replace_cylinder) {
        difference() {
            cylinder(thickness, outer_radius(mm_per_tooth, teeth, 0), outer_radius(mm_per_tooth, teeth, 0), center, $fn = cylinder_segments);
        translate([0,0, (center ? 0 : -0.1)])
            cylinder(h=thickness+0.2, r=hole_diameter/2, center=center, $fn=cylinder_segments);
        }
    }
    else
        gear(mm_per_tooth, teeth, thickness, hole_diameter, center);
}

//////////////////////////////////////////////////////////////////////////////////////////////
//                                                                  __           
//   ____   ____    _____  ______    ____    ____    ____    ____ _/  |_  ______ 
// _/ ___\ /  _ \  /     \ \____ \  /  _ \  /    \ _/ __ \  /    \\   __\/  ___/ 
// \  \___(  <_> )|  Y Y  \|  |_> >(  <_> )|   |  \\  ___/ |   |  \|  |  \___ \  
//  \___  >\____/ |__|_|  /|   __/  \____/ |___|  / \___  >|___|  /|__| /____  > 
//      \/              \/ |__|                 \/      \/      \/           \/
//////////////////////////////////////////////////////////////////////////////////////////////

module board()
{
    board_thickness = 1.6;
    r = board_width_max/2;
    color([0.3, 0.7, 0.3, 0.7]) union() {
        translate([-r/2, 0, -board_thickness/2]) cube([board_length-r, board_width_min, board_thickness], center = true);
        translate([(board_length/2)-r, 0, -board_thickness]) {
            difference() {
                h = board_thickness;
                e=.02;
                cylinder(board_thickness,r,r);
                translate([-2*r,-r,-e])cube([2*r,2*r,h+2*e]);
            }
        }
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////

module motor()
{
    color([0.3, 0.3, 0.7, 0.7]) rotate([90,0,0]) {
        rb = motor_body_diameter/2;
        cylinder(motor_body_length, rb, rb);
        translate([0, 0, motor_body_length]) {
            rs = motor_shift_diameter/2;
            cylinder(motor_shift_protrude_length, rs, rs);
        }
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////

module motor_gear(pos, flip=0)     // orange
{
    translate(pos)
        rotate([90,90,0]) color([1.00,0.75,0.50])
        mirror([0,0,flip])
            xgear(motor_gear_mm_per_tooth, motor_gear_teeth, motor_gear_thickness, motor_gear_hole, center = false);
}
echo(str("Motor gear outside diameter = ", 2*outer_radius(motor_gear_mm_per_tooth, motor_gear_teeth, 0), "mm"));
motor_PR = pitch_radius(motor_gear_mm_per_tooth, motor_gear_teeth);


//////////////////////////////////////////////////////////////////////////////////////////////

module wheel(diameter, thickness, hole_diameter, center = false)
{
    r = diameter/2;
    difference() {
        cylinder(thickness, r, r, center, $fn = cylinder_segments);
        translate([0, 0, (center ? 0 : -0.1)])
            cylinder(h=thickness+0.2, r=hole_diameter/2, center=center, $fn=cylinder_segments);
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////

module wheel_and_gear(pos, flip=0)
{
    angle=0; offset=0; offsety=0;
    translate(pos)
    rotate([0, angle, 0]) translate([offset, -flip*wheel_thickness + offsety, 0])
        rotate([90,90,0]) 
        mirror([0,0,flip])
            {
            color([0.75,1.00,0.75]) xgear(wheel_gear_mm_per_tooth, wheel_gear_teeth, wheel_gear_thickness, wheel_hole, center = false);
            translate([0,0,wheel_gear_thickness-0.1]) color([0.5,1.00,0.5]) wheel(wheel_diameter, wheel_thickness, wheel_hole, center = false);
            }
}

echo(str("Gear2010 large outside diameter = ", 2*outer_radius(wheel_gear_mm_per_tooth, wheel_gear_teeth, 0), "mm"));
wheel_gear_PR = pitch_radius(wheel_gear_mm_per_tooth, wheel_gear_teeth);

//////////////////////////////////////////////////////////////////////////////////////////////

tyre_thickness = 2;

module tyre(pos, flip=0)
{
    angle=0; offset=0; offsety=0;
    translate(pos)
    rotate([0, angle, 0]) translate([offset, -flip*wheel_thickness + offsety, 0])
        rotate([90,90,0]) 
        mirror([0,0,flip])
            {
            translate([0,0,wheel_gear_thickness-0.1]) color([0, 0, 0.2, 0.5]) wheel(wheel_diameter+2*tyre_thickness, wheel_thickness, wheel_diameter, center = false);
            }
}

//////////////////////////////////////////////////////////////////////////////////////////////

module wheel_assembly()
{
    translate([wheel_gear_PR+motor_PR,0,0]) {
        wheel_and_gear([0,0,0], 0);
        tyre([0, 0, 0], 0);
    }
    translate([-(wheel_gear_PR+motor_PR),0,0]) {
        wheel_and_gear([0,0,0],0);
        tyre([0, 0, 0], 0);
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////

holder_height = 8;
holder_width = 5;
holder_length = 20;

holder_seperation = 7;

module motor_holder()
{
    translate([0, holder_seperation, 0]) {
        difference()
        {
            color([1,1,1]) cube([holder_length, holder_width, holder_height]);
            // put axle holes in motor holder here
            // put mounting holder in motor holder here
        }
    }
}


//////////////////////////////////////////////////////////////////////////////////////////////
//                .__        
//   _____ _____  |__| ____  
//  /     \\__  \ |  |/    \ 
// |  Y Y  \/ __ \|  |   |  \
// |__|_|  (____  /__|___|  /
//       \/     \/        \/ 
//
//////////////////////////////////////////////////////////////////////////////////////////////

board();

motor_gear_offset = motor_body_length + motor_shift_protrude_length/2 - motor_gear_thickness/2;
wheel_additional_offset = wheel_gear_thickness/2 - motor_gear_thickness/2;

translate([-10, 0, motor_body_diameter/2]) {   
    translate([0, -motor_seperation/2, 0]) {
        motor();
        translate([0, -motor_gear_offset, 0]) {
            motor_gear([0,0,0], 0);
            translate([0, wheel_additional_offset, 0]) wheel_assembly();
        }
    }
    mirror([0,1,0]) {
        translate([0, -motor_seperation/2, 0]) {
            motor();
            translate([0, -motor_gear_offset, 0]) {
                motor_gear([0,0,0], 0);
                translate([0, wheel_additional_offset, 0]) wheel_assembly();
            }
        }
    }
}

translate([-holder_length, 0, 0]) {
    motor_holder();
    mirror([0,1,0]) {
        motor_holder();
    }
}


