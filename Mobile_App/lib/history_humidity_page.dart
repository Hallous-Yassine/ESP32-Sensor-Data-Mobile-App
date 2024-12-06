import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistoryHumidityPage extends StatefulWidget {
  final String Pc_Ip_Address;

  HistoryHumidityPage({required this.Pc_Ip_Address});

  @override
  _HistoryHumidityPageState createState() => _HistoryHumidityPageState();
}

class _HistoryHumidityPageState extends State<HistoryHumidityPage> {
  List<dynamic> historyDataList = [];
  late StreamController<List<dynamic>> _streamController;
  late Stream<List<dynamic>> _stream;
  bool _isFetching = false;
  Timer? _fetchTimer;

  @override
  void initState() {
    super.initState();
    _streamController = StreamController<List<dynamic>>();
    _stream = _streamController.stream;
    fetchHistoryData();
    _fetchTimer = Timer.periodic(Duration(seconds: 10), (Timer) => fetchHistoryData());
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    _streamController.close();
    super.dispose();
  }

  Future<void> fetchHistoryData() async {
    setState(() {
      _isFetching = true;
    });

    var url = "http://${widget.Pc_Ip_Address}/api/read_humidity.php?type=history_humidity";

    try {
      var res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);

        if (data is List) {
          setState(() {
            historyDataList = List.from(data);
            _streamController.add(historyDataList);
          });
        } else {
          print('Unexpected data format');
        }
      } else {
        print('Failed to fetch data. Status code: ${res.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
      _streamController.addError(e);
    } finally {
      setState(() {
        _isFetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF34e89e), Color(0xFF0f3443)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: StreamBuilder<List<dynamic>>(
          stream: _stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: Colors.cyan));
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No Historical Data Available'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final data = snapshot.data![index];
                  return ListTile(
                    leading: Icon(
                      Icons.opacity,
                      color: Colors.red[300], // Color of the icon
                      size: 30, // Size of the icon
                    ),
                    title: Text(
                      'Humidity : ${data['humidity'] ?? 'No Humidity data'}',
                      style: TextStyle(
                        color: Colors.grey[100], // Color of the title text
                        fontSize: 18, // Size of the title text
                        fontWeight: FontWeight.bold, // Bold text
                      ),
                    ),
                    subtitle: Text(
                      'Date: ${data['timestamp'] ?? 'No timestamp data'}',
                      style: TextStyle(
                        color: Colors.white60, // Color of the subtitle text
                        fontSize: 16, // Size of the subtitle text
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _isFetching ? null : fetchHistoryData,
          backgroundColor: Color(0xFF0f3443), // Change this to your desired background color
          child: _isFetching
              ? CircularProgressIndicator(color: Colors.cyan)
              : Icon(Icons.refresh, color: Colors.cyan), // Change this to your desired icon color
          tooltip: 'Refresh Data',
        ),
      ),
    );
  }
}
