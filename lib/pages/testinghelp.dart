import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
void main(List<String> arguments) async {
  OpenFoodAPIConfiguration.userAgent = UserAgent(name: 'Your app name', url: 'Your url, if applicable');
  ProductQueryConfiguration config = ProductQueryConfiguration(
    '5449000053879',
    version: ProductQueryVersion.v3,
  );
  ProductResultV3 product = await OpenFoodAPIClient.getProductV3(config);
  //print('Hello world: ${food_facts_project.calculate()}!');
  print("packaging\n");
  print(product.product?.packaging); // Coca Cola Zero
  String here = product.product?.categories?? "nulled";
  here = here.toLowerCase();
  print("categories\n");
  if(here.contains("beverage")){
    print("has be");
  }
  print(here);
}