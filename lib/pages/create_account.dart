import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recycletracker/pages/home.dart';
import 'package:recycletracker/db_connection.dart';
import 'package:provider/provider.dart';
import 'interPageComms.dart';
class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}
String _checkUsername = '';
class _CreateAccountPageState extends State<CreateAccountPage> {
  var username;
  var fullname;
  var password;
  var imageurl;
  var state;

  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  //Database handler
  late DatabaseHandler db;
  Future<void> _initDb() async {
    db = await DatabaseHandler.createInstance();
    await db.openConnection();
  }

  //Initialize database handler on load of page
  @override
  void initState() {
    super.initState();
    _initDb();
  }


  Future<void> _pickImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Banner
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

            // Form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Create Account",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 25),

                  const Text("Username:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  TextField(
                    onChanged: (text){
                      username = text;
                      context.read<UserData>().setUsername(text);
                    },
                    decoration: const InputDecoration(
                      hintText: "enter username",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 15),

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

                  // Chris: Upload photo, pfp for users
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade300,
                            image: _profileImage != null
                                ? DecorationImage(
                                    image: FileImage(_profileImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _profileImage == null
                              ? const Center(
                                  child: Text("upload\nphoto",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 12)),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Text("(optional)"),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Create Account Button
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF609966),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                      ),
                      onPressed: () async {
                        //add account to database
                        await db.createAccount(username, fullname, password, state, "temp");
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Create Account",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

