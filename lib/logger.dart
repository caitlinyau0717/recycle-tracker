import 'package:logging/logging.dart';

final Logger logger = Logger('MongoLogger');

void setupLogging() {
  Logger.root.level = Level.ALL; // You can change this level for production
  Logger.root.onRecord.listen((record) {
    print(
      '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}',
    );
  });
}
