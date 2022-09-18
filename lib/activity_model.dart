class ActivityModel{
  String? fallDate;
  String? fallTime;
  String? uid;

  ActivityModel({this.fallDate,this.fallTime,this.uid});

  Map<String,dynamic> toJson()=>{
    'fall_date':fallDate,
    'fall_time':fallTime,
    'uid':uid,
  };

  static ActivityModel fromJson(Map<String,dynamic>json)=>ActivityModel(
    fallDate: json['fall_date'],
    fallTime: json['fall_time'],
    uid: json['uid'],
  );

}