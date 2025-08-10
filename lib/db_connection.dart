import 'package:mongo_dart/mongo_dart.dart';
import 'logger.dart';
import 'bottle.dart';

class DatabaseHandler{
  Db db;

  DatabaseHandler._({required this.db});

  static Future<DatabaseHandler> createInstance() async{
    //connection string with a dev user
    return DatabaseHandler._(db: await Db.create("mongodb+srv://dev:dev123@dev.6asiq0l.mongodb.net/development?retryWrites=true&w=majority&appName=dev"));
  }

  Future<void> openConnection() async{
    //Attempt connection to database
    try {
      await db.open();
      logger.info("Connected to MongoDB");
    } catch (e, stack) {
      //Handle error upon failed connection
      logger.severe("Error connecting to MongoDB", e, stack);
      rethrow;
    }
  }

  Future<void> closeConnection() async {
    //Attempt connection closure to database
    try {
      await db.close();
      logger.info("Closed connection");
    } catch (e, stack) {
      //Handle error upon failed closure
      logger.severe("Error closing connection to MongoDB", e, stack);
      rethrow;
    }
  }

  //Create an account given the correct parameters
  Future<void> createAccount(String user, String fullname, String password, String state, String image) async {
    DbCollection accounts = db.collection('userAccounts');
    await accounts.insertOne({"username" : user, "name" : fullname,
                              "password_hash" : password, "state" : state,
                              "pfp_url" : image, "created_at" : DateTime.now(),
                              "sessions" : [], "bottles_recycled" : 0,
                              "amount_saved" : 0.toDouble()});
  }

  //Returns whether or not user is in database
  Future<bool> userExists(String username) async {
    DbCollection accounts = db.collection('userAccounts');
    var account = await accounts.findOne({'username' : username});
    return(account != null);
  }

  //Returns whether or not user + password combination is correct
  Future<bool> passwordCorrect(String username, String password) async {
    DbCollection accounts = db.collection('userAccounts');
    var account = await accounts.findOne({'username' : username, 'password_hash' : password});
    return(account != null);
  }

  Future<ObjectId> getId(String username) async {
    DbCollection accounts = db.collection('userAccounts');
    var account = await accounts.findOne({'username' : username});
    return(account?["_id"]);
  }

  Future<String> getUsername(ObjectId id) async {
    DbCollection accounts = db.collection('userAccounts');
    var account = await accounts.findOne({'_id' : id});
    return(account?['username']);
  }

  //Returns the name of a user
  Future<String> getName(ObjectId id) async {
    DbCollection accounts = db.collection('userAccounts');
    var account = await accounts.findOne({'_id' : id});
    return(account?["name"]);
  }

  Future<String> getPassword(ObjectId id) async {
    DbCollection accounts = db.collection('userAccounts');
    var account = await accounts.findOne({'_id' : id});
    return(account?["password_hash"]);
  }

  //Returns the state of the user
  Future<String> getState(ObjectId id) async {
    DbCollection accounts = db.collection('userAccounts');
    var account = await accounts.findOne({'_id' : id});
    return(account?["state"]);
  }

  //Update the state of the user
  Future<void> updateState(ObjectId id, String state) async {
    DbCollection accounts = db.collection('userAccounts');
    accounts.updateOne(where.eq('_id', id), modify.set('state', state));
  }

  //Returns the amount the user saved
  Future<double> getAmountSaved(ObjectId id) async {
    DbCollection accounts = db.collection('userAccounts');
    var account = await accounts.findOne({'_id' : id});
    return(account?["amount_saved"]);
  }

  //uploads the bottles to the bottle table
  Future<void> uploadBottles(List<Bottle> sessionBottles) async {
    DbCollection bottles = db.collection("bottles");
    List< Map<String, dynamic>> insertion = [];

    //Convert bottle objects into an insertable format
    for(Bottle bottle in sessionBottles) {
      insertion.add(bottle.toJson());
    }
    await bottles.insertMany(insertion);
  }

  //updates the brand's bottle count for a specific user
  Future<void> updateStats(ObjectId id, List<Bottle> sessionBottles) async {
    DbCollection userStats = db.collection('personalStats');

    //increment the brand count each time a brand has a new bottle
    for (Bottle bottle in sessionBottles) {
      String brand = bottle.getBrand();
      userStats.updateOne(where.eq('_id',id), modify.inc("brand_map.$brand", 1));
    }
  }

  //create session of bottle recycling
  Future<void> createSession(List<Bottle> sessionBottles, DateTime timestamp) async {
    DbCollection sessions = db.collection('sessions');
    DbCollection bottles = db.collection('bottles');
    List<ObjectId> bottleIds = [];

    //add each bottle created at session creation to list
    await bottles.find(where.eq('created_at', timestamp)).forEach(
            (v) => bottleIds.add(v['_id']));
    sessions.insertOne({'created_at' : timestamp, 'bottles' : bottleIds});
  }

  Future<void> updateUserProfile(ObjectId id, String username, String password, String fullname) async {
    DbCollection accounts = db.collection('userAccounts');

     accounts.updateOne(where.eq('_id', id),
        ModifierBuilder()
          .set('username', username)
          .set('password', password)
          .set('fullname', fullname)
    );
  }
  //update the sessions, value, and bottles_recycled field to include new sessions data
  Future<void> updateUserSessions(ObjectId id, List<Bottle> sessionBottles, DateTime timestamp) async {
    DbCollection accounts = db.collection('userAccounts');
    DbCollection sessions = db.collection('sessions');

    //get the account and session
    var account = await accounts.findOne({'_id' : id});
    var session = await sessions.findOne({'created_at' : timestamp});

    //calculate the new value
    double sum = account?["amount_saved"];
    for(Bottle bottle in sessionBottles) {
      sum += bottle.getValue();
    }

    //update the account with the new session, updated value, and bottle count
    accounts.updateOne(where.eq('_id', id),
        ModifierBuilder()
            .push('sessions', session?['_id'])
            .set('amount_saved', sum)
            .set('bottles_recycled', sessionBottles.length)
    );
  }
}