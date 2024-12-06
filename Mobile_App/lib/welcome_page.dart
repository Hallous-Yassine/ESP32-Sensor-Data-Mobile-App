import 'package:flutter/material.dart';
import 'sign_in_page.dart';
import 'sign_up_page.dart';
import 'choice_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WelcomePage extends StatefulWidget {
  final String ipAddress;

  WelcomePage({required this.ipAddress});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {

  @override
  void initState() {
    super.initState();
    resetCurrentUserId(); // Call to reset user ID when the page initializes
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    resetCurrentUserId(); // Call to reset user ID when returning to this page
  }

  Future<void> resetCurrentUserId() async {
    final String url = 'http://${widget.ipAddress}/api/reset_current_id.php';

    final response = await http.post(Uri.parse(url));

    if (response.statusCode == 200) {
      // Handle successful response if needed
      print('User ID reset to null');
    } else {
      // Handle error response
      print('Failed to reset User ID');
    }
  }

  Future<void> continueAsGuest() async {
    final String url = 'http://${widget.ipAddress}/api/continue_as_guest.php';

    try {
      final response = await http.post(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChoicePage(ipAddress: widget.ipAddress)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to continue as guest')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF34e89e), // Start color
              Color(0xFF0f3443), // End color
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // Top Section
            Padding(
              padding: const EdgeInsets.only(top: 50.0), // Top margin
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0), // Padding inside the container
                  margin: const EdgeInsets.symmetric(horizontal: 20.0), // Margin outside the container
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Welcome To Your\n ',
                              style: TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.5,
                              ),
                            ),
                            TextSpan(
                              text: 'Smart Home',
                              style: TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo[900], // Different color for "Smart Home"
                              ),
                            ),
                            TextSpan(
                              text: ' Tracker App',
                              style: TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10), // Space between the texts
                      Text(
                        'Temperature and Humidity',
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Divider(
                        color: Colors.blueGrey[700],
                        thickness: 2, // Line thickness
                        indent: 50,
                        endIndent: 50,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Enlarged photo
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5, // Fixed width
                  height: MediaQuery.of(context).size.height * 0.3, // Fixed height
                  child: Image.asset(
                    'assets/smart.png',
                    fit: BoxFit.cover, // Make sure the image covers the container
                  ),
                ),
              ),
            ),
            // Buttons and Sign Up text at the bottom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity, // Makes the button take the full width
                    child: ElevatedButton(
                      onPressed: () { // Call fetchData when Login button is pressed
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignInPage(ipAddress: widget.ipAddress)), // Navigate to Sign In Page
                        );
                      },
                      child: Text('Login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[700], // Button color
                        foregroundColor: Colors.white, // Text color
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        textStyle: TextStyle(fontSize: 27),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15), // Radius for rounded corners
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15), // Space between buttons
                  SizedBox(
                    width: double.infinity, // Makes the button take the full width
                    child: ElevatedButton(
                      onPressed: () {
                        continueAsGuest(); // Call the function to trigger continue_as_guest.php
                      },
                      child: Text('Continue as Guest'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[700], // Button color
                        foregroundColor: Colors.white, // Text color
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        textStyle: TextStyle(fontSize: 27),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15), // Radius for rounded corners
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account ?",
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUpPage(ipAddress: widget.ipAddress)), // Navigate to Sign Up Page
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo[300], // Different color for "Sign Up"
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20), // Space between the Sign Up text and the bottom
          ],
        ),
      ),
    );
  }
}
