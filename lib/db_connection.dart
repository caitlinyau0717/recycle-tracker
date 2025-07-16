import 'package:mongo_dart/mongo_dart.dart';
import 'logger.dart';

Future<Db> connectToMongoDB() async {
  // 1. Create connection string with your database name
  const connectionString =
      'INSERT_CONNECTION_STRING_HERE';

  // 2. Create DB instance

  Db db = await Db.create(connectionString);

  try {
    // 3. Open connection
    await db.open();
    logger.info("Connected to MongoDB");

    // 4. Verify connection by listing collections (better than ping)
    final collections = await db.getCollectionNames();
    logger.info("Available collections: $collections");

    return db;
  } catch (e, stack) {
    logger.severe("Error connecting to MongoDB", e, stack);
    await db.close();
    rethrow;
  }
}

Future<void> closeMongoDBConnection(Db db) async {
  try {
    await db.close();
    logger.info("MongoDB connection closed");
  } catch (e) {
    logger.severe("Error closing MongoDB connection", e);
  }
}
