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
  print("Hi. packaging\n");
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
  int milliletersFound = quantity.indexOf("ml");
  if (milliletersFound == -1){
    print("I DID NOT FIND MILLILITERS. NOW I WILL ENTER IF STATEMENTS");
    milliletersFound = quantity.indexOf("fl");
    if (milliletersFound == -1){
      milliletersFound = quantity.indexOf("l");
      quantityMeasured = "l";
      if (milliletersFound == -1){
        milliletersFound = 2;
      }
      }
      else{
      quantityMeasured = "l"; 
      }
    }
  else{
      quantityMeasured = "ml"; 
  }
  quantity = quantity.substring(0,milliletersFound);
  quantity = quantity.replaceAll(" ", "");
  quantity = quantity.replaceAll(",", ".");
  double doubleQuantity = double.parse(quantity);
  print(milliletersFound);
  print(quantityMeasured);
  print(doubleQuantity);
  //quantity = quantity.substring(0,fluidFound);
  //print(quantity);
} 