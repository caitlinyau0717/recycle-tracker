import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class StateBottleRules {
  final double depositSmall;  // e.g., < 24 fl oz, or single deposit if fixed
  final double depositLarge;  // e.g., >= 24 fl oz, or null if no volume differentiation
  final double depositSpecial; // e.g. boxed wine special rate, can be null
  final List<String> includedCategories;  // categories eligible for deposit
  final List<String> excludedCategories;  // categories excluded from deposit

  StateBottleRules({
    required this.depositSmall,
    this.depositLarge = 0.0,
    this.depositSpecial = 0.0,
    this.includedCategories = const [],
    this.excludedCategories = const [],
  });
}


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
  print("ORIGINAL QUANTITY (in original units): $doubleQuantity");

  // CONVERT TO ML based on unit
  if (quantityMeasured == "l") {
    doubleQuantity *= 1000; // liters to mL
  } else if (quantityMeasured == "fl") {
    doubleQuantity *= 29.5735; // fluid ounces to mL
  }

  // Print info
  print("THIS IS A $doubleQuantity mL BOTTLE");  

  //will convert into a function to return a string later.

}

//TODO: return a string of information about the bottle or can 
//String will contain brand, quantity (ML), and return recycling price (depends on the state)


final Map<String, double> depositByState = {
};



String getBottleInfo(String brand, double quantityML, String state) {
  double recyclingPrice = getRecyclingPrice(state);
  return "Brand: $brand\nQuantity: $quantityML mL\nRecycling Price: \$$recyclingPrice";
}

double getRecyclingPrice(String state) {
  return 0;
}
