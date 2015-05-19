             //////////////////////////////////////////////////////////////////////
            // Supermount v7 Single                                             //
           // super practical super customizable mount for E3Dv6               //
          // and similar groove mount hotends and standard capacitive         //
         // sensors, compatible to the Prusa i3 Einstein Rework's            //
        // X carriage                                                       //
       //                                                                  //
      // created by Moritz Walter                                         //
     // licensed under GPLv3 http://www.gnu.org/copyleft/gpl.html        //
    //                                                                  //
   // known issues / todos:                                            //
  // pivots not consistent (but reasonable)                           //
 // translation/rotation order not consistent (and not reasonable)   //
//////////////////////////////////////////////////////////////////////

use <oh_gear.scad>;

    ////////////////////
  // WHAT TO RENDER //
////////////////////

render_all=true;
render_supermount=false;
render_bracket=false;
render_assembled=false;
render_emboss=false;

if(render_supermount || render_all){
	supermount();
}
if(render_bracket || render_all){
	if(render_assembled){
		hotend_mount_bracket();
	}else{
		hotend_mount_bracket_printable();
	}
}
//supermount_core();
//hotend_mount_screw_cutouts();

    //////////////////////////////
  // CONFIGURATION PARAMETERS //
//////////////////////////////

rounded_corner_radius=2; // how round shall it be?
overlap=0.1; // this is a generic helper, setting it to zero may cause defects in geometry
bridging_helper_height=0.2; // should be about the layer height
bridging_helper_width=0.8; // should be about once or twice the nozzle size

// groove mount dimensions
hotend_groove_mount_diameter=16;
hotend_groove_mount_groove_diameter=12;
hotend_groove_mount_upper_ring_height=3.7;
hotend_groove_mount_groove_height=6;
hotend_groove_mount_lower_ring_height=3;
hotend_groove_mount_height=hotend_groove_mount_lower_ring_height+hotend_groove_mount_groove_height+hotend_groove_mount_upper_ring_height;

// other hotend dimensions
hotend_collet_diameter=7;
hotend_collet_height=1.2;
hotend_liner_diameter=4;
hotend_total_height=62.3;
hotend_heatsink_diameter=26;
hotend_heatsink_clearance=30; // important
hotend_heatsink_height=30;
hotend_heatsink_offset=-16.7-hotend_heatsink_height;

// hotend mount parameters
hotend_mount_bracket_thickness=7;
hotend_mount_screws_offset=9; // offset from center of hotend
hotend_mount_bracket_gap=1;
hotend_mount_screw_length=23;
hotend_mount_screw_head_length=20;
hotend_mount_screw_depth=hotend_mount_screw_length-0.25*hotend_groove_mount_diameter-hotend_mount_bracket_gap-3;
hotend_mount_screw_diameter=3.4;
hotend_mount_screw_head_diameter=7.5;
hotend_mount_nut_diameter=6.5;
hotend_mount_nut_height=3;
hotend_mount_slot_height=20;
hotend_mount_slot_offset=3;

hotend_vertical_clearance=0.1; // should be adjusted first when encountering fitting problems (if loose, reduce)
hotend_horizontal_clearance=0.1; // should be adjusted first when encountering fitting problems (if loose, reduce)

// dimensions of the sensor
sensor_tip_height=9;
sensor_total_height=72;
sensor_thread_height=49;
sensor_diameter=16.5;
sensor_thread_diameter=18;

// parameters of the sensor mount
sensor_mount_outer_diameter=28.5;
sensor_mount_height=30;
sensor_vertical_clearance=0.1;
sensor_horizontal_clearance=0.2;

// parameters of the mounting plate
plate_w=36; //34 vs 56
plate_h=36; //36 vs 68
plate_t=3;

plate_screw_slot_length=20;
plate_screw_nut_height=3.5;
plate_screw_length=15;
plate_screw_nut_diameter=8.8;
plate_screw_diameter=4.8;
plate_screw_distance=23;

nut_cutout_dia=8.66;
nut_cutout_h=plate_t-3;
screw_cutout_dia=4.8;
screw_cutout_dist=23;

