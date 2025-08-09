import 'package:flutter/material.dart';
import 'package:recycletracker/pages/create_account.dart';
import 'package:recycletracker/pages/home.dart';
import 'package:recycletracker/db_connection.dart';

// This class represents the Login Page screen
// It is a StatefulWidget because it will hold state for user input and validation
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// The state class holds the mutable data for LoginPage
class _LoginPageState extends State<LoginPage> {
  String username = '';
  String password = '';

	// DatabaseHandler instance for managing database actions
  late DatabaseHandler db;

	// This function initializes the database connection
  Future<void> _initDb() async {
    db = await DatabaseHandler.createInstance();
    await db.openConnection();
  }

	// Called when the widget is first inserted into the widget tree
  @override
  void initState() {
    super.initState();
    _initDb(); // Initialize database connection on page load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Banner with app logo
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

            // Main form area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Title
                  const Text("Log In",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 25),

                  // Username field
                  const Text("Username:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  TextField(
                    onChanged: (text) {
                      username = text; // Store username input
                    },
                    decoration: const InputDecoration(
                      hintText: "enter username",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Password field
                  const Text("Password:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  TextField(
                    onChanged: (text) {
                      password = text; // Store password input
                    },
                    obscureText: true, // Hide characters in password for security
                    decoration: const InputDecoration(
                      hintText: "enter password",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Buttons
                  Center(
                    child: Column(
                      children: [
                        // Log in button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF609966),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                          ),
                          onPressed: () async {
                            // Check if the username exists in the database
                            bool exists = await db.userExists(username);
                            if (exists) {
                              // Verify that the provided password is correct
                              bool authenticated = await db.passwordCorrect(username, password);
                              if (authenticated) {
                                // Navigate to HomePage if login is successful
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => HomePage()),
                                );
                              } else {
                                // Show error if password is incorrect
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Invalid username/password"),
                                    duration: Duration(milliseconds: 1500),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            } else {
                              // Show error if username is not found
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Invalid username/password"),
                                  duration: Duration(milliseconds: 1500),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          child: const Text(
                            "Log In",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 15),
                        
												// Create Account navigation button
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const CreateAccountPage()),
                            );
                          },
                          child: const Text("Create Account"),
                        ),
                      ],
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
