import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recycletracker/db_connection.dart';
import '../models/scan_session.dart';
import 'camera_page.dart';
import 'profile_page.dart';
import 'history_detail_page.dart';

class HomePage extends StatefulWidget {
  final mongo.ObjectId id;
  const HomePage({super.key, required this.id});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ScanSession> sessions = [];

  // Database handler
  late DatabaseHandler db;

  // Load database and relevant information before page
  late Future<void> _dbFuture;

  double totalSaved = 0.0;

  // Initialize database connection asynchronously
  Future<void> _initDb(mongo.ObjectId id) async {
    db = await DatabaseHandler.createInstance();
    await db.openConnection();
    totalSaved = await db.getAmountSaved(id);
    List<Map<String, dynamic>> sessionsMap = await db.retrieveSessions(id);
    sessions = sessionsMap.map((doc) => ScanSession.fromMongo(doc)).toList();
  }

  @override
  void initState() {
    super.initState();
    _dbFuture = _initDb(widget.id);
  }

  Future<void> _loadSessions(mongo.ObjectId id) async {

  }

  Future<void> _goToCamera(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CameraPage(id: widget.id)),
    );
  }

  String _formatDateTime(DateTime dt) {
    final two = (int n) => n.toString().padLeft(2, '0');
    final mm = two(dt.month);
    final dd = two(dt.day);
    final yy = two(dt.year % 100);
    final hour12 = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = two(dt.minute);
    return "$mm/$dd/$yy  $hour12:$min $ampm";
  }

  // Placeholder pie chart data
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

  //Ensure database is loaded before the page is
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _dbFuture,
        builder: (context, snapshot) {
          //If not connected show loading screen
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
          //Load in actual page
          return _buildHomePage(context);
        }
    );
  }

  Widget _buildHomePage(BuildContext context) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Top Banner
                  Container(
                    color: const Color(0xFFD5EFCD),
                    padding: EdgeInsets.only(
                        top: MediaQuery
                            .of(context)
                            .padding
                            .top + 20, bottom: 15),
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
                    child: Column(
                      children: [
                        const Text('Total Saved:',
                            style:
                            TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(
                          //circular issue with id
                          '\$${totalSaved.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(56, 118, 29, 1.0)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Pie Chart with Legend
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
                        const Text('Bottles Recycled:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
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
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("History",
                            style:
                            TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),

                        if (sessions.isEmpty)
                          const Text("No sessions yet."),
                        ...sessions.map((s) {
                          return ListTile(
                            title: Text(
                                "Session on ${_formatDateTime(s.dateTime)}"),
                            trailing:
                            const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HistoryDetailPage(session: s),
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
              padding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfilePage(id: widget.id)),
                      );
                    },
                    child: const CircleAvatar(
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
                    onPressed: () => _goToCamera(context),
                  ),
                ],
              ),
            ),
          );
  }
}
