/**
* Name: BIcycle
* Based on the internal empty template. 
* Author: yudai
* Tags: 
*/


model Bicycle

/* Insert your model definition here */

import "BicycleRoad.gaml"


global{
	float max_bicycle_speed<-20*(1000/3600)*scale#m/#s;//目標速度 km/hをm/sに変換
	float bicycle_width<-1.2;	//0.5m
	float bicycle_length<-5.4;	//1.8m
	float tau<-9#s;
	float lambda<-0.3; //背後から受ける斥力の重み付け
	float road_p;	//道路の境界から受ける斥力の重みづけ
//	float A_road<-4.0;
//	float B_road<-1.7;
//	float A_road<-6;
//	float B_road<-0.8;
	float A_road<-2.3;
	float B_road<-5;
	//自動車用
//	float A_car<-2.7;
//	float B_car<-11.3;
	float A_car<-8;
	float B_car<-12;
	//自転車用
//	float A_bike<-0.8;
//	float B_bike<-0.7;
	float A_bike<-1.7;
	float B_bike<-3.25;
	//歩行者用
	float A_ped<-2;
	float B_ped<-0.5;
	//計測用
	list <float> dead_list<-[0.0];
	float arrive_sum<-0.0;
	int arrive_num<-0;
	//最近接距離
	//自転車目線の自動車との最近接距離の平均
	float ave_b_nearest_c;	
	//自転車目線の自転車との最近接距離の平均
	float ave_b_nearest_b;
	//歩行者目線の自転車との最近接距離
	float ave_p_nearest_b;
	float b_num;//自転車の母数
	float c_num;//歩行者の母数
}

