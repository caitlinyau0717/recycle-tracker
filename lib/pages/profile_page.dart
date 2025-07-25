import 'package:flutter/material.dart';
import 'edit_profile_page.dart';
import 'camera_page.dart';
import 'home.dart'; // Corrected from 'home.dart'

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // I've re-added the state variables from the previous version
  bool _notificationsEnabled = true;
  bool _showAchievementDetail = false;

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
                    // Corrected text to match mockup
                    Text('home', style: TextStyle(color: Colors.black54, fontSize: 16)),
                  ],
                ),
              ),
              const Spacer(),
              const Text('Your Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              const Spacer(),
              const SizedBox(width: 60), // To balance the title
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0), // Adjusted padding for consistency
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // This is the main section for the profile header
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // profile icon
                const CircleAvatar(
                  radius: 60, // Adjusted radius to better match mockup
                  backgroundImage: AssetImage('assets/ProfilePic.png'),
                ),
                const SizedBox(width: 20),

                // column for name and edit button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Johnny Doe',
                      style: TextStyle(
                        fontSize: 28, // Adjusted font size to match mockup
                        fontWeight: FontWeight.bold,
                        height: 1.2, // Reduces the space below the text
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EditProfilePage()),
                        );
                      },
                      style: TextButton.styleFrom(
                        // This is the key property to make the button tighter
                        visualDensity: const VisualDensity(vertical: -4),
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.centerLeft,
                      ),
                      child: const Text('edit profile', style: TextStyle(color: Colors.blue, fontSize: 16.0)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30), // Increased space before the next section
            
            // achievements
            _buildSection(
              title: 'Achievements',
              child: _showAchievementDetail
                  ? _buildAchievementDetail()
                  : _buildAchievementGrid(),
            ),
            const SizedBox(height: 25),

            // notifications
            _buildSection(
              title: 'Notifications',
              showBorder: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Enable Notifications', style: TextStyle(fontSize: 16.0),),
                  Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildSection(
              title: 'State',
              showBorder: false,
              child: Row(
                children: [
                  Image.asset('assets/NYState.png', width: 160, height: 160),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('New York', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26.0)),
                      Text('change state', style: TextStyle(color: Colors.blue, fontSize: 16.0)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFFD5EFCD),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage('assets/ProfilePic.png'),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Image.asset('assets/logo.png', height: 40),
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt_rounded, size: 40),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CameraPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for building sections (re-added from previous version)
  Widget _buildSection({required String title, required Widget child, bool showBorder = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          // add padding only if there's a border
          padding: showBorder ? const EdgeInsets.all(16) : EdgeInsets.zero,
          decoration: showBorder
              ? BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                )
              : null, // No decoration if showBorder is false
          child: child,
        ),
      ],
    );
  }

  Widget _buildAchievementGrid() {
    return SizedBox(
      height: 150, // sets the fixed height for the content inside the box.
      child: Wrap(
        spacing: 16.0, // Horizontal space between icons.
        runSpacing: 16.0, // Vertical space if icons wrap to the next line.
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _showAchievementDetail = true;
              });
            },
            child: const Icon(Icons.favorite, size: 50, color: Colors.red),
          ),
          // CAN ADD MORE ACHIEVEMENTS HERE
        ],
      ),
    );
  }

  Widget _buildAchievementDetail() {
    // It now has the same fixed height to prevent the box from resizing.
    return SizedBox(
      height: 150, // Same height as the grid view.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _showAchievementDetail = false;
              });
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min, // Keep the back button compact
              children: [
                Icon(Icons.arrow_back_ios, size: 12),
                Text('back'),
              ],
            ),
          ),
          // Expanded and Center are used to center the detail content vertically.
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite, size: 40, color: Colors.red),
                  const SizedBox(height: 4),
                  const Text('Lifesaver', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Text('recycled over 50 bottles', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
