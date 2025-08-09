import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recycletracker/pages/home.dart';
import 'package:recycletracker/db_connection.dart';
import 'package:provider/provider.dart';
import 'interPageComms.dart';
import 'package:recycletracker/pages/login_page.dart';

// CreateAccountPage is the screen where user creates a new account
class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}
String _checkUsername = '';
class _CreateAccountPageState extends State<CreateAccountPage> {
	// Variables to store user input values, with type suffix for clarity
  String username = "";
  String fullname = "";
  String password = "";
  String imageurl = "";
  var state;
  var id;

	// For storing picked profile image file
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  // Database handler
  late DatabaseHandler db;

	// Initialize database connection asynchronously
  Future<void> _initDb() async {
    db = await DatabaseHandler.createInstance();
    await db.openConnection();
    await Future.delayed(Duration(seconds: 3)); // manual pause
  }

	// Called once when widget is created to initialize the database handler
  @override
  void initState() {
    super.initState();
    _initDb();
  }

	// Function to pick an image from gallery and update UI
  Future<void> _pickImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

	// Build method creates the UI for this screen
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      //waiting for database initialization method to be ran
        future: _initDb(),
        builder: (context, snapshot) {
          if(snapshot.connectionState != ConnectionState.done) {
            //display loading screen if not loaded in yet
            return const Center(child: CircularProgressIndicator());
          }
          //now build login page after connection completed
          return _buildCreateAccountPage(context);
        }
    );
  }

  Widget _buildCreateAccountPage(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Banner with logo
            Container(
              color: const Color(0xFFD5EFCD),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                bottom: 15,
              ),
              child: Center(
                child: Image.asset(
                  'assets/logo.png',
                  height: 80,
                ),
              ),
            ),
            const SizedBox(height: 20),

						// Form inputs with horizontal padding
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Create Account",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 25),

                  // Username input field
                  const Text("Username:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  TextField(
                    onChanged: (text){
                      username = text;
                    },
                    decoration: const InputDecoration(
                      hintText: "enter username",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Password input field
                  const Text("Password:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  TextField(
                    onChanged: (text){
                      password = text;
                      _checkUsername = text;
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "enter password",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Name input field
                  const Text("Name:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  TextField(
                    onChanged: (text) {
                      fullname = text;
                    },
                    decoration: InputDecoration(
                      hintText: "e.g. Johnny Doe",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // State dropdown menu
                  const Text("State:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  DropdownButtonFormField<String>(
                    items: [
                      "California",
                      "Connecticut",
                      "Hawaii",
                      "Iowa",
                      "Maine",
                      "Massachusetts",
                      "Michigan",
                      "New York",
                      "Oregon",
                      "Vermont",
                      "Guam"
                    ].map((state) {
                      return DropdownMenuItem(
                        value: state,
                        child: Text(state),
                      );
                    }).toList(),
                    onChanged: (value) {
                      state = value;
                    },
                    decoration: const InputDecoration(
                      hintText: "Select State",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Create Account Button
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF609966),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                      ),
                      // When pressed, validate inputs and create account if valid
                      onPressed: () async {
                        // Check if any field is empty
                        if (username == null || username.trim().isEmpty ||
                            password == null || password.trim().isEmpty ||
                            fullname == null || fullname.trim().isEmpty ||
                            state == null || state.toString().trim().isEmpty) {
                          // Show error message if validation fails
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please fill out all required fields"),
                              duration: Duration(milliseconds: 1500),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        bool exists = await db.userExists(username);
                        if(exists) {
                          // TODO: front end add logic for if the username already used
                        } else {
                          // Add account to database
                          await db.createAccount(username, fullname, password, state, "temp");
                          //send id to other pages
                          id = await db.getId(username);
                          db.closeConnection();
                          context.read<UserData>().setId(id);
                          // Navigate to Home page replacing current page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(id: id),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Create Account",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Button to switch to Login page if user already has account
                  Center(child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: const Text("Already have an account? Login."),
                  ),                  
                ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

