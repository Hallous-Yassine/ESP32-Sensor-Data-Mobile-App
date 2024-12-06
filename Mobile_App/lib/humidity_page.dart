import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'circular_progress_bar.dart';
import 'line_chart_sample.dart';
import 'profile_page.dart';
import 'history_humidity_page.dart'; // Ensure you have this page

class HumidityPage extends StatefulWidget {
  final String ipAddress;

  HumidityPage({required this.ipAddress});

  @override
  _HumidityPageState createState() => _HumidityPageState();
}

class _HumidityPageState extends State<HumidityPage> {
  String _humidity = 'Fetching...';
  double? _maxHumidity;
  double? _minHumidity;
  double? _averageHumidity;
  Timer? _fetchTimer;
  int _currentIndex = 0;
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _fetchHumidity();
    _fetchTimer = Timer.periodic(Duration(seconds: 10), (timer) => _fetchHumidity());
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchHumidity() async {
    final url = 'http://${widget.ipAddress}/api/read_humidity.php?type=current_humidity';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.containsKey('current_humidity')) {
          final humidity = double.tryParse(data['current_humidity'].toString());
          final maxHumidity = double.tryParse(data['max_humidity'].toString());
          final minHumidity = double.tryParse(data['min_humidity'].toString());
          final averageHumidity = double.tryParse(data['average_humidity'].toString());

          setState(() {
            _humidity = humidity != null ? '${humidity.toStringAsFixed(2)}%' : 'Error parsing data';
            _maxHumidity = maxHumidity;
            _minHumidity = minHumidity;
            _averageHumidity = averageHumidity;
          });
        } else {
          setState(() {
            _humidity = 'No humidity data';
          });
        }
      } else {
        setState(() {
          _humidity = 'Error fetching data';
        });
      }
    } catch (e) {
      setState(() {
        _humidity = 'Error fetching data';
      });
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Humidity Dashboard',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Color(0xFF34e89e),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          // Dashboard Page
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF34e89e), Color(0xFF0f3443)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Column(
                  children: <Widget>[
                    // Radial Gauge Widget at the top
                    Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: CircularProgressBar(
                        currenthumidity: double.tryParse(_humidity.replaceAll('%', '')) ?? 0,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Card for Humidity Statistics
                    Card(
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 8,
                      color: Colors.indigo[100],
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Humidity: \n$_humidity',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 12),
                            if (_maxHumidity != null)
                              Text(
                                'Max Humidity: \n${_maxHumidity!.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                            if (_minHumidity != null)
                              Text(
                                'Min Humidity: \n${_minHumidity!.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                            if (_averageHumidity != null)
                              Text(
                                'Average Humidity: \n${_averageHumidity!.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Line Chart Page
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF34e89e), Color(0xFF0f3443)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: LineChartSample(
                  Pc_Ip_Address: widget.ipAddress,
                ),
              ),
            ),
          ),
          // History Page
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF34e89e), Color(0xFF0f3443)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: HistoryHumidityPage(
              Pc_Ip_Address: widget.ipAddress,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Chart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
        selectedItemColor: Colors.cyan,
        unselectedItemColor: Colors.white,
        backgroundColor: Color(0xFF0f3443),
      ),
    );
  }
}
