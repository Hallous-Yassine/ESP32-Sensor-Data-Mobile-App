import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this import for URL launching

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF212121), // Grey background color
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Top Row with Back Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  color: Color(0xFFFFC107),
                  iconSize: 30,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),

            // Profile Image
            Center(
              child: CircleAvatar(
                radius: 70,
                backgroundImage: AssetImage('assets/yassine.png'),
              ),
            ),
            SizedBox(height: 20),

            // Profile Information Cards
            _buildInfoCard('Name: Yassine Hallous'),
            SizedBox(height: 10),
            _buildInfoCard('Email: yassine_hallous@ieee.org'),
            SizedBox(height: 10),
            _buildInfoCard('Phone: +216 98 47 71 82'),
            SizedBox(height: 10),
            _buildLinkCard('LinkedIn', 'https://www.linkedin.com/in/yassine-hallous'),
            SizedBox(height: 10),
            _buildLinkCard('GitHub', 'https://github.com/yassine-hallous'),
          ],
        ),
      ),
    );
  }

  // Helper method to create cards for profile information
  Widget _buildInfoCard(String text) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
      ),
      color: Color(0xFF373737),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFFFFFFFF),
          ),
          textAlign: TextAlign.center, // Centers the text in the card
        ),
      ),
    );
  }

  // Helper method to create clickable cards for links
  Widget _buildLinkCard(String text, String url) {
    return InkWell(
      onTap: () => _launchURL(url),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        color: Color(0xFF373737),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFFFFFFFF),
            ),
            textAlign: TextAlign.center, // Centers the text in the card
          ),
        ),
      ),
    );
  }

  // Method to launch URL
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}