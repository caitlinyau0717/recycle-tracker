import 'package:mongo_dart/mongo_dart.dart';
import 'logger.dart';

//Connection string for all future connections
const DATABASE_STRING = String.fromEnvironment("DATABASE_STRING", defaultValue: "");

Future<Db> connectToMongoDB() async {
  // 2. Create DB instance

  Db db = await Db.create(DATABASE_STRING);

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

Future<void> createAccount(String user, String fullname, String pw, String state, String image) async {
  //connect to database
  Db db = await Db.create(DATABASE_STRING);
  try {
    await db.open();

    try {
      //connect to staging collection
      DbCollection collection = db.collection('userAccounts');

      //insert user pw and image string into database
      await collection.insertOne({"username" : user, "name" : fullname, "password_hash" : pw, "state" : state, "pfp_url" : image, "created_at" : DateTime.now(), "sessions" : [], "bottles_recycled" : 0, "amount_saved" : 0});

      closeMongoDBConnection(db);
    } catch (e, stack) {
      logger.severe("Error creating account", e, stack);
      closeMongoDBConnection(db);
    }

  } catch (e, stack) {
    logger.severe("Error connecting to MongoDB", e, stack);
    closeMongoDBConnection(db);
    rethrow;
  }
}