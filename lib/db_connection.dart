import 'package:mongo_dart/mongo_dart.dart';
import 'logger.dart';

//Connection string for all future connections
class DatabaseHandler{
  Db db;

  DatabaseHandler._({required this.db});

  static Future<DatabaseHandler> createInstance() async{
    return DatabaseHandler._(db: await Db.create("mongodb+srv://dev:dev123@dev.6asiq0l.mongodb.net/development?retryWrites=true&w=majority&appName=dev"));
  }

  Future<void> openConnection() async{
    try {
      await db.open();
      logger.info("Connected to MongoDB");
    } catch (e, stack) {
      logger.severe("Error connecting to MongoDB", e, stack);
      rethrow;
    }
  }

  Future<void> closeConnection() async {
    try {
      await db.close();
      logger.info("Closed connection");
    } catch (e, stack) {
      logger.severe("Error closing connection to MongoDB", e, stack);
      rethrow;
    }
  }
  Future<void> createAccount(String user, String fullname, String password, String state, String image) async {
    DbCollection accounts = db.collection('userAccounts');
    await accounts.insertOne({"username" : user, "name" : fullname,
                              "password_hash" : password, "state" : state,
                              "pfp_url" : image, "created_at" : DateTime.now(),
                              "sessions" : [], "bottles_recycled" : 0,
                              "amount_saved" : 0});
  }
}