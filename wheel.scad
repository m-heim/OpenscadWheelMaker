include <BOSL2/std.scad>

$fn = 91;

// SETUP

// inner diameter of wheel
wheel_diameter = 120;

// thickness of outer part
wheel_thickness = 3.5;


tire_thickness = 4;
tire_middle_height = 35;
tire_indent_depth = 1.5;
tire_indent_height = 4;
tire_grip_degrees = 15;
tire_grip_radius = 0.74;

// diameter for axis
bore_diameter = 4.5;
bore_diameter_with_key = 3.4;
bore_screw_fixation_diameter = 3.4;

wheel_height = 45;

// the connectors for the inside of the wheel
wheel_connectors = 4;
wheel_connectors_width = 2.1;

// for mount
wheel_mount_offset = 7;
wheel_mount_width = 15;
wheel_mount_depth = 35;
wheel_mount_height = 7;
wheel_mount_tolerance = 0.35;
wheel_mount_slit_width = 0.8;
wheel_mount_sink_height = 3.5;
wheel_mount_sink_radius = 3.5;


// INTERNAL
frame_outer_diameter = wheel_diameter;
frame_outer_radius = frame_outer_diameter / 2;
frame_inner_diameter = frame_outer_diameter - 2 * wheel_thickness;
frame_inner_radius = frame_inner_diameter / 2;

tire_inner_radius = frame_outer_radius;
tire_outer_radius = tire_inner_radius + tire_thickness;

t_i_r = tire_inner_radius;
t_o_r = tire_outer_radius;
t_m_h = tire_middle_height;
t_g_d = tire_grip_degrees;
t_g_r = tire_grip_radius;

b_d = bore_diameter;
b_r = b_d / 2;
w_h = wheel_height;
w_m_o = wheel_mount_offset;
w_m_w = wheel_mount_width;
w_m_d = wheel_mount_depth;
w_m_h = wheel_mount_height;
w_m_t = wheel_mount_tolerance;
w_m_s_w = wheel_mount_slit_width;

b_s_f_d = bore_screw_fixation_diameter;
b_s_f_o = (w_m_w / 2) + (w_m_d/2 - w_m_w/2) / 2;

module indent() {
    difference() {
        union() {
            // main cylinder
          cylinder(h=tire_indent_height - tire_indent_depth, r=frame_outer_radius);
           translate([0, 0, tire_indent_height - tire_indent_depth])
           difference() {
               cylinder(h=tire_indent_depth, r=frame_outer_radius);
               // slope
               cylinder(h=tire_indent_depth, r1=frame_outer_radius - tire_indent_depth, r2=frame_outer_radius);
           }
       }
       cylinder(h=tire_indent_height, r=frame_outer_radius - tire_indent_depth);
       }
}

// https://www.reddit.com/r/openscad/comments/15btcks/need_help_creating_oval_two_parallel_sides/
module oval(d=d,l=l){
  hull(){
    translate([ - (l-d)/2,0])
    circle(d=d);
    translate([(l-d)/2,0]) circle(d=d);
  }
}
  