// parameters of the endstop trigger
endstop_pos=[30,35,0];
endstop_arm_thickness=5;

// position of sensor and hotend, mostly generic but could be manually entered
hotend_sensor_distance=34; // note this as x-offset in your firmware
hotend_offset=[hotend_sensor_distance/2,plate_h/2 ,25]; // note to myself [-3,3.5,38.5];
sensor_offset=[-hotend_sensor_distance/2,hotend_offset[1]-hotend_total_height,hotend_offset[2]];
hotend_holding_angle=-atan(sensor_offset[0]/sensor_offset[2]);

// open hardware gear embossing
oh_gear_emboss_pos=[-8.5,-5.5,sensor_offset[2]+sensor_mount_outer_diameter/2];
oh_gear_emboss_depth=0.8;
oh_gear_emboss_scale=0.2;



// printing plate parameters
hotend_mount_bracket_priting_offset=[0,endstop_pos[1],0];

    /////////////
  // MODULES //
/////////////

module oh_gear_emboss_logo(){
		translate(oh_gear_emboss_pos)
			translate([0,0,-oh_gear_emboss_depth])
				scale([oh_gear_emboss_scale,oh_gear_emboss_scale,1])
						translate([0,2.55,-overlap])
							oh_gear(2*oh_gear_emboss_depth+overlap);
}

module oh_gear_emboss_cutout(){
		translate(oh_gear_emboss_pos)
			translate([0,0,-oh_gear_emboss_depth])
				scale([oh_gear_emboss_scale,oh_gear_emboss_scale,1])
						cylinder(r=31,h=2*oh_gear_emboss_depth,$fn=36);
}
module oh_gear_emboss_flatten(){
		translate(oh_gear_emboss_pos)
			translate([0,0,-oh_gear_emboss_depth/2])
				scale([oh_gear_emboss_scale,oh_gear_emboss_scale,1])
						cylinder(r=31,h=2*oh_gear_emboss_depth,$fn=36);
}
				
module endstop_core(){
	hull(){
		translate()
			translate([endstop_pos[0]-overlap-rounded_corner_radius,endstop_pos[1]-hotend_groove_mount_height/2+rounded_corner_radius,endstop_pos[2]])
				cube([overlap,hotend_groove_mount_height-2*rounded_corner_radius,endstop_arm_thickness]);
		translate([plate_w/2-overlap-rounded_corner_radius,plate_h/2-hotend_groove_mount_height+rounded_corner_radius,0])
			cube([overlap,hotend_groove_mount_height-2*rounded_corner_radius,endstop_arm_thickness]);
	}
}

module hotend_mount_bracket_printable(){
	translate(hotend_mount_bracket_priting_offset)
		translate([0,0,-hotend_mount_bracket_gap-0.25*hotend_groove_mount_diameter])
			rotate([0,-hotend_holding_angle,0])
				translate(-hotend_offset)
					hotend_mount_bracket_supported();
}


module supermount(){
	difference(){
		supermount_block();
		plate_cutoff();
		hotend_cutout();
		sensor_cutout();
		hotend_mount_screw_cutouts();
		plate_screws();
		if(render_emboss){
			difference(){
				oh_gear_emboss_cutout();
				oh_gear_emboss_logo();
			}
			oh_gear_emboss_flatten();
		}
	}
}

/*
module supermount_core(){
		import("hotendHolder_v3_supermount_core.stl");
}
*/

module supermount_core(){
	difference(){
		union(){
			hull(){
				supermount_core_plate();
				supermount_core_hotend();
				supermount_core_sensor();
			}
			endstop_core();
		}
		supermount_core_hotend_cutout();
		supermount_core_heatsink_cutout();
		supermount_core_sensor_cutout();
	}
}

module supermount_core_plate(){
	translate([-plate_w/2+rounded_corner_radius,-plate_h/2+rounded_corner_radius,0])
		cube([plate_w-2*rounded_corner_radius,plate_h-2*rounded_corner_radius,overlap]);
}

