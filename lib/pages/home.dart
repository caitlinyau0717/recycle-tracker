import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'camera_page.dart';
import 'profile_page.dart';
import 'history_detail_page.dart'; // <-- create this file

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // Pie chart data
  final List<PieChartSectionData> pieChartSections = [
    PieChartSectionData(
      value: 60,
      color: const Color.fromARGB(255, 126, 207, 245),
      title: '60.0%',
      radius: 80,
    ),
    PieChartSectionData(
      value: 25,
      color: const Color.fromARGB(255, 240, 131, 123),
      title: '25.0%',
      radius: 80,
    ),
    PieChartSectionData(
      value: 15,
      color: const Color.fromARGB(255, 133, 239, 137),
      title: '15.0%',
      radius: 80,
    ),
  ];

  final List<Map<String, dynamic>> legendItems = [
    {'name': 'Poland Spring', 'color': Color.fromARGB(255, 126, 207, 245)},
    {'name': 'Coca-Cola Bottle', 'color': Color.fromARGB(255, 240, 131, 123)},
    {'name': 'Sprite Can', 'color': Color.fromARGB(255, 133, 239, 137)},
  ];

  final List<String> fakeSessionDates = [
    "08/08/25",
    "08/07/25",
    "08/06/25",
    "08/05/25",
    "08/04/25",
  ];

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
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, bottom: 15),
              child: Center(
                child: Image.asset(
                  'assets/logo.png',
                  height: 80,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Total Saved
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                children: [
                  Text('Total Saved:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('\$102.95', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color.fromRGBO(56, 118, 29, 1.0))),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Pie Chart with Legend - Bottles Recycled
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  const Text('Bottles Recycled:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 200,
                        width: 198,
                        child: PieChart(
                          PieChartData(
                            sections: pieChartSections,
                            sectionsSpace: 2,
                            centerSpaceRadius: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: legendItems.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    color: item['color'],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    item['name'],
                                    style: const TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // History Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ...fakeSessionDates.map((date) {
                    return ListTile(
                      title: Text("Session on $date"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HistoryDetailPage(sessionDate: date),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      // Bottom Footer
      bottomNavigationBar: Container(
        color: const Color(0xFFD5EFCD),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              child: CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage('assets/ProfilePic.png'),
              ),
            ),
            Image.asset(
              'assets/logo.png',
              height: 40,
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
}
