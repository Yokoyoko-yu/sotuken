/**
* Name: Pedestrianroad
* Based on the internal empty template. 
* Author: yudai
* Tags: 
*/


model Pedestrianroad

/* Insert your model definition here */

import "Main.gaml"
import "road_ori.gaml"

species pedestrian_road skills:[pedestrian_road]{
	point start; //道路の始点
	point end; //道路の終点
	float walk_l;//歩行者道
	float walk_bi_l;//自転車歩行者道
	float green_l;//植樹帯
	float g_l;//ガードレール
	
	init{
		float car_l; //車道の中心から端までの距離
	}
	
}