module supermount_core_hotend(){
	translate(hotend_offset)
		rotate([-90,0,0])
			translate([0,0,-hotend_groove_mount_height+rounded_corner_radius])
				cylinder(r=hotend_groove_mount_diameter/2+hotend_mount_bracket_thickness-rounded_corner_radius,h=hotend_groove_mount_height-2*rounded_corner_radius,$fn=32);		
}

module supermount_core_hotend_cutout(){
	if(hotend_offset[1]<plate_h/2){
		// hotend cutout
		hull(){
			translate(hotend_offset)
				rotate([-90,0,0])
					translate([5,0,-rounded_corner_radius])
						cylinder(r=hotend_groove_mount_diameter/2+hotend_mount_bracket_thickness+rounded_corner_radius,h=plate_h,$fn=32);
			translate(hotend_offset)
				rotate([-90,0,0])
					translate([-5,0,-rounded_corner_radius])
						cylinder(r=hotend_groove_mount_diameter/2+hotend_mount_bracket_thickness+rounded_corner_radius,h=plate_h,$fn=32);
		}
	}
}

module supermount_core_heatsink_cutout(){
	hull(){
		translate([plate_w/2-rounded_corner_radius,hotend_offset[1]-hotend_total_height-hotend_groove_mount_height+rounded_corner_radius,0])
			cube([hotend_heatsink_clearance,hotend_total_height,overlap]);
		translate([hotend_offset[0],hotend_offset[1]-hotend_total_height-hotend_groove_mount_height,hotend_offset[2]])
			rotate([-90,0,0])
				cylinder(r=hotend_heatsink_clearance/2+rounded_corner_radius,h=hotend_total_height+rounded_corner_radius,$fn=32);
		translate([hotend_offset[0],hotend_offset[1]-hotend_total_height-hotend_groove_mount_height,hotend_offset[2]+hotend_groove_mount_diameter/2+hotend_mount_bracket_thickness])
			rotate([-90,0,0])
				cylinder(r=hotend_heatsink_clearance/2+rounded_corner_radius,h=hotend_total_height+rounded_corner_radius,$fn=32);
	}
}

module supermount_core_sensor(){
	translate([sensor_offset[0],sensor_offset[1]+sensor_tip_height+sensor_thread_height/2-sensor_mount_height/2+rounded_corner_radius,sensor_offset[2]])
		rotate([-90,0,0])
			cylinder(r=sensor_mount_outer_diameter/2-rounded_corner_radius,h=sensor_mount_height-2*rounded_corner_radius,$fn=32);
}

module supermount_core_sensor_cutout(){
	hull(){
		translate([sensor_offset[0],sensor_offset[1]+sensor_tip_height+sensor_thread_height/2+sensor_mount_height/2-rounded_corner_radius,sensor_offset[2]])
			rotate([-90,0,0])
				cylinder(r=sensor_mount_outer_diameter/2+rounded_corner_radius,h=sensor_total_height,$fn=32);
		translate([-plate_w/2-sensor_mount_outer_diameter,sensor_offset[1]+sensor_tip_height+sensor_thread_height/2+sensor_mount_height/2-rounded_corner_radius,0])
			cube([sensor_mount_outer_diameter+rounded_corner_radius,sensor_total_height,overlap]);
	}	
}

module supermount_block(){
	minkowski(){
		supermount_core();
		sphere(r=rounded_corner_radius,$fn=16);
	}
}


module sensor_dummy(){
	translate([0,0,0])
		cylinder(r=sensor_diameter/2,h=sensor_total_height,$fn=32);
	translate([0,0,sensor_tip_height])
		cylinder(r=sensor_thread_diameter/2,h=sensor_thread_height,$fn=32);
	
}

