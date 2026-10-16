/* ====================================================================
   Parametric Arduino + 1602 LCD Enclosure (Screw-Free Snap-Fit Version)
   - Zero screws for case closure (Interlocking snap-ridge + groove)
   - Corner screw posts removed for maximum interior wire clearance
   - Complete 3.33mm through-holes retained for LCD mounting
   - Overall Dimensions: 81mm (L) x 81mm (W) x 66mm (H)
   ==================================================================== */

$fn = 60;

// --- Main Enclosure Dimensions (mm) ---
box_l        = 81.0;   // 8.1 cm
box_w        = 81.0;   // 8.1 cm
box_h        = 66.0;   // 6.6 cm
wall         = 2.8;    // Slightly thicker 2.8mm wall for snap groove depth
floor_thick  = 2.4;    // Base floor thickness
corner_r     = 4.0;    // Outer corner radius

// --- Snap-Fit Joint Parameters ---
lid_h        = 6.0;    // 6.0mm top plate thickness
base_h       = box_h - lid_h;
snap_tab_h   = 5.5;    // Depth of lid skirt tabs inside the base
snap_ridge_w = 0.65;   // Depth of snap ridge (solid positive locking)
snap_ridge_h = 1.4;    // Height of snap ridge
joint_gap    = 0.25;   // Clearance tolerance for 3D printing fit

// --- LCD 16x2 Dimensions & Vertex Hole Offsets ---
lcd_cutout_w = 71.5;   // Rectangular hole width (Length)
lcd_cutout_h = 24.5;   // Rectangular hole height (Breadth)
lcd_offset_y = 10.0;   // Shift towards back/top of the lid

// LCD Screw Hole Parameters (3.33mm diameter complete through-hole)
lcd_mount_hole_d    = 3.33; 
lcd_hole_offset_raw = 3.75; 
lcd_hole_inset_adj  = 1.0;  // Shifted inward by 1.0mm for unbroken walls
lcd_hole_offset_x   = lcd_hole_offset_raw - lcd_hole_inset_adj; 
lcd_hole_offset_y   = lcd_hole_offset_raw;

// --- Potentiometer (White Rod) ---
pot_r        = 3.0;    // 3mm radius (6mm diameter)
pot_offset_x = 9.5;    // Shifted +0.95 cm (+9.5 mm) to the right
pot_offset_y = -21.5;

// --- Ports & Cutouts ---
usb_w        = 13.5;
usb_h        = 12.5;
usb_z        = 6.5;

pt100_size   = 10.0;   // 1 cm square
pt100_z      = 15.0;   // 1.5 cm from floor

// --- Render Selector ---
// 1 = Base Only, 2 = Lid Only, 3 = Both Side-by-Side
render_mode  = 3;


// ====================================================================
// Geometry Helpers
// ====================================================================

module rounded_rect(l, w, h, r) {
    hull() {
        translate([r, r, 0]) cylinder(r=r, h=h);
        translate([l - r, r, 0]) cylinder(r=r, h=h);
        translate([l - r, w - r, 0]) cylinder(r=r, h=h);
        translate([r, w - r, 0]) cylinder(r=r, h=h);
    }
}

// LCD Mounting Holes (Complete 3.33mm through-holes)
module lcd_mounting_holes() {
    rect_x0 = (box_l - lcd_cutout_w) / 2;
    rect_x1 = rect_x0 + lcd_cutout_w;
    rect_y0 = (box_w - lcd_cutout_h) / 2 + lcd_offset_y;
    rect_y1 = rect_y0 + lcd_cutout_h;

    translate([rect_x0 - lcd_hole_offset_x, rect_y1 + lcd_hole_offset_y, 0]) children();
    translate([rect_x1 + lcd_hole_offset_x, rect_y1 + lcd_hole_offset_y, 0]) children();
}


