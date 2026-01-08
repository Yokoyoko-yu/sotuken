/**
* Name: roadori
* Based on the internal empty template. 
* Author: yudai
* Tags: 
*/


model roadori

/* Insert your model definition here */
import "Main.gaml"

species road skills:[road_skill] parallel:true schedules:[]{
	bool oneway;
	int width;	//描画用の太さ
	rgb color;
	bool one_way; //一方通行か否か
	int speed; //制限速度
	int p_lane;
	int m_lane;
	int road_width; //車道の幅員(単位はm)
	float center_line;	//センターラインの幅員
	float sholder; //路肩
	float bicycle_line;//自転車専用通行帯
	float all_length;
	point start;
	point end;
	float shift;
	float car_shift; //中心線から車道までのずれ　normalcarで描画の際に使う
	init{
		self.all_length<-(center_line/2+road_width+sholder+bicycle_line);
		write("端まで"+self.all_length+"m");
		//小さいので道路をすべて3倍する
		road_width<-road_width*scale;
		center_line<-center_line*scale;
		sholder<-sholder*scale;
		bicycle_line<-bicycle_line*scale;
		car_shift<-(center_line+road_width)/2;
	}
	aspect base{
		shift<-0.0;
		//センターライン
		if(center_line>0){
			draw polygon([start-{0,center_line/2},start+{0,center_line/2},end+{0,center_line/2},end-{0,center_line/2}])
			color:#white;
		}
		shift<-shift+(center_line/2);
		//車道
		if(road_width>0){
			draw polygon([start-{0,shift+road_width},start-{0,shift},end-{0,shift},end-{0,shift+road_width}]) color:#black;
			
			draw polygon([start+{0,shift},start+{0,shift+road_width},end+{0,shift+road_width},end+{0,shift}]) color:#black;
		}
		shift<-shift+road_width;
		//路肩
		if(sholder>0){
			draw polygon([start-{0,shift+sholder},start-{0,shift},end-{0,shift},end-{0,shift+sholder}]) color:#gray;
			
			draw polygon([start+{0,shift},start+{0,shift+sholder},end+{0,shift+sholder},end+{0,shift}]) color:#gray;
		}
		shift<-shift+sholder;
		//自転車専用通行帯
		if(bicycle_line>0){
			draw polygon([start-{0,shift+bicycle_line},start-{0,shift},end-{0,shift},end-{0,shift+bicycle_line}]) color:#blue;
			
			draw polygon([start+{0,shift},start+{0,shift+bicycle_line},end+{0,shift+bicycle_line},end+{0,shift}]) color:#blue;
		}
		
	}
}



species road_make{
	init{
		create road with:[
			width:50,
			color:#gray,
			one_way:false,
			speed:60,
			p_lane:1,
			m_lane:1,
			road_width:3,
			center_line:2.0,
			sholder:0.5,
			bicycle_line:0,
			start:{0,50},
			end:{100,50},
			shape:polyline([{0,50},{100,50}])
			
		]{
			if(one_way=false){
				create road with:[
				width:50,
				color:#gray,
				one_way:false,
				speed:60,
				p_lane:1,
				m_lane:1,
				road_width:3,
				center_line:2.0,
				sholder:0.5,
				bicycle_line:0,
				start:{100,50},
				end:{0,50},
				shape:polyline([{100,50},{0,50}])
				];
			}
		}
		
		
	}
}

experiment c type:gui{
	 
		init{
			create road_make number:1 ;
			
			}
			
			output{
				display main type:opengl background:#cornsilk{
					species road aspect: base;
					
				}
			}
					
}