module hotend_cutout_core(){
	translate(hotend_offset)
		rotate([-90,0,0])
			rotate([0,0,hotend_holding_angle])
				union(){
					translate([0,0,-hotend_groove_mount_height-overlap])
						cylinder(r=hotend_groove_mount_diameter/2+hotend_horizontal_clearance,h=hotend_groove_mount_lower_ring_height+overlap+hotend_vertical_clearance,$fn=32);
					translate([0,0,-hotend_groove_mount_groove_height-hotend_groove_mount_upper_ring_height-overlap])
						cylinder(r=hotend_groove_mount_groove_diameter/2+hotend_horizontal_clearance,h=hotend_groove_mount_groove_height+2*overlap,$fn=32);
					translate([0,0,-hotend_groove_mount_upper_ring_height-hotend_vertical_clearance])
						cylinder(r=hotend_groove_mount_diameter/2+hotend_horizontal_clearance,h=hotend_groove_mount_upper_ring_height+2*hotend_vertical_clearance,$fn=32);
					translate([0,0,-overlap])
						cylinder(r=hotend_collet_diameter/2+hotend_horizontal_clearance,h=hotend_collet_height+hotend_vertical_clearance+overlap,$fn=32);
				}
}

module hotend_cutout_core_bracket(){
	translate(hotend_offset)
		rotate([-90,0,0])
			rotate([0,0,hotend_holding_angle])
				union(){
					translate([0,0,-hotend_groove_mount_height+bridging_helper_width])
						cylinder(r=hotend_groove_mount_diameter/2+hotend_horizontal_clearance,h=hotend_groove_mount_lower_ring_height+hotend_vertical_clearance-bridging_helper_width,$fn=32);
					translate([0,0,-hotend_groove_mount_groove_height-hotend_groove_mount_upper_ring_height+bridging_helper_width+hotend_vertical_clearance])
						cylinder(r=hotend_groove_mount_groove_diameter/2+hotend_horizontal_clearance,h=hotend_groove_mount_groove_height-2*hotend_vertical_clearance-2*bridging_helper_width,$fn=32);
					translate([0,0,-hotend_groove_mount_upper_ring_height-hotend_vertical_clearance])
						cylinder(r=hotend_groove_mount_diameter/2+hotend_horizontal_clearance,h=hotend_groove_mount_upper_ring_height+hotend_vertical_clearance-bridging_helper_width,$fn=32);
				}
}

module hotend_cutout_extension(){
	translate(hotend_offset)
		rotate([-90,0,0])
			rotate([0,0,hotend_holding_angle])
				union(){
					translate([-hotend_heatsink_clearance/2,-0.25*hotend_groove_mount_diameter-2*(hotend_groove_mount_diameter+hotend_mount_bracket_thickness),-hotend_groove_mount_height-overlap])
						cube([(hotend_heatsink_clearance),2*(hotend_groove_mount_diameter+hotend_mount_bracket_thickness),hotend_groove_mount_height+2*overlap]);
					
					//the slide
					translate([-hotend_groove_mount_diameter/2-hotend_horizontal_clearance,-hotend_groove_mount_diameter/2-overlap,-hotend_groove_mount_height-overlap])
						cube([hotend_groove_mount_diameter+2*hotend_horizontal_clearance,hotend_groove_mount_diameter/2+overlap,hotend_groove_mount_lower_ring_height+hotend_vertical_clearance+overlap]);
					translate([-hotend_groove_mount_groove_diameter/2-hotend_horizontal_clearance,-hotend_groove_mount_diameter/2-overlap,-hotend_groove_mount_upper_ring_height-hotend_groove_mount_groove_height-overlap])
						cube([hotend_groove_mount_groove_diameter+2*hotend_horizontal_clearance,hotend_groove_mount_diameter/2+overlap,hotend_groove_mount_groove_height+2*overlap]);
					translate([-hotend_groove_mount_diameter/2-hotend_horizontal_clearance,-hotend_groove_mount_diameter/2-overlap,-hotend_groove_mount_upper_ring_height-hotend_vertical_clearance])
						cube([hotend_groove_mount_diameter+2*hotend_horizontal_clearance,hotend_groove_mount_diameter/2+overlap,hotend_groove_mount_upper_ring_height+hotend_vertical_clearance+overlap]);
				}
}

