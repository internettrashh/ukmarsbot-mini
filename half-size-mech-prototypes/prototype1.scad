// Micromouse wheel & gear train

use <pd-gears/pd-gears.scad>

/* TODO
   * Adjustments to positions
   * Look at motor mount detail.
   * Add more parameterization of design (especially in y direction and for wheels).
   * Hollow out wheels
*/

//
// What things to render
//
render_whole_mouse = true;
render_gears_only = false;

// options
rounded_motor_holder = false;

// helper
function module_to_circular_pitch(module_val) = module_val * PI;

//////////////////////////////////////////////////////////////////////////////////////////////
//        .__                          
//  ______|__|________  ____    ______ 
// /  ___/|  |\___   /_/ __ \  /  ___/ 
// \___ \ |  | /    / \  ___/  \___ \  
///____  >|__|/_____ \ \___  >/____  > 
//     \/           \/     \/      \/  
//     
//////////////////////////////////////////////////////////////////////////////////////////////

board_length = 50;
board_width_min = 28;
board_width_max = 40;

motor_body_length = 12;
motor_body_diameter = 6;
motor_shift_protrude_length = 4;
motor_shift_diameter = 1;

motor_separation = 3;

// gear definitions
// Ratio 37:9 (no coprime) - 4.111
module_value = 0.3;

// motor gear definitions
motor_gear_teeth = 9;
motor_gear_mm_per_tooth = module_to_circular_pitch(module_value);
motor_gear_hole = 0.8;
motor_gear_thickness = 1.5;
motor_gear_outside_radius = outer_radius(motor_gear_mm_per_tooth, motor_gear_teeth, 0);

// other wheel specific items
wheel_shaft_diameter = 1.5;         // these are the shaft diameters for Rob's axles
//wheel_shaft_diameter = 2.2;       // Size for M2 screws???
wheel_shaft_length = 15;

// wheel gear sizes
wheel_gear_teeth = 37;
wheel_gear_mm_per_tooth = module_to_circular_pitch(module_value);
wheel_gear_thickness = 1.4;
wheel_diameter = 10;
wheel_thickness = 3;
//wheel_hole = wheel_thickness-wheel_gear_thickness;
wheel_hole = wheel_shaft_diameter;
tyre_thickness = 1.5;

// axle holder sizes
holder_height = 8;
holder_width = 4;
holder_length = 20;

// general positions
motor_sets_backwards_offset = 5;
wheel_to_board_edge_extra_clearance = 0.5;
motor_rise = 0.8;

//
// Gear dimensions
//
motor_PR = pitch_radius(motor_gear_mm_per_tooth, motor_gear_teeth);
motor_gear_OD = 2*outer_radius(motor_gear_mm_per_tooth, motor_gear_teeth, 0);
echo(str("Motor gear outside diameter = ", motor_gear_OD, "mm"));

wheel_gear_PR = pitch_radius(wheel_gear_mm_per_tooth, wheel_gear_teeth);
wheel_gear_OD = 2*outer_radius(wheel_gear_mm_per_tooth, wheel_gear_teeth, 0);
echo(str("Wheel Gear large outside diameter = ", wheel_gear_OD, "mm"));
wheel_tyre_OD = wheel_diameter+2*tyre_thickness;

// additive sizes
motor_to_board_clearance = (wheel_tyre_OD/2 + wheel_gear_PR + motor_PR + wheel_to_board_edge_extra_clearance);
echo(str(board_length/2," ",motor_to_board_clearance));
// board calculations


// board tail calculations
board_tail_length = (board_length/2)-motor_to_board_clearance-motor_sets_backwards_offset;
enable_board_tail = board_tail_length >= 3;

// front calculations
in_front_of_wheels_board_position = motor_to_board_clearance-motor_sets_backwards_offset;



//////////////////////////////////////////////////////////////////////////////////////////////
//                                    .___             ___.             
// _______   ____   __ __   ____    __| _/ ____   __ __\_ |__    ____   
// \_  __ \ /  _ \ |  |  \ /    \  / __ |_/ ___\ |  |  \| __ \ _/ __ \  
//  |  | \/(  <_> )|  |  /|   |  \/ /_/ |\  \___ |  |  /| \_\ \\  ___/  
//  |__|    \____/ |____/ |___|  /\____ | \___  >|____/ |___  / \___  > 
//                             \/      \/     \/            \/      \/  
//////////////////////////////////////////////////////////////////////////////////////////////

