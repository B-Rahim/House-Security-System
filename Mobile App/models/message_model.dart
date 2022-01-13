class Message {
  int id;
  String content;
  String datetime;
  String phone;

  Message({this.content,  this.phone, this.datetime});
  Message.withId({this.id,this.content,  this.phone, this.datetime});

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {};
    if(id != null)
      map['id'] = id;
    map['content'] = content;
    map['datetime'] = datetime;
    map['phone'] = phone;
      return map;
  }

  factory Message.fromMap( Map<String, dynamic> map){
     return Message.withId(
         id: map['id'],
         content: map['content'],
         phone: map['phone'],
         datetime: map['datetime']
     );
  }
}