module hotend_mount_bracket_supported(){
	intersection(){
		translate(hotend_offset)
			rotate([-90,0,0])
				rotate([0,0,hotend_holding_angle])
						translate([-hotend_heatsink_clearance/2+hotend_mount_bracket_gap,-hotend_mount_bracket_gap-0.25*hotend_groove_mount_diameter-2*(hotend_groove_mount_diameter+hotend_mount_bracket_thickness),-hotend_groove_mount_height-overlap])
							cube([(hotend_heatsink_clearance),2*(hotend_groove_mount_diameter+hotend_mount_bracket_thickness),hotend_groove_mount_height+2*overlap]);
		difference(){
			supermount_block();
			hotend_cutout_core_bracket();
			hotend_mount_screw_cutouts();
		}
	}
}

module hotend_mount_bracket(){
	intersection(){
		translate(hotend_offset)
			rotate([-90,0,0])
				rotate([0,0,hotend_holding_angle])
						translate([-hotend_heatsink_clearance/2+hotend_mount_bracket_gap,-hotend_mount_bracket_gap-0.25*hotend_groove_mount_diameter-2*(hotend_groove_mount_diameter+hotend_mount_bracket_thickness),-hotend_groove_mount_height-overlap])
							cube([(hotend_heatsink_clearance),2*(hotend_groove_mount_diameter+hotend_mount_bracket_thickness),hotend_groove_mount_height+2*overlap]);
		difference(){
			supermount_block();
			hotend_cutout_core();
			hotend_mount_screw_cutouts();
		}
	}
}

module hotend_mount_screw_cutouts(){
	translate(hotend_offset)
		rotate([-90,0,0])
			rotate([0,0,hotend_holding_angle])
				union(){
					//slot
					hull(){
						translate([-hotend_mount_screws_offset,hotend_mount_screw_depth-hotend_mount_slot_offset,-hotend_groove_mount_upper_ring_height-hotend_groove_mount_groove_height/2])
							rotate([90,0,0])
								rotate([0,0,180/6])
									cylinder(r=hotend_mount_nut_diameter/2,h=hotend_mount_nut_height+overlap,$fn=6);
						translate([-hotend_mount_screws_offset,hotend_mount_screw_depth-hotend_mount_slot_offset,-hotend_groove_mount_upper_ring_height-hotend_groove_mount_groove_height/2+hotend_mount_slot_height])
							rotate([90,0,0])
								rotate([0,0,180/6])
									cylinder(r=hotend_mount_nut_diameter/2,h=hotend_mount_nut_height+overlap,$fn=6);
					}
					//screw
					translate([-hotend_mount_screws_offset,hotend_mount_screw_depth-overlap,-hotend_groove_mount_upper_ring_height-hotend_groove_mount_groove_height/2])
						rotate([90,0,0])
							cylinder(r=hotend_mount_screw_diameter/2,h=hotend_mount_screw_length+overlap,$fn=16);
					//head
					translate([-hotend_mount_screws_offset,hotend_mount_screw_depth-hotend_mount_screw_length,-hotend_groove_mount_upper_ring_height-hotend_groove_mount_groove_height/2])
						rotate([90,0,0])
							cylinder(r=hotend_mount_screw_head_diameter/2,h=hotend_mount_screw_head_length,$fn=16);
					