module wheel() {
    union() {
        difference() {
           cylinder(h=w_h, r=frame_outer_radius);
           cylinder(h=w_h, r=frame_inner_radius);
           translate([0, 0, 0])
           indent();
           translate([0, 0, w_h])
           rotate([180, 0, 0])
           indent();
           translate([0, 0, w_h/2])
           rotate([180, 0, 0])
           indent();
           translate([0, 0, w_h/2])
           indent();
       }
       difference() {
           union() {
               for(i =[0 : 180 / wheel_connectors : 180]) {
                   rotate([0, 0, i])
                    translate([-wheel_connectors_width/2, -frame_inner_radius, 0])
                        cube([wheel_connectors_width, frame_inner_diameter, w_m_o + w_m_h]);
               cylinder(h=w_m_o + w_m_h, r=(w_m_d / 2) * 1.2);
               }
            }
            // for the mount
            translate([0, 0, 1]);
            intersection(){
            cylinder(h=w_h, r=b_r);
            translate([- b_r + (b_d - bore_diameter_with_key), - b_r, 0])
            cube([b_d, b_d, w_h]);
        }
            
            translate([- w_m_w/2 - w_m_t, - w_m_d/2 - w_m_t, w_m_o])
            cube([w_m_w + w_m_t * 2, w_m_d + w_m_t * 2, w_m_h]);
            translate([- w_m_d/2 - w_m_t, - w_m_w/2 - w_m_t, w_m_o])
            cube([w_m_d + w_m_t * 2, w_m_w + w_m_t * 2, w_m_h]);
            for(i =[-1 : 2 : 1]) {
                translate([i * b_s_f_o, 0, 0])
                    linear_extrude(w_h)
                    oval(b_s_f_d, b_s_f_d * 3 / 2);
                
                translate([i * b_s_f_o, 0, 0])
                    linear_extrude(wheel_mount_sink_height )
                    oval(wheel_mount_sink_radius * 2, b_s_f_d * 3 / 2);
            }
        }
    }
}

module axis_mount(side) {
    translate([0, 0, w_m_o])
    difference() {
        union() {
            // slit
            translate([-w_m_w/2, -w_m_d/2, 0])
                cube([w_m_w, w_m_d, w_m_h + b_s_f_d * 3]);
            // mount
            translate([- w_m_d / 2, -w_m_w/2, 0])
                cube([w_m_d, w_m_w, w_m_h]);
        }
        // slit for clamp
        translate([-w_m_s_w/2, -w_m_d/2, 0])
            cube([w_m_s_w, w_m_d, w_m_h + b_s_f_d * 3]);
        // screws for clamp
        for(i =[-1 : 2 : 1]) {
            translate([-b_r - 3.5, i * (b_d/2 + b_s_f_d/2 + 1.5), w_m_h + (b_s_f_d * 3 / 2)])
                rotate([0, 90, 0])
                    cylinder(h=w_m_w, r=b_s_f_d/2);
        }
        // screws for plate
        intersection(){
            cylinder(h=w_h, r=b_r);
            translate([- b_r + (b_d - bore_diameter_with_key), - b_r, 0])
            cube([b_d, b_d, w_h]);
        }
        for(i =[-1 : 2 : 1]) {
            translate([i * b_s_f_o, 0, 0])
                cylinder(h=w_h/2, r=b_s_f_d/2);
        }
        // half
        translate([- w_m_d * side, -w_m_d/2, 0])
        cube([w_m_d, w_m_d, w_m_h + b_s_f_d * 3]);
    }  
}

module tire() {
    t_m_o = (w_h - t_m_h) / 2;
   union() {
       difference() {
           cylinder(h=w_h, r=t_o_r - t_m_o);
           cylinder(h=w_h, r=t_i_r);
       }
       translate([0, 0, 0])
       indent();
       translate([0, 0, w_h])
       rotate([180, 0, 0])
       indent();
       translate([0, 0, w_h/2])
       rotate([180, 0, 0])
       indent();
       translate([0, 0, w_h/2])
       indent();
       difference() {
                   union() {
                    // main section
                    translate([0, 0, t_m_o])
                    cylinder(h=w_h - t_m_o * 2, r=t_o_r);
                    // bottom
                    cylinder(h=t_m_o, r1=t_o_r - t_m_o, r2=t_o_r);
                    // top
                    translate([0, 0, wheel_height])
                    rotate([180, 0, 0])
                    cylinder(h=t_m_o, r1=t_o_r - t_m_o, r2=t_o_r);
                   }
                   cylinder(h=w_h, r=t_i_r);
                   // texture
                   for(i =[0 : t_g_d : 360]) {
                        translate([-sin(i) * t_o_r, -cos(i) * t_o_r, 0])
                            cylinder(h=w_h, r=t_g_r, $fn=32);
           }
       }
   }   
}
//wheel();
//axis_mount(0);
//axis_mount(1);
//color("black", 1.0)
tire();