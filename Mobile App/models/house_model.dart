
class House {
  House( { String phone, String name, String address} )
      :this._name=name, this._phone=phone, this._address=address;
  int _id;
  String _name;
  String _phone;
  String _address;

  int get id => _id;
  String get name => _name;
  String get phone => _phone;
  String get address => _address;

  // TODO: add conditions to setters
  set name(String newN){
    this._name = newN;
  }
  set phone(String newP){
    this._phone = newP;
  }
  set address(String newA){
    this._address = newA;
  }

  Map<String, dynamic> toMap(){
    var  map = Map<String, dynamic>();
    if(_id!=null)
      map['id'] = _id;

    map['name'] = _name;
    map['phone'] = _phone;
    map['address'] = _address;
    return map;
  }
  House.fromMap(Map<String,dynamic> map){
    this._id = map['id'];
    this._name = map['name'];
    this._phone = map['phone'];
    this._address = map['address'];
  }
}
