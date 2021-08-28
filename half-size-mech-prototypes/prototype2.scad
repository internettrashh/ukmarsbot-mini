// Micromouse wheel & gear train

use <pd-gears/pd-gears.scad>
use <attached_wheel.scad>

/* TODO
   	•	It may be convenient at some point to have the drawing x origin at the motor axle position. (Maybe rather than recalculating everything I'll just put an option in the top of the file (so we can have PCB view and motor view).)
	•	PCB to gear spacing (looks like we could get another 1-2 mm of PCB there.)
	•	Motor hole tuning (after print)
	•	Decide on wheel axle width (what is wheel axle hole in mount, e.g. bearing diameter, or whatever)
    •	Tyre sizes? Tyres need to be bigger than wheel gears.

*/

//
// What things to render
//
// (select one of these only)
render_whole_mouse = true;                                         
render_gears_only = false;       // at the moment render hub only from attached_wheel.scad
render_pcb_only = false;
render_mount_only = false;
export_pcb = false;

// options
number_of_wheels = 4;       // @TODO: wheels=2 requires some work
enable_tyres = true;
basic_wheels = true;
rounded_motor_holder = false;
hide_wheels_and_motor = false; // option for render_whole_mouse only
SHOW_SCREW_DEPTH = false;   // ensure false in real print
hide_one_wheel_pair = true;
disable_screw_heads = false;

// helper
function module_to_circular_pitch(module_val) = module_val * PI;

// To show comparative size to classic Micromouse
//translate([-26, -20, -3]) import("ukmarsbot.dxf");
//translate([10, -62, 6.5]) rotate([0,0,90]) import("ukmarsbot-a v47.stl");

epsilon = 0.001;        // small constant to avoid coincident walls on union, difference or intersection


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
board_width_min = 27;
board_width_max = 40;
board_thickness = 0.8;

motor_body_length = 12;
motor_body_diameter = 6;
motor_shaft_protrude_length = 3.5;
motor_shaft_diameter = 0.8;

motor_separation = 3;

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
wheel_shaft_diameter = 1;         // these are the shaft diameters for Rob's axles
//wheel_shaft_diameter = 2.2;       // Size for M2 screws???
wheel_shaft_length = 10;

// wheel gear sizes
wheel_gear_teeth = 44;
wheel_gear_mm_per_tooth = module_to_circular_pitch(module_value);
wheel_gear_thickness = 1;
type_expansion = 2;     // expand rhe rim and tyre to we don't run on the gear teeth
wheel_diameter = (11+type_expansion);
wheel_diameter_2w = 18;
//wheel_diameter = (number_of_wheels==4) ? wheel_diameter_4w : wheel_diameter_2w;

wheel_thickness = 4.5;
//wheel_hole = wheel_thickness-wheel_gear_thickness;
wheel_hole = wheel_shaft_diameter;
tyre_thickness = 1.4;

// axle holder sizes
holder_height = 8;
holder_width = 5;
holder_length = 24;
holder_separation = 8.5;

// Screw details (M2*4 countersunk head, self-tapping, nickel-plated steel, flat head, metric)
// Using longer M2 screws would be problematic, but potentially we could use M1.7*6 or M1.4*5. 
mount_holder_screw_diameter_grip = 1.6;     // OD = 2, but we need something for the threads to grip
mount_holder_screw_diameter_OD = 2;
mount_holder_screw_total_depth = 3.8;       // including head, actual total = 3.65mm plus some clearance
mount_holder_screw_head_diameter = 3.7;     // 3.65mm actual, 0.05 clearance
mount_holder_screw_head_depth = 1;
mount_holder_screw_depth = mount_holder_screw_total_depth-mount_holder_screw_head_depth;               // excluding head
mount_holder_screw_faces = 15;

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

// Bearing
// MR62ZZ (2x6x2.5mm) 
bearing_OD = 6+0.1; // 0.1 is clearance
bearing_ID = 2;
bearing_thickness = 2.5;


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

