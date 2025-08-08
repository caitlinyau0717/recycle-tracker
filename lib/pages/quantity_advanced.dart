import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

//StateBottleRules class
class StateBottleRules {
  final double? depositSmall;
  final double? depositLarge;
  final double? depositSpecial;
  final List<String> includedCategories;
  final List<String> excludedCategories;
  final double? volumeBreakpointFlOz; // <= this

  StateBottleRules({
    this.depositSmall,
    this.depositLarge,
    this.depositSpecial,
    required this.includedCategories,
    this.excludedCategories = const [],
    this.volumeBreakpointFlOz, // <= this
  });
}

//MAP FOR STATE BOTTLE DEPOSIT RULES
final Map<String, StateBottleRules> stateRules = {
  'CA': StateBottleRules(
    depositSmall: 0.05, // <= 24 fl oz
    depositLarge: 0.10, // > 24 fl oz
    depositSpecial: 0.25, // boxed wine, wine pouches, cartons
    includedCategories: [
      'beer', 'soft drinks', 'water', 'boxed wine', 'wine pouches', 'cartons'
    ],
    excludedCategories: [
      'milk', 'vegetable juice > 16oz', 'fruit juice >=46oz', 'baby formula'
    ],
    volumeBreakpointFlOz: 24, // to help logic
  ),

  'CT': StateBottleRules(
    depositSmall: 0.10,
    includedCategories: [
      'beer', 'soft drinks', 'water', 'carbonated water'
    ],
    excludedCategories: [
      'milk', 'juice', 'mineral water'
    ],
  ),

  'HI': StateBottleRules(
    depositSmall: 0.05,
    includedCategories: [
      'beer', 'soft drinks', 'water', 'juice', 'wine', 'liquor'
    ],
  ),

  'IA': StateBottleRules(
    depositSmall: 0.05,
    includedCategories: [
      'beer', 'carbonated soft drinks', 'wine coolers', 'liquor'
    ],
    excludedCategories: [
      'milk', 'non-carbonated water', 'juice'
    ],
  ),

  'ME': StateBottleRules(
    depositSmall: 0.05,
    depositLarge: 0.15, // liquor and wine
    includedCategories: [
      'fruit juice soda', 'beer', 'bottled water', 'liquor', 'wine'
    ],
    excludedCategories: [
      'blueberry juice', 'apple cider produced in Maine'
    ],
  ),

  'MA': StateBottleRules(
    depositSmall: 0.05,
    includedCategories: [
      'carbonated beverages'
    ],
  ),

  'MI': StateBottleRules(
    depositSmall: 0.10,
    includedCategories: [
      'soft drinks', 'soda water', 'carbonated natural water', 'mineral water',
      'nonalcoholic carbonated drink', 'beer', 'ale', 'malt drink', 'kombucha'
    ],
  ),

  'OR': StateBottleRules(
    depositSmall: 0.10,
    includedCategories: [
      'water', 'flavored water', 'beer', 'malt beverages'
    ],
    excludedCategories: [
      'wine', 'liquor', 'dairy', 'plant-based milk', 'meal replacement', 'infant formula'
    ],
  ),

  'VT': StateBottleRules(
    depositSmall: 0.05,
    depositLarge: 0.15,
    includedCategories: [
      'beer', 'malt', 'soda', 'mixed wine drinks', 'liquor'
    ],
  ),

  'NY': StateBottleRules(
    depositSmall: 0.05,
    includedCategories: [
      'beer', 'malt beverages', 'carbonated soft drinks', 'mineral water',
      'soda water', 'non-carbonated fruit juice', 'non-carbonated vegetable juice',
      'wine coolers'
    ],
    excludedCategories: [
      'milk', 'dairy alternatives', 'liquor', 'wine', 'spirits', 'juice >= 1 gallon', 'infant formula'
    ],
  ),
};

//CONVERT ANY QUANTITY TO FL OZ
double? convertQuantityToFlOz(String quantityStr) {
  if (quantityStr.isEmpty) return null;

  String quantity = quantityStr.toLowerCase().trim();

  // Default to ml if no units found
  String unit = 'ml';

  // Detect unit and set position to slice numeric part
  int unitIndex = -1;
  if (quantity.contains('ml')) {
    unit = 'ml';
    unitIndex = quantity.indexOf('ml');
  } else if (quantity.contains('fl oz')) {
    unit = 'fl oz';
    unitIndex = quantity.indexOf('fl oz');
  } else if (quantity.contains('fl')) {
    // 'fl' by itself is ambiguous but assume fl oz for now
    unit = 'fl oz';
    unitIndex = quantity.indexOf('fl');
  } else if (quantity.contains('l')) {
    unit = 'l';
    unitIndex = quantity.indexOf('l');
  } else {
    // No units found, try to parse as ml by default
    unitIndex = quantity.length;
  }

  // Extract numeric part (substring before unit)
  String numberPart = quantity.substring(0, unitIndex).replaceAll(RegExp(r'[ ,]'), '.');

  // Parse to double
  double? value;
  try {
    value = double.parse(numberPart);
  } catch (e) {
    return null; // Parsing failed
  }

  // Convert to fl oz
  switch (unit) {
    case 'ml':
      return value / 29.5735;
    case 'l':
      return value * 33.814; // 1 L = 33.814 fl oz
    case 'fl oz':
      return value;
    default:
      return null; // Unknown unit
  }
}


//TODO: make a function to return brand, quantity, and recycling price based on openfoodfacts api and the state.
String getBottleInfo(String brand, double quantityFlOz, String state) {
  double recyclingPrice = getRecyclingPrice(state);
  return "Brand: $brand\nQuantity: $quantityFlOz fl oz\nRecycling Price: \$$recyclingPrice";
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



