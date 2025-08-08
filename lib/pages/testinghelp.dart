import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:openfoodfacts/openfoodfacts.dart';


void main(List<String> arguments) async {
  OpenFoodAPIConfiguration.userAgent = UserAgent(name: 'Your app name', url: 'Your url, if applicable');
  ProductQueryConfiguration config = ProductQueryConfiguration(
    '5000112654523',
    version: ProductQueryVersion.v3,
    language: OpenFoodFactsLanguage.ENGLISH,
  );
  ProductResultV3 product = await OpenFoodAPIClient.getProductV3(config);
  //print('Hello world: ${food_facts_project.calculate()}!');
  print("packaging\n");
  print(product.product?.packaging); // Coca Cola Zero
  List<String> here = product.product?.categoriesTags??[];
  print("categories\n");
  for (String tag in here){
    tag = tag.toLowerCase();
    if(tag.contains("beverage")){
      print("ok");
    }
  }
  //Quantity
  //
  String quantity = product.product?.quantity??"";
  quantity = quantity.toLowerCase();
  String quantityMeasured = "";
  int fluidFound = quantity.indexOf("ml");
  if (fluidFound == -1){
    fluidFound = quantity.indexOf("fl");
    if (fluidFound == -1){
      fluidFound = quantity.indexOf("l");
      quantityMeasured = "l";
      if (fluidFound == -1){
        fluidFound = 2;
      }
      }
      else{
      quantityMeasured = "l"; 
      }
    }
  else{
      quantityMeasured = "ml"; 
  }
  quantity = quantity.substring(0,fluidFound);
  quantity = quantity.replaceAll(" ", "");
  quantity = quantity.replaceAll(",", ".");
  double doubleQuantity = double.parse(quantity);
  print(fluidFound);
  print(quantityMeasured);
  print(doubleQuantity);
  //quantity = quantity.substring(0,fluidFound);
  //print(quantity);
} 