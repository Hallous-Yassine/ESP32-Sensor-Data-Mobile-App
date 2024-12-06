import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'radial_gauge_widget.dart';
import 'line_Chart_Sample2.dart';
import 'profile_page.dart';
import 'History_temperature_page.dart';

class TemperaturePage extends StatefulWidget {
  final String ipAddress;

  TemperaturePage({required this.ipAddress});

  @override
  _TemperaturePageState createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {
  String _temperature = 'Fetching...';
  double? _maxTemperature;
  double? _minTemperature;
  double? _averageTemperature;
  Timer? _fetchTimer;
  int _currentIndex = 0; // To track the current page
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _fetchTemperature();
    _fetchTimer = Timer.periodic(Duration(seconds: 10), (timer) => _fetchTemperature());
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchTemperature() async {
    final url = 'http://${widget.ipAddress}/api/read_temperature.php?type=current_temperature'; // Replace with your PHP script URL
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data != null && data.isNotEmpty) {
          final temperature = double.tryParse(data['current_temperature'].toString());
          final maxTemp = double.tryParse(data['max_temperature'].toString());
          final minTemp = double.tryParse(data['min_temperature'].toString());
          final avgTemp = double.tryParse(data['average_temperature'].toString());

          if (temperature != null) {
            setState(() {
              _temperature = '${temperature.toStringAsFixed(2)}°C';
              _maxTemperature = maxTemp;
              _minTemperature = minTemp;
              _averageTemperature = avgTemp;
            });
          } else {
            setState(() {
              _temperature = 'Error parsing data';
            });
          }
        }
      } else {
        setState(() {
          _temperature = 'No temperature data';
        });
      }
    } catch (e) {
      setState(() {
        _temperature = 'Error fetching data';
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
            'Temperature Dashboard',
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
          // Page 1: Temperature Gauge and Card
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF34e89e), Color(0xFF0f3443)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView( // Wrap the content in a SingleChildScrollView
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Column(
                  children: <Widget>[
                    // Radial Gauge Widget at the top
                    Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: RadialGaugeWidget(
                        currentTemperature: double.tryParse(_temperature.replaceAll('°C', '')) ?? 0,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Card for Temperature Statistics
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
                              'Current Temperature: \n$_temperature',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 12),
                            if (_maxTemperature != null)
                              Text(
                                'Max Temperature: \n${_maxTemperature!.toStringAsFixed(2)}°C',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                            if (_minTemperature != null)
                              Text(
                                'Min Temperature: \n${_minTemperature!.toStringAsFixed(2)}°C',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                            if (_averageTemperature != null)
                              Text(
                                'Average Temperature: \n${_averageTemperature!.toStringAsFixed(2)}°C',
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

          // Page 2: Line Chart (Placeholder)
          Container(
            child: Container(
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
                  child: LineChartSample2(
                    Pc_Ip_Address: widget.ipAddress,
                  ),
                ),
              ),
            ),
          ),

          // Page 3: History of Values (Placeholder)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF34e89e), Color(0xFF0f3443)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Container(
              child: HistoryTemperaturePage(
                Pc_Ip_Address: widget.ipAddress,
              ),
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
        selectedItemColor: Colors.cyan, // Color for the selected item
        unselectedItemColor: Colors.white,     // Color for unselected items
        backgroundColor: Color(0xFF0f3443),
      ),
    );
  }
}
