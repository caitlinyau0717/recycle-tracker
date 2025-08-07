class Bottle {
  String brand;
  String name;
  String image; // Assuming image is a URL or path to the image
  double value;

  Bottle(this.brand, this.name, this.image, this.value);

  Map<String, dynamic> toJson() {
    return {'brand': brand, 'name': name, 'image': image, 'value': value};
  }
}
