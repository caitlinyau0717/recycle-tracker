//Class to represent the structure of a bottle in the database
class Bottle {
  final String _brand;
  final String _name;
  final double _value;
  final DateTime _timestamp;

  Bottle(this._brand, this._name, this._value, this._timestamp);

  String getBrand(){
    String brand = _brand;
    return brand;
  }

  double getValue(){
    return _value;
  }

  //Turn into JSON for database insertion
  Map<String, dynamic> toJson() {
    return {'name': _name, 'brand': _brand,' value': _value, 'created_at' : _timestamp};
  }
}
