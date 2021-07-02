// Simple Micromouse wheel shape
//
use <pd-gears/pd-gears.scad>

show_reference_wheel = true;

if(show_reference_wheel) {
    translate([-12, 0, 5])      // side by side
    //translate([0, 0, 15])     // behind
    rotate([-90,0,0]) import("zirconia_single_wheel_rim.stl", convexity = 4);
}

faces = 200;
//faces = 50;

// mini_UKMARS constants
// =====================
//RIM_depth = 4.5;
//RIM_outside_radius = 11/2;
//RIM_inside_radius = RIM_outside_radius-1;
//axle_diameter = 1;
//axle_collar_diameter = 2; 
//axle_collar_length = 2;
//gear_offset = 0.5;
//
//gear_thickess = 1;
//gear_teeth = 37;
//gear_module = 0.3;

// Zirconia constants
// =====================
RIM_depth = 3.5;
RIM_outside_radius = 4.75;
RIM_inside_radius = 3.75;
axle_diameter = 1;
axle_collar_diameter = 2; 
axle_collar_length = 2;
gear_offset = 0.5;

gear_thickess = 1;
gear_teeth = 37;
gear_module = 0.3;


// common constants
defined_pressure_angle = 20;

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
        gear(mm_per_tooth, teeth, thickness, hole_diameter, center, pressure_angle = defined_pressure_angle);
}
//////////////////////////////////////////////////////////////////////////////////////////////
//
// module_to_circular_pitch
//

function module_to_circular_pitch(module_val) = module_val * PI;

//////////////////////////////////////////////////////////////////////////////////////////////
//
// zwheel
//
module zwheel()
{
    color("white", 1.0) {
        difference() {
            union() {
                // main RIM
                translate([0, 0, gear_thickess+gear_offset]) difference() {
                    cylinder(RIM_depth, RIM_outside_radius, RIM_outside_radius, $fn=faces);
                    translate([0,0,-0.05]) cylinder(RIM_depth+0.1, RIM_inside_radius, RIM_inside_radius, $fn=faces);
                }
                // axel collar
                cylinder(axle_collar_length, axle_collar_diameter/2, axle_collar_diameter/2, $fn=faces);
                translate([0,0,gear_offset]) xgear(module_to_circular_pitch(gear_module), gear_teeth, gear_thickess, axle_diameter, center=true);
            }
        // axle
        translate([0, 0, -RIM_depth/2]) cylinder(RIM_depth*2, axle_diameter/2, axle_diameter/2, $fn=faces);
        }
    }
}

//
//
//
zwheel();

