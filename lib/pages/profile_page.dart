import 'package:flutter/material.dart';
import 'edit_profile_page.dart';
import 'camera_page.dart';
import 'home.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notificationsEnabled = true;
  bool _showAchievementDetail = false;
  String _selectedState = "New York"; // default state

  final List<String> states = [
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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: const Color(0xFFD5EFCD),
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                    (route) => false,
                  );
                },
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back_ios, color: Colors.black54, size: 16),
                    Text('home', style: TextStyle(color: Colors.black54, fontSize: 16)),
                  ],
                ),
              ),
              const Spacer(),
              const Text('Your Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              const Spacer(),
              const SizedBox(width: 60),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile photo + name
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/ProfilePic.png'),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Johnny Doe',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EditProfilePage()),
                        );
                      },
                      style: TextButton.styleFrom(
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
            const SizedBox(height: 30),

            _buildSection(
              title: 'Achievements',
              child: _showAchievementDetail ? _buildAchievementDetail() : _buildAchievementGrid(),
            ),
            const SizedBox(height: 25),

            _buildSection(
              title: 'Notifications',
              showBorder: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Enable Notifications', style: TextStyle(fontSize: 16.0)),
                  Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() => _notificationsEnabled = value);
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
              child: DropdownButtonFormField<String>(
                value: _selectedState,
                items: states.map((state) {
                  return DropdownMenuItem<String>(
                    value: state,
                    child: Text(state),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedState = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Select Your State',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
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
                  MaterialPageRoute(builder: (context) => HomePage()),
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

  Widget _buildSection({required String title, required Widget child, bool showBorder = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: showBorder ? const EdgeInsets.all(16) : EdgeInsets.zero,
          decoration: showBorder
              ? BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          child: child,
        ),
      ],
    );
  }

  Widget _buildAchievementGrid() {
    return SizedBox(
      height: 150,
      child: Wrap(
        spacing: 16.0,
        runSpacing: 16.0,
        children: [
          GestureDetector(
            onTap: () => setState(() => _showAchievementDetail = true),
            child: const Icon(Icons.favorite, size: 50, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementDetail() {
    return SizedBox(
      height: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _showAchievementDetail = false),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_ios, size: 12),
                Text('back'),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.favorite, size: 40, color: Colors.red),
                  SizedBox(height: 4),
                  Text('Lifesaver', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('recycled over 50 bottles', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