module torus(r1, r2)
{
    rotate_extrude(convexity = 10)
    translate([r2, 0, 0])
    circle(r = r1, $fn = 100);
}

module roundcube(h, l, w, side_r, top_r)
{
    difference()
    {
        hull()
        {
            translate([side_r,side_r,0]) cylinder(0.1, side_r, side_r);
            translate([w-side_r, side_r,0]) cylinder(0.1, side_r, side_r);
            translate([side_r, l-side_r,0]) cylinder(0.1, side_r, side_r);
            translate([w-side_r, l-side_r,0]) cylinder(0.1, side_r, side_r);
            translate([side_r, side_r, h-top_r]) torus(top_r, side_r-top_r);
            translate([w-side_r, side_r, h-top_r]) torus(top_r, side_r-top_r);
            translate([side_r, l-side_r, h-top_r]) torus(top_r, side_r-top_r);
            translate([w-side_r, l-side_r, h-top_r]) torus(top_r, side_r-top_r);
        }
    }
}

/*
x_side_r = 7;
x_top_r = 3;
x_h = 11;
x_l = 44;
x_w = 77;
roundcube(x_h, x_l, x_w, x_side_r, x_top_r);
*/

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
        // main narrow square
        subboard_length = in_front_of_wheels_board_position+board_length/2;
        translate([-subboard_length/2+in_front_of_wheels_board_position, 0, -board_thickness/2]) cube([subboard_length, board_width_min, board_thickness], center = true);
        // tail
        if(enable_board_tail)
        {
            translate([-(board_length-board_tail_length)/2, 0, -board_thickness/2]) cube([board_tail_length, board_width_max, board_thickness], center = true);
        }
        // circle
        circle_offset = (board_length/2)-r;
        translate([0, 0, -board_thickness]) {
            difference() {
                h = board_thickness;
                e=.02;
                translate([circle_offset, 0, 0]) cylinder(board_thickness,r,r);
                translate([-2*r+in_front_of_wheels_board_position,-r,-e])cube([2*r,2*r,h+2*e]);
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


//////////////////////////////////////////////////////////////////////////////////////////////


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



holder_seperation = 7;

module motor_holder()
{
    translate([0, holder_seperation, 0]) {
        difference()
        { 
            color([1,1,1]) if(rounded_motor_holder)
            {
                roundcube(holder_length, holder_width, holder_height, 0.5, 0.5);
            }
            else
            {
                cube([holder_length, holder_width, holder_height]);
            }
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

if(render_whole_mouse)
{
    board();

    motor_gear_offset = motor_body_length + motor_shift_protrude_length/2 - motor_gear_thickness/2;
    wheel_additional_offset = wheel_gear_thickness/2 - motor_gear_thickness/2;

    translate([-motor_sets_backwards_offset, 0, motor_body_diameter/2+motor_rise]) {   
        translate([0, -motor_separation/2, 0]) {
            motor();
            translate([0, -motor_gear_offset, 0]) {
                motor_gear([0,0,0], 0);
                translate([0, wheel_additional_offset, 0]) wheel_assembly();
            }
        }
        mirror([0,1,0]) {
            translate([0, -motor_separation/2, 0]) {
                motor();
                translate([0, -motor_gear_offset, 0]) {
                    motor_gear([0,0,0], 0);
                    translate([0, wheel_additional_offset, 0]) wheel_assembly();
                }
            }
        }
    }

    translate([-holder_length/2-motor_sets_backwards_offset, 0, 0]) {
        motor_holder();
        mirror([0,1,0]) {
            motor_holder();
        }
    }
}
else if(render_gears_only)
{
    rotate([-90, 0, 0])
    {
        motor_gear([0,0,0], 0);
        translate([wheel_gear_PR+motor_PR+1, 0, 0]) wheel_and_gear([0,0,0], 0);
        translate([-(wheel_gear_PR+motor_PR+1), 0, 0]) wheel_and_gear([0,0,0], 0);
    }
}

