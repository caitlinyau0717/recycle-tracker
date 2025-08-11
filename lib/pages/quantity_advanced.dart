import 'package:openfoodfacts/openfoodfacts.dart';

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
List<String> water = ['water'];
List<String> milks = ['milk', 'Dairies', 'Dairy'];
List<String> fruit = ['nectar', 'fruit', 'juice'];
List<String> baby = ['baby'];
List<String> mineralWater = ['mineral'];
List<String> wine = ['wine'];
List<String> altMilk = ['milk alternatives'];
List<String> beer = ['beer'];
List<String> sodas = ['beer', 'malt', 'soda', 'mineral'];
bool Exclude(String categories, List<List<String>> excludedItems){
  for (List<String> arr in excludedItems){
      for (String item in arr){
          if (categories.contains(item)){
            return true;
          }
      }
  }
  return false;
}
bool IncludeAmount(String categories, List<List<String>> includedItems){
  for (List<String> arr in includedItems){
      for (String item in arr){
          if (categories.contains(item)){
            return true;
          }
      }
  }
  return false;
}
double calcVal(String categories, double vol, String state){
  switch(state){
    case 'California':
      if(Exclude(categories, [milks, fruit, baby])){
        return 0.00;
      }
      double amount = 0.25;
      if(IncludeAmount(categories, [wine])){
        return 0.25;
      }
      if(vol > 24){
        return 0.10;
      }
      return 0.05;
    case 'Connecticut':
      if(Exclude(categories, [fruit, baby, mineralWater])){
        return 0.00;
      }
      return 0.10;
    case 'Hawaii':
      return 0.05;
    case 'Maine':
      if(IncludeAmount(categories,[fruit,milks,water])){
        return 0.05;
      }
      if(IncludeAmount(categories,[beer, wine])){
        return 0.15;
      }
      return 0.05;
    case 'Massachusetts':
      if (vol > 135){
        return 0.0;
      }
      if(IncludeAmount(categories, [sodas])){
        return 0.05;
      }
      return 0.05;
    case 'Michigan':
      if(vol > 128){
        return 0.00;
      }
      if(IncludeAmount(categories, [sodas, wine])){
        return 0.10;
      }
      return 0.10;
    case 'Oregon':
      if(Exclude(categories, [wine, beer, altMilk, baby])){
        return 0.00;
      }
      if(IncludeAmount(categories, [sodas, water])){
        return 0.10;
      }
    case 'Vermont':
      if(IncludeAmount(categories, [wine, beer])){
        return 0.15;
      }
      return 0.05;
    case 'New York':
      return 0.05;
    default:
      return 0.00;
  }
  return 0.00;
}

double converToFL(String number, String unit){
  double? value;
  try {
    value = double.parse(number);
  } catch (e) {
    return 0.0; // Parsing failed
  }

  // Convert to fl oz
  switch (unit) {
    case 'ml':
      return value / 29.5735;
    case 'l':
      return value * 33.814; // 1 L = 33.814 fl oz
    case 'fl':
      return value;
    default:
      return 0.0; // Unknown unit
  }
}

String removeUneeded(String quantity, int found){
  quantity = quantity.substring(0,found);
  quantity = quantity.replaceAll(" ", "");
  quantity = quantity.replaceAll(",", ".");
  return quantity;
}

double calcQuantity(String quantity){
  if (quantity == "nulled"){
      return 0;
  }
  quantity = quantity.toLowerCase();
  //very dumb logic however it helps to avoid edge cases where there are 2 quanitites such as 14 fl oz (250 ml)
  //split this into 3 quanities and determine it at the very end
  int mlFound = quantity.indexOf("ml");
  int flFound = quantity.indexOf("fl");
  int literFound = quantity.indexOf("l");
  //set these up to find the least one and that will be our best quanitity 
  mlFound = mlFound == -1 ? 0x7FFFFFFFFFFFFFFF : mlFound;
  flFound = flFound == -1 ? 0x7FFFFFFFFFFFFFFF : flFound;
  literFound = literFound == -1 ? 0x7FFFFFFFFFFFFFFF:  literFound;
  if (mlFound < flFound){
    if(mlFound < literFound){
      return converToFL(removeUneeded(quantity, mlFound), 'ml');
    }
  }
  else{
    if(flFound < literFound){
      return converToFL(removeUneeded(quantity, flFound), 'fl');
    }
  }
  return converToFL(removeUneeded(quantity, literFound), 'l');
}

Future<Map<String, dynamic>> returnBottleinfo(String barcode, String state) async {
  Map<String, dynamic> returnVal = {"Error" : ""};
  OpenFoodAPIConfiguration.userAgent = UserAgent(name: 'Your app name', url: 'Your url, if applicable');
  ProductQueryConfiguration config = ProductQueryConfiguration(
    barcode,
    version: ProductQueryVersion.v3,
    language: OpenFoodFactsLanguage.ENGLISH,
  );
  ProductResultV3 product = await OpenFoodAPIClient.getProductV3(config);
  List<String> categoriesTags = product.product?.categoriesTags??[];
  bool notbev = true;
  for (String tag in categoriesTags){
    tag = tag.toLowerCase();
    if(tag.contains("beverage")){
      notbev = false;
      break;
    }
  }
  if(notbev){
    returnVal["Error"] = "not a beverage";
    return returnVal;
  }
  //brands
  String brands = product.product?.brands??"nulled";
  if(brands == "nulled"){
    print("no brands");
  }
  String name = product.product?.productName??"nulled";
  if(name == "nulled") {
    print("no name");
  }
  String quantity = product.product?.quantity??"nulled";
  if(quantity == "nulled"){
    returnVal["Error"] = "missing quantity";
    return returnVal;
  }
  quantity = quantity.toLowerCase();
  String productBrand = product.product?.quantity??"nulled";
  double doubleQuantity = calcQuantity(quantity);
  String categoriesTagsString = "";
  for (String cat in categoriesTags){
    categoriesTagsString += cat;
  }
  //String categories, double vol, String state
  returnVal = {
    'brand' : productBrand,
    'value' : calcVal(categoriesTagsString, doubleQuantity, state),
    'name' : name
  };
  return returnVal;
}



