import 'dart:convert';

class ScanItem {
  final String barcode;
  final String deposit; // store as string like "0.05" to match your UI

  ScanItem({required this.barcode, required this.deposit});

  Map<String, dynamic> toJson() => {"barcode": barcode, "deposit": deposit};
  factory ScanItem.fromJson(Map<String, dynamic> j) =>
      ScanItem(barcode: j["barcode"], deposit: j["deposit"]);
}

class ScanSession {
  final DateTime dateTime;
  final List<ScanItem> items;
  final double total; // precomputed total so list is fast
  final List<String>? imagePaths; // optional: store paths if you want thumbnails later

  ScanSession({
    required this.dateTime,
    required this.items,
    required this.total,
    this.imagePaths,
  });

  Map<String, dynamic> toJson() => {
        "dateTime": dateTime.toIso8601String(),
        "items": items.map((e) => e.toJson()).toList(),
        "total": total,
        "imagePaths": imagePaths,
      };

  factory ScanSession.fromJson(Map<String, dynamic> j) => ScanSession(
        dateTime: DateTime.parse(j["dateTime"]),
        items: (j["items"] as List).map((e) => ScanItem.fromJson(e)).toList(),
        total: (j["total"] as num).toDouble(),
        imagePaths: (j["imagePaths"] as List?)?.map((e) => e.toString()).toList(),
      );

  static String encodeList(List<ScanSession> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<ScanSession> decodeList(String raw) =>
      (jsonDecode(raw) as List).map((e) => ScanSession.fromJson(e)).toList();

  factory ScanSession.fromMongo(Map<String, dynamic> doc) {
    return ScanSession(
      dateTime: DateTime.parse(doc['date_time'] as String),
      items: (doc['items'] as List).map((item) {
        return ScanItem(
          barcode: item['barcode'] as String,
          deposit: item['deposit'] as String,
        );
      }).toList(),
      total: (doc['total'] as num).toDouble(),
      imagePaths: List<String>.from(doc['image_paths'] ?? []),
    );
  }

}
