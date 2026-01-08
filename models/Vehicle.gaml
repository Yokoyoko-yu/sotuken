/**
* Name: Vehicle
* Based on the internal empty template. 
* Author: yudai
* Tags: 
*/


model Vehicle

/* Insert your model definition here */

import "Main.gaml"


 species vehicle skills:[driving]{
 	point view_loc; //車のlocation（表示位置）を表す
 	bool drive_ov; //再走行を許可する
 	float ave_speed; //車の平均速度(結果用）
 	float total_speed; //車の速度の総和
 	int drive_step <- 0; //走行ステップ数
 	int total_time <- 0; //走行時間（drive_step * step)
 	bool drived <- false;
 	bool arrived <- false;
 
 	init{
 		right_side_driving <- false;
 	}
 	
 	 action driving_action{

		do drive;   //drive action
 	 }

 	 point calc_loc{
 	 	if road(current_road).num_lanes = nil {
 	 		write"V55";
 	 		
 	 	}
 	  	float val <- (road(current_road).num_lanes - current_lane) + 0.5;
 	  	val <- on_linked_road ? val * - 1 : val;
 	  	if (val = 0) {
			return location;
		}
		else {
			return (location - {cos(heading + 90) * val, sin(heading + 90) * val});
		}
 	 }

 }