// ====================================================================
// 1. Enclosure Base Box (With Snap Grooves)
// ====================================================================
module enclosure_base() {
    difference() {
        // Outer body
        rounded_rect(box_l, box_w, base_h, corner_r);
        
        // Main hollow interior
        translate([wall, wall, floor_thick])
            rounded_rect(box_l - 2*wall, box_w - 2*wall, base_h + 1, max(1, corner_r - wall));

        // Horizontal Snap Grooves inside the left and right inner walls
        snap_z_pos = base_h - snap_tab_h * 0.65;
        
        // Left inner wall groove
        translate([wall - snap_ridge_w - 0.2, box_w/2 - 16, snap_z_pos])
            cube([snap_ridge_w + 0.3, 32, snap_ridge_h + 0.3]);

        // Right inner wall groove
        translate([box_l - wall - 0.1, box_w/2 - 16, snap_z_pos])
            cube([snap_ridge_w + 0.3, 32, snap_ridge_h + 0.3]);

        // Front Pry Notch (for opening lid with fingernail or flathead)
        translate([box_l/2 - 7, -1, base_h - 1.6])
            cube([14, wall + 2, 2.0]);

        // USB Type-B Port
        translate([(box_l - usb_w)/2, -1, floor_thick + usb_z])
            cube([usb_w, wall + 2, usb_h]);

        // PT100 Square Hole (1.5 cm height)
        translate([-1, (box_w - pt100_size)/2, floor_thick + pt100_z])
            cube([wall + 2, pt100_size, pt100_size]);

        // Rear ventilation slits
        for (i = [-2 : 2]) {
            translate([box_l/2 + i*7 - 1.5, box_w - wall - 1, floor_thick + 8])
                cube([3, wall + 2, 25]);
        }
    }
}


// ====================================================================
// 2. Enclosure Top Lid (With Snap-Fit Ridge Skirt)
// ====================================================================
module enclosure_lid() {
    rect_x0 = (box_l - lcd_cutout_w) / 2;
    rect_y0 = (box_w - lcd_cutout_h) / 2 + lcd_offset_y;
    skirt_l = box_l - 2*(wall + joint_gap);
    skirt_w = box_w - 2*(wall + joint_gap);
    snap_z_pos = -(snap_tab_h * 0.65);

    difference() {
        union() {
            // Solid 6.0 mm lid plate
            rounded_rect(box_l, box_w, lid_h, corner_r);

            // Perimeter snap skirt extending downwards
            translate([wall + joint_gap, wall + joint_gap, -snap_tab_h])
                difference() {
                    rounded_rect(skirt_l, skirt_w, snap_tab_h, max(1, corner_r - wall));
                    translate([1.8, 1.8, -0.5])
                        rounded_rect(skirt_l - 3.6, skirt_w - 3.6, snap_tab_h + 1, max(1, corner_r - wall - 1.8));
                }

            // Left snap bead (ridge) on outer face of skirt
            translate([wall + joint_gap - snap_ridge_w, box_w/2 - 15, snap_z_pos])
                hull() {
                    cube([snap_ridge_w, 30, snap_ridge_h * 0.4]);
                    translate([snap_ridge_w, 0, snap_ridge_h * 0.8])
                        cube([0.1, 30, 0.1]);
                }

            // Right snap bead (ridge) on outer face of skirt
            translate([box_l - (wall + joint_gap), box_w/2 - 15, snap_z_pos])
                hull() {
                    cube([snap_ridge_w, 30, snap_ridge_h * 0.4]);
                    translate([-snap_ridge_w, 0, snap_ridge_h * 0.8])
                        cube([0.1, 30, 0.1]);
                }
        }

        // Rectangular LCD Cutout (71.5mm x 24.5mm complete through-cut)
        translate([rect_x0, rect_y0, -snap_tab_h - 2])
            cube([lcd_cutout_w, lcd_cutout_h, lid_h + snap_tab_h + 4]);

        // 2 LCD Mounting Screw Holes (3.33mm complete through-holes)
        lcd_mounting_holes() {
            translate([0, 0, -snap_tab_h - 2])
                cylinder(d=lcd_mount_hole_d, h=lid_h + snap_tab_h + 4);
        }

        // Potentiometer Hole (Radius 3.0mm, Shifted Right 9.5mm)
        translate([box_l/2 + pot_offset_x, box_w/2 + pot_offset_y, -snap_tab_h - 2])
            cylinder(r=pot_r, h=lid_h + snap_tab_h + 4);
    }
}


// ====================================================================
// Render Output
// ====================================================================
if (render_mode == 1) {
    enclosure_base();
} else if (render_mode == 2) {
    enclosure_lid();
} else if (render_mode == 3) {
    // Both arranged side-by-side
    enclosure_base();
    translate([box_l + 12, 0, 0])
        enclosure_lid();
}
