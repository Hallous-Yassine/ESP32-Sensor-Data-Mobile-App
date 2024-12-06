import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class LineChartSample extends StatefulWidget {

  final String Pc_Ip_Address;

  LineChartSample({required this.Pc_Ip_Address});

  @override
  State<LineChartSample> createState() => _LineChartSampleState();
}

class AppColors {
  static const Color contentColorCyan = Color(0xFF00FFFF);
  static const Color contentColorBlue = Color(0xFF0000FF);
  static const Color mainGridLineColor = Color(0xFF37434D);
}

class _LineChartSampleState extends State<LineChartSample> {
  List<double> humidities = [];
  Timer? _fetchTimer;

  @override
  void initState() {
    super.initState();
    _fetchInitialTemperatures();
    _fetchTimer = Timer.periodic(Duration(seconds: 10), (timer) => _fetchNewTemperature());
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchInitialTemperatures() async {
    final url = 'http://${widget.Pc_Ip_Address}/api/read_humidity.php?type=humidity_chart'; // URL pour récupérer toutes les données initiales
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        if (data.isNotEmpty) {
          setState(() {
            humidities = data.map((item) => double.tryParse(item['humidity'].toString()) ?? 0.0).toList();
            if (humidities.length > 31) {
              humidities = humidities.sublist(humidities.length - 31); // Ne garder que les 30 dernières valeurs
            }
          });
        }
      } else {
        print('Erreur de réponse du serveur: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des données: $e');
    }
  }

  Future<void> _fetchNewTemperature() async {
    final url = 'http://${widget.Pc_Ip_Address}/api/read_humidity.php?type=humidity_chart'; // URL pour récupérer une nouvelle donnée
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          final newTemperature = double.tryParse(data.last['humidity'].toString());
          if (newTemperature != null) {
            setState(() {
              if (humidities.length > 31) {
                humidities.removeAt(0); // Supprimer la plus ancienne donnée
              }
              humidities.add(newTemperature);
            });
          } else {
            print('Erreur de parsing de la nouvelle température');
          }
        } else {
          print('Les données ne sont pas valides ou sont vides');
        }
      } else {
        print('Erreur lors de la récupération des nouvelles données: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception lors de la récupération de la nouvelle température: $e');
    }
  }

  List<Color> gradientColors = [
    AppColors.contentColorCyan,
    AppColors.contentColorBlue,
  ];

  @override
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: AspectRatio(
          aspectRatio: 1.00,
          child: LineChart(
            mainData(),
          ),
        ),
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('0', style: style);
        break;
      case 10:
        text = const Text('10', style: style);
        break;
      case 20:
        text = const Text('20', style: style);
        break;
      case 30:
        text = const Text('30', style: style);
        break;
      case 40:
        text = const Text('40', style: style);
        break;
      case 50:
        text = const Text('50', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0%';
        break;
      case 10:
        text = '10%';
        break;
      case 20:
        text = '20%';
        break;
      case 30:
        text = '30%';
        break;
      case 40:
        text = '40%';
        break;
      case 50:
        text = '50%';
        break;
      case 60:
        text = '60%';
        break;
      case 70:
        text = '70%';
        break;
      case 80:
        text = '80%';
        break;
      case 90:
        text = '90%';
        break;
      case 100:
        text = '100%';
        break;
      default:
        return Container();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Add vertical padding here
      child: Text(text, style: style, textAlign: TextAlign.left),
    );
  }

  LineChartData mainData() {
    final limitedTemperatures = humidities.length > 31
        ? humidities.sublist(humidities.length - 31)
        : humidities;

    final spots = limitedTemperatures.asMap().entries.map((entry) {
      int index = entry.key;
      double temp = entry.value;
      return FlSpot(index.toDouble(), temp);
    }).toList();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 5,
        verticalInterval: 5,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 10,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 10,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: (limitedTemperatures.length - 1).toDouble(),
      minY: 0,
      maxY: 100,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.2))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
