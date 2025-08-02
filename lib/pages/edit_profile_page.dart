import 'package:flutter/material.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
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
            
            // CHRIS: USERNAME, PASSWORD, AND NAME GO HERE | USERS CAN CHANGE THEIR INFO HERE
            // Form Fields
            _buildTextField(label: 'Username', initialValue: 'johnnydoe15'),
            const SizedBox(height: 16),
            _buildTextField(label: 'Password', initialValue: 'password', obscureText: true),
            const SizedBox(height: 16),
            _buildTextField(label: 'Name', initialValue: 'Johnny Doe'),
            const SizedBox(height: 40),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // CHRIS: DATABASE INFORMATION SHOULD UPDATE TO INFORMATION ON CLICK HERE
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