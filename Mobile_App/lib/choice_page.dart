import 'package:flutter/material.dart';
import 'temperature_page.dart'; // Import the TemperaturePage class
import 'humidity_page.dart'; // Import the HumidityPage class
import 'profile_page.dart'; // Import the ProfilePage class

class ChoicePage extends StatelessWidget {
  final String ipAddress;

  ChoicePage({required this.ipAddress});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Select Data Type',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 24,
              color: Colors.black,
            ),
          ),
        ),
        backgroundColor: Color(0xFF34e89e),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF34e89e),
              Color(0xFF0f3443),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _EnhancedButtonWidget(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TemperaturePage(ipAddress: ipAddress),
                    ),
                  );
                },
                text: 'Temperature',
                icon: Icons.thermostat_outlined,
              ),
              SizedBox(height: 20),
              _EnhancedButtonWidget(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HumidityPage(ipAddress: ipAddress),
                    ),
                  );
                },
                text: 'Humidity',
                icon: Icons.water_drop_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Enhanced button widget with improved styling
class _EnhancedButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;

  _EnhancedButtonWidget({required this.onPressed, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        backgroundColor: Colors.teal[400],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        shadowColor: Colors.black45,
        elevation: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28),
          SizedBox(width: 15),
          Text(
            text,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
