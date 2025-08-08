import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

void main(List<String> arguments) async {
  OpenFoodAPIConfiguration.userAgent =
      UserAgent(name: 'Your app name', url: 'Your url, if applicable');

  ProductQueryConfiguration config = ProductQueryConfiguration(
    '5000112654523',
    version: ProductQueryVersion.v3,
    language: OpenFoodFactsLanguage.ENGLISH,
  );

  ProductResultV3 product = await OpenFoodAPIClient.getProductV3(config);

  // Packaging
  print("packaging");
  print(product.product?.packaging);

  // Categories
  List<String> here = product.product?.categoriesTags ?? [];
  print("categories");
  for (String tag in here) {
    tag = tag.toLowerCase();
    if (tag.contains("beverage")) {
      print("ok");
    }
  }

  // Quantity parsing
  String quantity = product.product?.quantity ?? "";
  quantity = quantity.toLowerCase();
  String quantityMeasured = "";

  // Check for ml
  int mlFound = quantity.indexOf("ml");
  if (mlFound != -1) {
    quantityMeasured = "ml";
  } else {
    print("I DID NOT FIND ML");

    // Check for fl
    int flFound = quantity.indexOf("fl");
    if (flFound != -1) {
      print("I DID NOT FIND FL");

      quantityMeasured = "fl";
      mlFound = flFound; // reuse position for substring extraction
    } else {
      // Check for l
      int lFound = quantity.indexOf("l");
      if (lFound != -1) {
        print("I DID NOT FIND L");

        quantityMeasured = "l";
        mlFound = lFound;
      } else {
        // Fallback position
        mlFound = 2;
      }
    }
  }

 

  // Extract numeric part
  quantity = quantity.substring(0, mlFound);
  quantity = quantity.replaceAll(" ", "");
  quantity = quantity.replaceAll(",", ".");

  // Parse string to double first
  double doubleQuantity = double.parse(quantity);

  print("WAS ML FOUND?: $mlFound\n");
  print("ORIGINAL QUANTITY UNITS: $quantityMeasured");
  print("ACTUAL QUANTITY (in original units): $doubleQuantity");

  // CONVERT TO ML based on unit
  if (quantityMeasured == "l") {
    doubleQuantity *= 1000; // liters to mL
  } else if (quantityMeasured == "fl") {
    doubleQuantity *= 29.5735; // fluid ounces to mL
  }

  // Print info
  print("THIS IS A $doubleQuantity mL BOTTLE");

}





//goal: return a string of information about the bottle or can 

//Brand, quantity (ML), and return recycling price (depends on the state)



