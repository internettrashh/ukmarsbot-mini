// Micromouse wheel & gear train

use <pd-gears/pd-gears.scad>
use <simple_wheels.scad>

/* TODO
   * Adjustments to positions
   * Look at motor mount detail
   *   - hole for axles
   *   - holes for mounting (Motor mount screws)
   * Add more parameterization of design (especially in y direction and for wheels).
   * Hollow out wheels
   
   	•	It may be convenient at some point to have the drawing x origin at the motor axle position. (Maybe rather than recalculating everything I'll just put an option in the top of the file (so we can have PCB view and motor view).)
	•	PCB to gear spacing (looks like we could get another 1-2 mm of PCB there.)
	•	Motor shaft length
	•	Motor hole tuning (after print)
	•	Decide on wheel axle width (what is wheel axle hole in mount, e.g. bearing diameter, or whatever)
    •	Tyre sizes?

*/

//
// What things to render
//
render_whole_mouse = true;                                         
render_gears_only = false;
render_pcb_only = false;
export_pcb = false;
number_of_wheels = 4;

// options
rounded_motor_holder = true;

// helper
function module_to_circular_pitch(module_val) = module_val * PI;

// To show comparative size to classic Micromouse
//translate([-26, -20, -3]) import("ukmarsbot.dxf");
//translate([10, -62, 6.5]) rotate([0,0,90]) import("ukmarsbot-a v47.stl");


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
board_thickness = 0.8;

motor_body_length = 12;
motor_body_diameter = 6;
motor_shaft_protrude_length = 3.5;
motor_shaft_diameter = 0.8;

motor_separation = 4;

// gear definitions
// Ratio 37:9 (no coprime) - 4.111
module_value_4wheel = 0.3;
module_value_2wheel = 0.5;
//module_value = (number_of_wheels==4) ? module_value_4wheel : module_value_2wheel;
module_value = module_value_4wheel;

// motor gear definitions
motor_gear_teeth = 9;
motor_gear_mm_per_tooth = module_to_circular_pitch(module_value);
motor_gear_mm_per_tooth_2w = module_to_circular_pitch(module_value_2wheel);
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
wheel_diameter = 11;
wheel_diameter_2w = 18;
//wheel_diameter = (number_of_wheels==4) ? wheel_diameter_4w : wheel_diameter_2w;

wheel_thickness = 4.5;
//wheel_hole = wheel_thickness-wheel_gear_thickness;
wheel_hole = wheel_shaft_diameter;
tyre_thickness = 1.4;

// axle holder sizes
holder_height = 8;
holder_width = 4;
holder_length = 20;
holder_separation = 10;

// general positions
motor_sets_backwards_offset_4w = 5;
motor_sets_backwards_offset_2w = 13;
motor_sets_backwards_offset = motor_sets_backwards_offset_4w;
wheel_to_board_edge_extra_clearance = 0.5;

motor_rise_4w = 0.8;
motor_rise_2w = 2.8;
motor_rise = (number_of_wheels==4) ? motor_rise_4w : motor_rise_2w;

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

// additive sizes - board calculations
motor_to_board_clearance = (wheel_tyre_OD/2 + wheel_gear_PR + motor_PR + wheel_to_board_edge_extra_clearance);
//echo(str(board_length/2," ",motor_to_board_clearance));


// board tail calculations
board_tail_length = (board_length/2)-motor_to_board_clearance-motor_sets_backwards_offset_4w;
enable_board_tail = board_tail_length >= 3;

// front calculations
in_front_of_wheels_board_position = motor_to_board_clearance-motor_sets_backwards_offset_4w;


//
// some calculations for the 2 wheel variant
//
motor_PR_2w = pitch_radius(motor_gear_mm_per_tooth_2w, motor_gear_teeth);
wheel_gear_PR_2w = pitch_radius(motor_gear_mm_per_tooth_2w, wheel_gear_teeth);

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
    rotate_extrude(convexity = 10, $fn=50)
    translate([r2, 0, 0])
    circle(r = r1, $fn = 50);
}

module roundcube(h, l, w, side_r, top_r)
{
    //difference()
    {
        hull()
        {
            fn_cylinder=30;
            translate([side_r,side_r,0]) cylinder(0.05, side_r, side_r, $fn=fn_cylinder);
            translate([w-side_r, side_r,0]) cylinder(0.05, side_r, side_r, $fn=fn_cylinder);
            translate([side_r, l-side_r,0]) cylinder(0.05, side_r, side_r, $fn=fn_cylinder);
            translate([w-side_r, l-side_r,0]) cylinder(0.05, side_r, side_r, $fn=fn_cylinder);
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
        gear(mm_per_tooth, teeth, thickness, hole_diameter, center, pressure_angle  = 20);
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
            rs = motor_shaft_diameter/2;
            cylinder(motor_shaft_protrude_length, rs, rs);
        }
    }
}