species bicycle{
	list <string> avoid_list<-[]; //自転車、車、歩行者のうち回避するものをstringでリストに入れる
	bool left_start; 
//	make_roadで使用するもの(目的地によって変容しうる変数)
	//走行中の道路
	bicycle_road use_road;
	//走行中の道路の位置
	list use_road_point;
	//自転車の中心点
	point location;
	//1ステップ当たりに進む距離
	point move_vector;
	//色
	rgb color;
	//目標地点
	point target_point;
	//回避の時に参照するパラメータ
	float dodge;
	//目標地点から受ける引力
	point gra_p;
	//エージェントの斥力
	point agent_p;
	//道路から受ける斥力
	point road_p;
	//回避ベクトルが生まれなかった時のための力
	point as_p;
	//スポーンした時間
	float spawn_time<-time;
	//車間距離
	//自動車との最近接距離距離
	float b_nearest_car<-150#m;
	//自転車との最近接距離
	float b_nearest_bi<-150.0;
	
	init{
		//shapeに反映
		shape<-polygon([
			location + {-bicycle_length/2, -bicycle_width/2},
		    location + {bicycle_length/2, -bicycle_width/2},
		    location + {bicycle_length/2, bicycle_width/2},
		    location + {-bicycle_length/2, bicycle_width/2}
		]);
		//走行中の道路
		use_road<-one_of(bicycle_road where(self overlaps each));
		self.spawn_time<-time;

	}
	
	//目標地点から受ける引力の計算(単位はm/s)
	point update_gravity{
		//目標地点までのベクトル
		point target_vector<-target_point-location;
		//単位ベクトルに変換
		point per_direction_vector<-target_vector/norm(target_vector);
		//目標速度に変換
		point wish_vector<-(per_direction_vector*max_bicycle_speed);
		return (wish_vector-move_vector*(1/step))/tau;
	}
	
	//道路から受ける斥力を求める(道路の境界からの距離に比例する)
	point add_road_repulsion{
			point ans<-{0,0};
			float d_to_target<-self.location distance_to target_point;
		loop i from:0 to:(length(use_road.shape.points)-2){
			point s<-self.use_road.shape.points[i];//道路の始点
			point e<-self.use_road.shape.points[i+1];//道路の終点
			point np<-nearest_edge_v(s,e,self.location);//自転車と最も近い点
			float d_from_edge<-self.location distance_to np;
			if(d_from_edge)<5.0 and d_to_target>5.0 and self.location!=np{
				point d_r<-(self.location-np)*scale;
				point e_r<-(d_r/norm(d_r));//自転車が逃げる方向の単位ベクトル
				point g<-e_r*(A_road*(exp(-1*norm(d_r)/B_road)));
				ans<-ans+g;
			}
		}
		return ans;
	}


	//道路の最近接点からエージェントまでのベクトルを返す
	point nearest_edge_v(point s,point e,point a){
		float s_to_a<-s distance_to a;

		float a_to_e<-a distance_to e;

		point vector_s_to_e<-e-s;
		float t<-((a-s)*(e-s))/((e-s)*(e-s));
		t <- max(0.0, min(1.0, t));
		point nearest_vector<-s+(e-s)*t;
		return nearest_vector;
	}
	
	
	//影響を受ける範囲にいる自転車群をまとめる
	list<agent> affect_agents{
		list<agent> all_agents <- (bicycle where (self != each)) as list;
		if ("pedestrian" in avoid_list){
			all_agents<- all_agents+(pedestrian as list);
		}
		if ("car" in avoid_list){
			all_agents<- all_agents+(car as list);
		}
		list<agent> circle_agents<-all_agents where((each distance_to self)<25#m);
	//双曲線内にいるエージェント
		list<agent> affect_list<-circle_agents where(
			((((move_vector*(self.location-each.location))*(move_vector*(self.location-each.location)))/(sqrt(3)/2)*(sqrt(3)/2))
			-(((move_vector*(self.location-each.location))*(move_vector*(self.location-each.location)))/(1/2)*(1/2)))>(-1)
		);
//		write("-----------"+affect_list);
		return affect_list;
	}
	
	//近接エージェントから受ける斥力を一つ一つ計算し、合計した斥力をベクトルで返す
	point add_repulsion{
		list<agent> calculate_list<-affect_agents();
		point repulsion_vector<-{0,0};
		self.as_p<-{0,0};
		loop i over: calculate_list{
			//自転車の時
			if(i is bicycle){
				repulsion_vector<-repulsion_vector+calc_repulsion_bicycle(bicycle(i));
				self.as_p<-self.as_p+repulsion_assist(bicycle(i));
//				write("あしすとぱわー"+self.as_p);
			}
			//自動車の時
			if(i is car){
				point cal_car_power<-calc_repulsion_car(car(i));
				repulsion_vector<-repulsion_vector+cal_car_power;
//				write("車から受ける斥力"+cal_car_power);

			}
			
			//歩行者の時
			if(i is pedestrian){
				point cal_p_power<-calc_repulsion_pedestrian(pedestrian(i));
				repulsion_vector<-repulsion_vector+cal_p_power;
//				write("歩行者から受ける斥力"+cal_p_power);
			}
			

		}
		return repulsion_vector;
	}
	
	reflex calc_nearest{
		list<agent> near_agents<-car as list;
		near_agents<-near_agents+(bicycle where(each!=self));
		list<agent> circle_agents<-near_agents where((each distance_to self)<60#m);
		if(!empty(near_agents)){
		loop age over:near_agents{
			if(age is bicycle){
//				write("-----------------");
				float d_b<-(age distance_to self);
//				write("自転車との距離"+d_b);
//				write("-----------------");
				if(self.b_nearest_bi>d_b){
					self.b_nearest_bi<-d_b;
				}
			}
			else if(age is car){
				float b_c<-(age distance_to self);
				write("b_c"+b_c);
				if(self.b_nearest_car>b_c){
					b_nearest_car<-b_c;
				}
			}
		}
		
		}
	}
	
	//selfから最も近い点を返す 1つ目の配列がself
	list<point> return_nearest_point(agent a_agent){
		list<point> v1<-a_agent.shape closest_points_with(self.shape);
		return v1;
	}
	
	//一つの自転車から受ける斥力を計算する
	point calc_repulsion_bicycle(bicycle a_bicycle){
		point self_n_point;
		point opponent_n_point;
		list <point> nl<-return_nearest_point(a_bicycle);
		if(nl[0]!=nl[1]){
		self_n_point<-nl[1];
		opponent_n_point<-nl[0];
		}else{
			self_n_point<-self.location;
			opponent_n_point<-a_bicycle.location;
		}

		//エージェントから主体までのベクトルd
		point d_v<-(self_n_point-opponent_n_point)*scale;
		//φを求める
		float phi<-angle_between(self_n_point,opponent_n_point-self_n_point,self.move_vector);
		float ganma<- lambda+(1-lambda)*((1+cos(phi))/2);
		point relative_speed<-a_bicycle.move_vector-self.move_vector;//論文中のyの式にあたる
		point e<-((d_v/norm(d_v))+((d_v-relative_speed)/norm((d_v-relative_speed))))*(0.5);
		float b<-0.5*(sqrt((norm(d_v)+norm(d_v-relative_speed))*(norm(d_v)+norm(d_v-relative_speed))-(norm(relative_speed)*norm(relative_speed))));//Δtは反応速度
		b<-max(0.000000001,b);
		point g<-e*(A_bike*(max(0.1,exp(-b/B_bike)))*((norm(d_v)+norm(d_v-relative_speed))/(2*b)));
//		write("b:"+b);

		return g*ganma;
	}
	
		//一つの歩行者から受ける斥力を計算する
		point calc_repulsion_pedestrian(pedestrian a_pedestrian){
			point self_n_point;
			point opponent_n_point;
			
			list <point> nl<-return_nearest_point(a_pedestrian);
			if(nl[0]!=nl[1]){
			self_n_point<-nl[1];
			opponent_n_point<-nl[0];
			}else{
				self_n_point<-self.location;
				opponent_n_point<-a_pedestrian.location;
			}
			
			//エージェントから主体までのベクトルd
			point d_v<-(self_n_point-opponent_n_point)*scale;
			//φを求める
			float phi<-angle_between(self_n_point,opponent_n_point-self_n_point,self.move_vector);
			float ganma<- lambda+(1-lambda)*((1+cos(phi))/2);
			point relative_speed<-a_pedestrian.velocity-self.move_vector;//論文中のyの式にあたる
			point e<-((d_v/norm(d_v))+((d_v-relative_speed)/norm((d_v-relative_speed))))*(0.5);
			float b<-0.5*(sqrt((norm(d_v)+norm(d_v-relative_speed))*(norm(d_v)+norm(d_v-relative_speed))-(norm(relative_speed)*norm(relative_speed))));//Δtは反応速度
			b<-max(0.000000001,b);
			point g<-e*(A_ped*(max(0.1,exp(-b/B_ped)))*((norm(d_v)+norm(d_v-relative_speed))/(2*b)));
//			write("b:"+b);
	
			return g*ganma;
			}
		
		//一つの車から受ける斥力を計算する
		point calc_repulsion_car(car a_car){
		point self_n_point;
		point opponent_n_point;
		
		list <point> nl<-return_nearest_point(a_car);
		if(nl[0]!=nl[1]){
		self_n_point<-nl[1];
		opponent_n_point<-nl[0];
		}else{
			self_n_point<-self.location;
			opponent_n_point<-a_car.location;
		}

		//エージェントから主体までのベクトルd
		point d_v<-(self_n_point-opponent_n_point)*scale;
		//φを求める
//		float phi<-angle_between(self.location,a_car.location-self.location/norm(a_car.location-self.location),self.move_vector/norm(self.move_vector));
		float phi<-angle_between(self.location,a_car.location,self.move_vector+self.location);
		float ganma<- lambda+(1-lambda)*((1+cos(phi))/2);
//		write("a_car.location-self.location:"+(a_car.location-self.location)/norm(a_car.location-self.location)+"self.move_vector"+self.move_vector/norm(self.move_vector));
//		write("cos(phi)の値:"+cos(phi));
//		write("cos45の値:"+cos(45));
//		write("rnd(1,10)"+rnd(1,10));
//		write(acos({0,1},{1,0}));
		point relative_speed<-a_car.move_vector-self.move_vector;//論文中のyの式にあたる
		point e<-((d_v/norm(d_v))+((d_v-relative_speed)/norm((d_v-relative_speed))))*(0.5);
		float b<-0.5*(sqrt((norm(d_v)+norm(d_v-relative_speed))*(norm(d_v)+norm(d_v-relative_speed))-(norm(relative_speed)*norm(relative_speed))));//Δtは反応速度
		b<-max(0.000000001,b);
		point g<-e*(A_car*(max(0.1,exp(-b/B_car)))*((norm(d_v)+norm(d_v-relative_speed))/(2*b)));
//		write("b:"+b);
//		write("自転車が自動車から受けるg"+g);
//		write("ganmaの値："+ganma);
		return g*ganma;
	}
	
	
	//斥力がmove_vectorと同一方向にしか働かないか判定し、回避
	point repulsion_assist(bicycle a_bicycle){

		if (norm(self.agent_p)!=0){
//			float naiseki<-(self.agent_p/norm(self.agent_p))*(self.move_vector/norm(self.move_vector));
			float naiseki<-(calc_repulsion_bicycle(a_bicycle)/norm(calc_repulsion_bicycle(a_bicycle)))*(self.move_vector/norm(self.move_vector));
//			write("エージェント"+a_bicycle.color+"から受ける斥力"+calc_repulsion_agent(a_bicycle));
			//内積が-1から誤差10**-2以内であれば衝突検知
			float naiseki_error<-naiseki+1;
//			write("エージェント"+a_bicycle.color+"からの内積は"+naiseki);
//			write("内積"+naiseki_error);
			if((-0.01)<naiseki_error and naiseki_error<0.01){
				
				write("------衝突検知---------");
				float x1<-move_vector.x;
				float y1<-move_vector.y;
				
				//位置が高いほうが上へよける
				if(self.location.y<a_bicycle.location.y){	//自分が上の時
//					write("私が上");
					if(self.move_vector.x>0){ //yは負
						//左へ
//						write("左に回避1"+{y1,-x1}*0.1);
						return {y1,-x1}*0.01;
					}else{
						//右へ
//						write("右に回避1"+{-y1,x1}*0.1);
						return {-y1,x1}*0.01;
					}
				}else{	//自分が下の時yは正
//				write("私がした");
					if(self.move_vector.x>0){
						//右へ
//						write("右に回避2"+{-y1,x1}*0.1);
						return {-y1,x1}*0.01;
					}else{
						//左へ
//						write("左に回避2"+{y1,-x1}*0.1);
						return {y1,-x1}*0.01;
					}
				}
	
				}

		}else{
			return {0,0};
		}
	}
	
	
	//消去
	action check_finish{
		use_road<-one_of(bicycle_road where(self overlaps each));
		bool is_arrive<-overlaps(self.shape,self.target_point);
//		write("目的地に到着した？"+is_arrive);
//		use_road_point<-use_road.shape.points;

		if(is_arrive){
			write("###############到着までにかかった時間"+(time-self.spawn_time));
			
			dead_list<-dead_list+(time-self.spawn_time);
			arrive_sum<-arrive_sum+(time-self.spawn_time);
			arrive_num<-arrive_num+1;
			
			}
//		}else if(use_road=nil and (50.0<self.bicycle_point.x and self.bicycle_point.x<70.0)){
//			dead_list<-dead_list+(time-self.spawn_time);
//			arrive_sum<-arrive_sum+(time-self.spawn_time);
//			arrive_num<-arrive_num+1;
//		}
		if (use_road=nil or is_arrive){
			write("最終地点:"+self.location);
			//自転車の最近接距離を集計
			if(self.b_nearest_car<100#m){
				ave_b_nearest_c<-ave_b_nearest_c+((self.b_nearest_car)/scale);
			}
			if(self.b_nearest_bi<100#m){
				ave_b_nearest_b<-ave_b_nearest_b+(self.b_nearest_bi/scale);
			}
			
			b_num<-b_num+1;

			do die;
		}
	}
	
	//移動
	action move{
	
		//力をm/sに変換
//		write("目標への引力:"+self.gra_p+"m/s");
//		write("自転車から受ける斥力"+self.agent_p+"m/s");
//		write("道路から受ける斥力"+self.road_p+"m/s");	
//		write("アシストの力"+self.as_p+"m/s");
//		write("現在の移動速度:"+self.move_vector*(1/step)+"m/s");
//		write("時速:"+norm(self.move_vector*(1/step))*(3600/1000)+"km/h");

		//引力
		self.gra_p<-update_gravity();
		//斥力
		self.agent_p<-add_repulsion();
		//道路から受ける斥力
		self.road_p<-add_road_repulsion();
	
		
		self.move_vector<-self.move_vector+(self.gra_p+self.agent_p+self.road_p+self.as_p)*step;
//		write("回避以前のmove:"+move_vector);
//		write("衝突回避:"+repulsion_assist());
//		move_vector<-move_vector+repulsion_assist()*step;
//		write("以後のmove:"+move_vector);
		//1m/sを0.1m/sに変換
//		move_vector<-move_vector*0.1;
//		write("move_vector:"+move_vector);
//		write("エージェントの速度:"+norm(move_vector)*(1/step)+"m/s");
		location<-location+move_vector;
		shape<-polygon([
			location + {-bicycle_length/2, -bicycle_width/2},
		    location + {bicycle_length/2, -bicycle_width/2},
		    location + {bicycle_length/2, bicycle_width/2},
		    location + {-bicycle_length/2, bicycle_width/2}
		]);
	}
	
	
	
	reflex move_action{
//		write("-----ここから-----"+self.color);
		do check_finish;
		do move;
//		write("self:場所"+self.location);
//		write("生まれた時間:"+self.spawn_time);
//		write("*****現在の時刻******"+time);
//		write("---------ここまで---------"+self.color);
//		write("到着リスト"+dead_list);
		if(arrive_num>0 ){
//		write("合計時間"+arrive_sum);
//		write("平均時間:"+arrive_sum/arrive_num);
		}
	}
	

	aspect base{
		draw shape color:self.color at:location;
	}
}