module mount_screw(pcb_section)
{    
    // the mount must use a thread diameter that allows the self-tap to cut into iut
    // the pcb wants the thread diameter for clearance
    diameter_of_thread = pcb_section ? mount_holder_screw_diameter_OD : mount_holder_screw_diameter_grip;
    rh = (disable_screw_heads ? diameter_of_thread : mount_holder_screw_head_diameter) /2;
    rd = diameter_of_thread/2;
    
    // head
    cylinder(mount_holder_screw_head_depth, rh, rd, $fn=mount_holder_screw_faces);
    // body
    translate([0,0,mount_holder_screw_head_depth-epsilon]) cylinder(mount_holder_screw_depth, rd, rd, $fn=mount_holder_screw_faces);

}

module screw_pair(pcb_section = false)
{
    
    translate([0, SHOW_SCREW_DEPTH?holder_width:holder_width/2,-board_thickness-epsilon]) {
        // the screws
        translate([-(wheel_gear_PR+motor_PR)/2,0,0])
        mount_screw(pcb_section);
        translate([+(wheel_gear_PR+motor_PR)/2,0,0])
        mount_screw(pcb_section);
    }
}

module board()
{
    r = board_width_max/2;
    difference() {
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
        union() {
        translate([-motor_sets_backwards_offset_4w, holder_separation, -epsilon])
            screw_pair(true);
        mirror([0,1,0]) translate([-motor_sets_backwards_offset_4w, holder_separation, -epsilon])
            screw_pair(true);
        }
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////

module motor()
{
    color([0.5, 0.5, 0.8, 1]) rotate([90,0,0]) {
        rb = motor_body_diameter/2;
        cylinder(motor_body_length-2*epsilon, rb, rb);
        translate([0, 0, motor_body_length]) {
            rs = motor_shaft_diameter/2;
            cylinder(motor_shaft_protrude_length, rs, rs);
        }
    }
}

module motor_hole(motor_height)
{
    translate([holder_length/2, motor_body_length-epsilon, motor_body_diameter/2+motor_height]) {
        /*color([0.3, 0.3, 0.7, 0.7])*/ rotate([90,0,0]) {
            rb = motor_body_diameter/2 * 1.05;
            cylinder(motor_body_length+2*epsilon, rb, rb, $fn=40);
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
        rotate([90,20,0]) color([1.00,0.75,0.50])
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

m_axle_collar_diameter = wheel_hole+1; 
m_axle_collar_length = 2;

module wheel_and_gear(pos, flip=0, mm_per_tooth, wheel_dia)
{
    if(basic_wheels) {
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
    else {
            move_wheel = 0.5;
            translate([0,move_wheel,0])
                rotate([90,0,0]) { simple_wheel(wheel_thickness, wheel_gear_thickness, move_wheel, wheel_dia/2, wheel_dia/2-1, m_axle_collar_diameter, m_axle_collar_length, wheel_hole, wheel_gear_teeth, module_value_4wheel);
                translate([0, 0, -6.5
                    ]) cylinder(wheel_shaft_length, wheel_hole/2, wheel_hole/2, $fn=10);
            }
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
            translate([0,0,wheel_gear_thickness-0.1-epsilon]) color([0, 0, 0.2, 0.5]) wheel(wheel_dia+2*tyre_thickness, wheel_thickness-epsilon*2, wheel_diameter, center = false);
            }
}

//////////////////////////////////////////////////////////////////////////////////////////////

module bearing()
{
    // really simple model
    rotate([90,0,0]) difference() {
        cylinder(bearing_thickness, bearing_OD/2, bearing_OD/2, $fn=20);
        translate([0,0,-epsilon]) cylinder(bearing_thickness+2*epsilon, bearing_ID/2, bearing_ID/2, $fn=10);
    }
}

module bearing_hole()
{
    // really simple model
    rotate([90,0,0]) {
        translate([0,0,-2*epsilon]) cylinder(bearing_thickness*2 + 3*epsilon, bearing_OD/2, bearing_OD/2, $fn=30);
    }
    
}

//////////////////////////////////////////////////////////////////////////////////////////////

module wheel_assembly()
{
    translate([wheel_gear_PR+motor_PR,0,0]) {
        wheel_and_gear([0,0,0], 0, wheel_gear_mm_per_tooth, wheel_diameter);
        if(enable_tyres) { tyre([0, 0, 0], 0, wheel_diameter); }
    }
    translate([-(wheel_gear_PR+motor_PR),0,0]) {
        wheel_and_gear([0,0,0],0, wheel_gear_mm_per_tooth, wheel_diameter);
        if(enable_tyres) { tyre([0, 0, 0], 0, wheel_diameter); }
    }
}
echo("Wheel gear PR and motor PR", wheel_gear_PR, motor_PR);

//////////////////////////////////////////////////////////////////////////////////////////////

module wheel_assembly_2wheel()
{
    translate([wheel_gear_PR_2w+motor_PR_2w,0,0]) {
        wheel_and_gear([0,0,0], 0, motor_gear_mm_per_tooth_2w, wheel_diameter_2w);
        if(enable_tyres) { tyre([0, 0, 0], 0, wheel_diameter_2w); }
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////




module motor_holder(motor_height)
{        
    translate([0, holder_separation, 0]) {
        difference()    // change to union to see the motor mount holes rendered
        { 
            translate([-holder_length/2, 0, 0]) color([1,1,1]) if(rounded_motor_holder)
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
                    translate([-holder_length/2, -epsilon, 0]) {
                
                    // motor hole
                    motor_hole(motor_height);
                    translate([0, wheel_shaft_length, holder_height/2])  {
                        //r = wheel_shaft_diameter/2;
                        //translate([0,0,0]) rotate([90, 0, 0]) cylinder(wheel_shaft_length, r*1.1, r*1.1, $fn=20);
                        //translate([0,0,0]) rotate([90, 0, 0]) cylinder(wheel_shaft_length, r*1.1, r*1.1, $fn=20);
                    }
                }
                    // bearing holes
                    translate([wheel_gear_PR+motor_PR,holder_width,motor_body_diameter/2+motor_rise]) {
                        translate([0, 0, 0]) bearing_hole();
                        translate([0,-bearing_thickness,0]) bearing_hole();
                    }
                    translate([-(wheel_gear_PR+motor_PR),holder_width,motor_body_diameter/2+motor_rise]) {
                        translate([0, 0, 0]) bearing_hole();
                        translate([0,-bearing_thickness,0]) bearing_hole();
                    }
                    
                    
                screw_pair();
                }
        }
        
        if(false)
        {
            // bearings
            translate([wheel_gear_PR+motor_PR,holder_width,motor_body_diameter/2+motor_rise]) {
                translate([0, epsilon, 0]) bearing();
                translate([0,-bearing_thickness-epsilon,0]) bearing();
            }
            translate([-(wheel_gear_PR+motor_PR),holder_width,motor_body_diameter/2+motor_rise]) {
                translate([0, epsilon, 0]) bearing();
                translate([0,-bearing_thickness-epsilon,0]) bearing();
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

    if(hide_wheels_and_motor)
    {
    }
    else if(number_of_wheels == 4) {
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
                        if(! hide_one_wheel_pair)
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
    
    translate([-motor_sets_backwards_offset, 0, 0]) {
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
else if(render_mount_only)
{
    motor_holder(motor_rise_4w);
}
else if(export_pcb)
{
    // http://rasterweb.net/raster/2012/07/16/openscad-to-dxf/
    projection(cut=false) import("prototype1_pcb28June2021.stl");
}


//translate([0, -15, 0])
//rotate([90, 0, 0])  
//zwheel();