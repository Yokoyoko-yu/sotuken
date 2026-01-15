/**
* Name: MakeRoad
* Based on the internal empty template. 
* Author: yudai
* Tags: 
*/


model MakeRoad

/* Insert your model definition here */

import "Pedestrian_road.gaml"
import "road_ori.gaml"
import "BicycleRoad.gaml"

species make_road{
	//共通
	point start;
	point end;
	//車道
	bool one_way; //一方通行か否か
	int speed; //制限速度
	int p_lane;
	int m_lane;
	int road_width; //車道の幅員(単位はm)
	float center_line;	//センターラインの幅員
	float sholder; //路肩
	float bicycle_line;//自転車専用通行帯
	//ここから歩道
	float g_l;//ガードレール
	float bicy_l;//自転車専用道
	float green_l;//植樹帯
	float walk_l;//歩行者道
	float walk_bi_l;//自転車歩行者道

	init{
		//車道の作成
		create road with:[
			one_way:one_way,
			speed:speed,
			p_lane:p_lane,
			m_lane:m_lane,
			road_width:road_width,
			center_line:center_line,
			sholder:sholder,
			bicycle_line:bicycle_line,
			start:start,
			end:end,
			shape:polyline([start,end])
		];
		float car_shift<-(center_line/2+road_width+sholder+bicycle_line)*scale; //車道の横幅(歩道に使う)
//		write("car_shift"+car_shift);
		//歩道の作成
		create pedestrian_road with:[
			start:self.start,
			end:self.end,
			g_l:self.g_l,
			bicy_l:self.bicy_l,
			green_l:self.green_l,
			walk_l:self.walk_l,
			walk_bi_l:self.walk_bi_l,
			shift:car_shift,
			one_way:one_way
		];
		
		//自転車道の作成
		float bicy_s;//センターラインから自転車道のスタートまでの距離
		if(sholder>0){	//路肩走行
			bicy_s<-center_line/2+road_width;
		}else if(bicycle_line>0){	//自転車レーン
			bicy_s<-center_line/2+road_width+sholder;
		}else if(bicy_l>0){	//自転車専用道
			bicy_s<-center_line/2+road_width+sholder+g_l;
		}else if(walk_bi_l>0){	//自転車歩行者道
			bicy_s<-center_line/2+road_width+sholder+g_l+green_l;
		}
		bicy_s<-bicy_s*scale;
		//自転車上側
		//路肩走行の時
		if(self.sholder>0){
			//上側
				create bicycle_road with:[
				width:(self.sholder+self.road_width),
				length:300,
				start_p:start-{0,(self.sholder+self.road_width+center_line/2)*scale}
			];
			//下側
			create bicycle_road with:[
				width:(self.sholder+self.road_width),
				length:300,
				start_p:start+{0,(center_line/2)*scale}
			];
		
		}else{
			//上側
			create bicycle_road with:[
			width:max(self.sholder,self.bicycle_line,self.bicy_l,walk_bi_l),//どれか一つしか存在しないためmaxで取得できる
			length:300,
			start_p:start-{0,bicy_s+max(self.sholder,self.bicycle_line,self.bicy_l,walk_bi_l)*scale}
			];
			//下側
			create bicycle_road with:[
				width:max(self.sholder,self.bicycle_line,self.bicy_l,walk_bi_l),
				length:300,
				start_p:start+{0,bicy_s}
			];
		}
		
		
	
	}
	
	float bicycle_start{
		if(sholder>0){	//路肩走行
			return (center_line/2+road_width)*scale;
		}else if(bicycle_line>0){	//自転車レーン
			return (center_line/2+road_width+sholder)*scale;
		}else if(bicy_l>0){	//自転車専用道
			return (center_line/2+road_width+sholder+g_l)*scale;
		}else if(walk_bi_l>0){	//自転車歩行者道
			return (center_line/2+road_width+sholder+g_l+green_l)*scale;
		}
	}
}

experiment road_test type:gui{
	point A<-{0,50};
	point B<-{300,50};
	init{
		create make_road with:[
			start:A,
			end:B,
			one_way:false,
			speed:60,
			p_lane:1,
			m_lane:1,
			center_line:2,
			road_width:3,
			sholder:0.5,
			bicycle_line:0,
			g_l:0,
			bicy_l:0,
			green_l:1.5,
			walk_l:2,
			walk_bi_l:0
		];
		write("bi_r"+one_of(bicycle_road).shape);
	}
	output{
    display d type: opengl background:#cornsilk{
      species road aspect: base;
      species pedestrian_road aspect:base;
      species bicycle_road aspect:base;
    }
  }
}


experiment road_test3 type:gui{
	point A<-{0,50};
	point B<-{300,50};
	init{
		create make_road with:[
			start:A,
			end:B,
			one_way:false,
			speed:60,
			p_lane:1,
			m_lane:1,
			center_line:0,
			road_width:3,
			sholder:0,
			bicycle_line:0,
			g_l:0,
			bicy_l:0,
			green_l:1,
			walk_l:0,
			walk_bi_l:4
		];
//		create bicycle with:[
//			location:{0,34},
//			move_vector:{2,0},
//			color:#black,
//			target_point:{300,34}
//		];
//		create bicycle with:[
//			location:{300,27},
//			move_vector:{-2,0},
//			color:#black,
//			target_point:{0,26}
//		];
		write("bi_r"+one_of(bicycle_road).shape);
		write("to_bi_r"+one_of(make_road).bicycle_start());
	}
	output{
    display d type: opengl background:#cornsilk{
      species road aspect: base;
      species pedestrian_road aspect:base;
      species bicycle_road aspect:base;
      species bicycle aspect:base;
    }
  }
}