					//slot
					hull(){
						translate([hotend_mount_screws_offset,hotend_mount_screw_depth-hotend_mount_slot_offset,-hotend_groove_mount_upper_ring_height-hotend_groove_mount_groove_height/2])
							rotate([90,0,0])
								rotate([0,0,180/6])
									cylinder(r=hotend_mount_nut_diameter/2,h=hotend_mount_nut_height+overlap,$fn=6);
						translate([hotend_mount_screws_offset,hotend_mount_screw_depth-hotend_mount_slot_offset,-hotend_groove_mount_upper_ring_height-hotend_groove_mount_groove_height/2+hotend_mount_slot_height])
							rotate([90,0,0])
								rotate([0,0,180/6])
									cylinder(r=hotend_mount_nut_diameter/2,h=hotend_mount_nut_height+overlap,$fn=6);
					}
					//screw
					translate([hotend_mount_screws_offset,hotend_mount_screw_depth-overlap,-hotend_groove_mount_upper_ring_height-hotend_groove_mount_groove_height/2])
						rotate([90,0,0])
							cylinder(r=hotend_mount_screw_diameter/2,h=hotend_mount_screw_length+overlap,$fn=16);
					//head
					translate([hotend_mount_screws_offset,hotend_mount_screw_depth-hotend_mount_screw_length,-hotend_groove_mount_upper_ring_height-hotend_groove_mount_groove_height/2])
						rotate([90,0,0])
							cylinder(r=hotend_mount_screw_head_diameter/2,h=hotend_mount_screw_head_length,$fn=16);
				}
}


module hotend_cutout(){
	union(){
		hotend_cutout_core();
		hotend_cutout_extension();
	}
}

module sensor_cutout(){
	translate(sensor_offset)
		rotate([-90,0,0])
			cylinder(r=sensor_thread_diameter/2+sensor_horizontal_clearance,h=sensor_total_height,$fn=32);
}

module hotend_dummy(){
	translate([0,0,-hotend_groove_mount_lower_ring_height-hotend_groove_mount_groove_height-hotend_groove_mount_upper_ring_height])
		cylinder(r=hotend_groove_mount_diameter/2,h=3,$fn=32);
	translate([0,0,-hotend_groove_mount_groove_height-hotend_groove_mount_upper_ring_height-overlap])
		cylinder(r=hotend_groove_mount_groove_diameter/2,h=hotend_groove_mount_groove_height+2*overlap,$fn=32);
	translate([0,0,-hotend_groove_mount_upper_ring_height])
		cylinder(r=hotend_groove_mount_diameter/2,h=hotend_groove_mount_upper_ring_height,$fn=32);
	translate([0,0,-hotend_total_height])
		cylinder(r=hotend_liner_diameter/2,h=hotend_total_height,$fn=32);
	translate([0,0,-overlap])
		cylinder(r=hotend_collet_diameter/2,h=hotend_collet_height+overlap,$fn=32);
	translate([0,0,hotend_heatsink_offset])
		cylinder(r=hotend_heatsink_diameter/2,h=hotend_heatsink_height,$fn=32);
}


module corner_mink(){
	difference(){
		sphere(r=rounded_corner_radius,$fn=32);
		translate([0,0,-rounded_corner_radius-overlap])
		cube([2*(rounded_corner_radius+overlap),2*(rounded_corner_radius+overlap),2*(rounded_corner_radius+overlap)],center=true);
	}	
}

module plate_cutoff(){
	translate([-plate_w-endstop_pos[0],-plate_h-endstop_pos[1],-rounded_corner_radius-overlap])
		cube([2*(plate_w+endstop_pos[0]),2*(plate_h+endstop_pos[1]),rounded_corner_radius+overlap]);
}

module plate_screws(){
	for(y=[-0.5:1:0.5]){
		for(x=[-0.5:1:0.5]){
			translate([x*screw_cutout_dist,y*screw_cutout_dist,0]){
				translate([0,0,-overlap])
					cylinder(r=plate_screw_diameter/2,h=plate_t+2*overlap,$fn=16);
				translate([0,0,plate_t+plate_screw_nut_height+bridging_helper_height])
					cylinder(r=plate_screw_diameter/2,h=plate_screw_length-plate_t-plate_screw_nut_height-bridging_helper_height,$fn=16);
				hull(){
					translate([0,0,plate_t])
						//rotate([0,0,180/6])
							cylinder(r=plate_screw_nut_diameter/2,h=plate_screw_nut_height+overlap,$fn=6);
					translate([x*2*plate_screw_slot_length,0,plate_t])
						//rotate([0,0,180/6])
							cylinder(r=plate_screw_nut_diameter/2,h=plate_screw_nut_height+overlap,$fn=6);
				}
			}
		}
	}
}