module motor_hole(motor_height)
{
    translate([holder_length/2, motor_body_length, motor_body_diameter/2+motor_height]) {
        /*color([0.3, 0.3, 0.7, 0.7])*/ rotate([90,0,0]) {
            rb = motor_body_diameter/2 * 1.05;
            cylinder(motor_body_length, rb, rb, $fn=40);
            //translate([0, 0, motor_body_length]) {
            //    rs = motor_shaft_diameter/2;
            //    cylinder(motor_shaft_protrude_length, rs, rs);
            //}
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

module motor_gear_2wheel(pos, flip=0)     // orange
{
    translate(pos)
        rotate([90,90,0]) color([1.00,0.75,0.50])
        mirror([0,0,flip])
            xgear(motor_gear_mm_per_tooth_2w, motor_gear_teeth, motor_gear_thickness, motor_gear_hole, center = false);
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

module wheel_and_gear(pos, flip=0, mm_per_tooth, wheel_dia)
{
    angle=0; offset=0; offsety=0;
    translate(pos)
    rotate([0, angle, 0]) translate([offset, -flip*wheel_thickness + offsety, 0])
        rotate([90,90,0]) 
        mirror([0,0,flip])
            {
            color([0.75,1.00,0.75]) xgear(mm_per_tooth, wheel_gear_teeth, wheel_gear_thickness, wheel_hole, center = false);
            translate([0,0,wheel_gear_thickness-0.1]) color([0.5,1.00,0.5]) wheel(wheel_dia, wheel_thickness, wheel_hole, center = false);
            }
}


//////////////////////////////////////////////////////////////////////////////////////////////


module tyre(pos, flip=0, wheel_dia)
{
    angle=0; offset=0; offsety=0;
    translate(pos)
    rotate([0, angle, 0]) translate([offset, -flip*wheel_thickness + offsety, 0])
        rotate([90,90,0]) 
        mirror([0,0,flip])
            {
            translate([0,0,wheel_gear_thickness-0.1]) color([0, 0, 0.2, 0.5]) wheel(wheel_dia+2*tyre_thickness, wheel_thickness, wheel_diameter, center = false);
            }
}

//////////////////////////////////////////////////////////////////////////////////////////////

module wheel_assembly()
{
    translate([wheel_gear_PR+motor_PR,0,0]) {
        wheel_and_gear([0,0,0], 0, wheel_gear_mm_per_tooth, wheel_diameter);
        tyre([0, 0, 0], 0, wheel_diameter);
    }
    translate([-(wheel_gear_PR+motor_PR),0,0]) {
        wheel_and_gear([0,0,0],0, wheel_gear_mm_per_tooth, wheel_diameter);
        tyre([0, 0, 0], 0, wheel_diameter);
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////

module wheel_assembly_2wheel()
{
    translate([wheel_gear_PR_2w+motor_PR_2w,0,0]) {
        wheel_and_gear([0,0,0], 0, motor_gear_mm_per_tooth_2w, wheel_diameter_2w);
        tyre([0, 0, 0], 0, wheel_diameter_2w);
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////




module motor_holder(motor_height)
{
    translate([0, holder_separation, 0]) {
        difference()    // change to iunion to see the motor mount holes rendered
        { 
            color([1,1,1]) if(rounded_motor_holder)
            {
                echo(str("roundcube = ", holder_length, ", ", holder_width, ", ", holder_height));
                roundcube(holder_height, holder_width, holder_length, 1.4, 0.7);
            }
            else
            {
                cube([holder_length, holder_width, holder_height]);
            }
            // put axle holes in motor holder here
            // put mounting holder in motor holder here
            union() {
                motor_hole(motor_height);
                translate([holder_length/2, wheel_shaft_length, holder_height/2])  {
                    r = wheel_shaft_diameter/2;
                    translate([0,0,0]) rotate([90, 0, 0]) cylinder(wheel_shaft_length, r*1.1, r*1.1, $fn=20);
                    translate([0,0,0]) rotate([90, 0, 0]) cylinder(wheel_shaft_length, r*1.1, r*1.1, $fn=20);
                }
            }
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

    motor_gear_offset = motor_body_length + motor_shaft_protrude_length/2 - motor_gear_thickness/2;
    wheel_additional_offset = wheel_gear_thickness/2 - motor_gear_thickness/2;

    if(number_of_wheels == 4) {
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
    } else if(number_of_wheels == 2)
    {
        translate([-motor_sets_backwards_offset_2w, 0, motor_body_diameter/2+motor_rise]) {   
            translate([0, -motor_separation/2, 0]) {
                motor();
                translate([0, -motor_gear_offset, 0]) {
                    motor_gear_2wheel([0,0,0], 0);
                    translate([0, wheel_additional_offset, 0]) wheel_assembly_2wheel();
                }
            }
            mirror([0,1,0]) {
                translate([0, -motor_separation/2, 0]) {
                    motor();
                    translate([0, -motor_gear_offset, 0]) {
                        motor_gear_2wheel([0,0,0], 0);
                        translate([0, wheel_additional_offset, 0]) wheel_assembly_2wheel();
                    }
                }
            }
        }
    }
    
    translate([-holder_length/2-motor_sets_backwards_offset, 0, 0]) {
        motor_holder(motor_rise_4w);
        mirror([0,1,0]) {
            motor_holder(motor_rise_4w);
        }
    }
}
else if(render_gears_only)
{
    rotate([-90, 0, 0])
    {
        motor_gear([0,0,0], 0);
        translate([wheel_gear_PR+motor_PR+1, 0, 0]) wheel_and_gear([0,0,0], 0, wheel_gear_mm_per_tooth, wheel_diameter);
        translate([-(wheel_gear_PR+motor_PR+1), 0, 0]) wheel_and_gear([0,0,0], 0, wheel_gear_mm_per_tooth, wheel_diameter);
    }
}
else if(render_pcb_only)
{
    board();
}
else if(export_pcb)
{
    // http://rasterweb.net/raster/2012/07/16/openscad-to-dxf/
    projection(cut=false) import("prototype1_pcb28June2021.stl");
}


//translate([0, -15, 0])
//rotate([90, 0, 0])  
//zwheel();