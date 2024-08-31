include <BOSL2/std.scad>

$fn = 32;
wheel_diameter = 70;
wheel_thickness = 1.5;
tire_thickness = 7;
tire_middle_height = 11;
tire_indent_depth = 0.7;
tire_indent_height = 4;
tire_grip_degrees = 15;
tire_grip_radius = 1.5;
bore_diameter = 4.5;
bore_diameter_with_key = 3.5;
bore_screw_fixation_diameter = 3.4;
wheel_height = 19;
wheel_connectors = 4;
wheel_connectors_width = 1;
hexagon_radius = 4.5;
wheel_mount_offset = 4;
wheel_mount_width = 9;
wheel_mount_depth = 21;
wheel_mount_height = 4;
wheel_mount_tolerance = 0.35;
wheel_mount_slit_width = 0.8;
wheel_mount_sink_height = 1.5;
wheel_mount_sink_radius = 3.5;


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
b_s_f_d = bore_screw_fixation_diameter;
h_r = hexagon_radius;
w_m_o = wheel_mount_offset;
w_m_w = wheel_mount_width;
w_m_d = wheel_mount_depth;
w_m_h = wheel_mount_height;
w_m_t = wheel_mount_tolerance;
w_m_s_w = wheel_mount_slit_width;

module indent() {
    difference() {
        union() {
           cylinder(h=tire_indent_height - tire_indent_depth, r=frame_outer_radius);
           translate([0, 0, tire_indent_height - tire_indent_depth])
           difference() {
               cylinder(h=tire_indent_depth, r=frame_outer_radius);
               cylinder(h=tire_indent_depth, r1=frame_outer_radius - tire_indent_depth, r2=frame_outer_radius);
           }
       }
       cylinder(h=tire_indent_height, r=frame_outer_radius - tire_indent_depth);
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
                translate([i * (w_m_w/2 + b_s_f_d), 0, 0])
                    cylinder(h=w_h, r=b_s_f_d/2);
                translate([i * (w_m_w/2 + b_s_f_d), 0, 0])
                    cylinder(h=wheel_mount_sink_height, r=wheel_mount_sink_radius);
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
                cube([w_m_w, w_m_d, w_m_h + b_s_f_d * 2]);
            // mount
            translate([- w_m_d / 2, -w_m_w/2, 0])
                cube([w_m_d, w_m_w, w_m_h]);
        }
        // slit for clamp
        translate([-w_m_s_w/2, -w_m_d/2, 0])
            cube([w_m_s_w, w_m_d, w_m_h + b_s_f_d * 2]);
        // screws for clamp
        for(i =[-1 : 2 : 1]) {
            translate([-b_r - 3.5, i * (b_r + b_s_f_d/2 + 1), w_m_h + b_s_f_d])
                rotate([0, 90, 0])
                    cylinder(h=b_d + 7, r=b_s_f_d/2);
        }
        // screws for plate
        intersection(){
            cylinder(h=w_h, r=b_r);
            translate([- b_r + (b_d - bore_diameter_with_key), - b_r, 0])
            cube([b_d, b_d, w_h]);
        }
        for(i =[-1 : 2 : 1]) {
            translate([i * (w_m_w/2 + b_s_f_d), 0, 0])
                cylinder(h=w_h/2, r=b_s_f_d/2);
        }
        // half
        translate([- w_m_d * side, -w_m_d/2, 0])
        cube([w_m_d, w_m_d, w_m_h + b_s_f_d * 2]);
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
                            cylinder(h=w_h, r=t_g_r);
           }
       }
   }   
}
wheel();
//axis_mount(0);
//color("black", 1.0)
//tire();