import 'package:flutter/material.dart';
import 'package:recycletracker/db_connection.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class EditProfilePage extends StatefulWidget {
  final mongo.ObjectId id;

  const EditProfilePage({super.key, required this.id});
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}
class _EditProfilePageState extends State<EditProfilePage> {
  String _ogUser = "";
  String _username = "";
  String _name = "";
  String _password = "";

  // DatabaseHandler instance for managing database actions
  late DatabaseHandler db;

  // Load database before page
  late Future<void> _dbFuture;

  // This function initializes the database connection
  Future<void> _initDb(mongo.ObjectId id) async {
    db = await DatabaseHandler.createInstance();
    await db.openConnection();

    _username = await db.getUsername(id);
    _ogUser = _username;
    _name = await db.getName(id);
    _password = await db.getPassword(id);
  }

  // Called when the widget is first inserted into the widget tree
  @override
  void initState() {
    super.initState();
    _dbFuture = _initDb(widget.id); // Initialize database connection on page load
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _dbFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator())
            );
          }
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          }
          return _buildEditProfilePage(context);
        }
    );
  }

  Widget _buildEditProfilePage(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
       appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: const Color(0xFFD5EFCD),
          elevation: 0,
          automaticallyImplyLeading: false, // Remove default back arrow
          title: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back_ios, color: Colors.black54, size: 16),
                    Text('back', style: TextStyle(color: Colors.black54, fontSize: 16)),
                  ],
                ),
              ),
              const Spacer(),
              const Text('Edit Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              const Spacer(),
              const SizedBox(width: 60),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Photo Section
            const SizedBox(height: 10),
            const CircleAvatar(
              radius: 50,
              // CHRIS: PROFILE PIC GOES HERE
              backgroundImage: AssetImage('assets/ProfilePic.png'),
            ),
            TextButton(
              // CHRIS: IM ASSUMING CODE TO CHANGE PROFILE PIC HAS TO DO WITH THE DATABASE
              onPressed: () { /* CODE TO CHANGE PROFILE PIC WILL GO HERE */ },
              child: const Text('select to change'),
            ),
            const SizedBox(height: 20),
            

            // Form Fields
            Text('Username', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            //Username
            TextFormField(
              initialValue: _username,
              obscureText: false,
              onChanged: (text){
                _username = text;
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            //Password
            TextFormField(
              initialValue: _password,
              obscureText: true,
              onChanged: (text){
                _password = text;
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _name,
              obscureText: false,
              onChanged: (text){
                _name = text;
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 40),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  bool exists = await db.userExists(_username);
                  if(_username != _ogUser && exists){
                    // TODO: front end add logic for if the username already used
                  } else {
                    await db.updateUserProfile(widget.id, _username, _password, _name);
                  }

                  Navigator.pop(context); // Go back to profile page
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF96B491),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Submit Changes',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required String initialValue, bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          obscureText: obscureText,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}