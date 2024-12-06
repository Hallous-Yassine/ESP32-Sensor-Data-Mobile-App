import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class RadialGaugeWidget extends StatelessWidget {
  final double currentTemperature;

  RadialGaugeWidget({required this.currentTemperature});

  @override
  Widget build(BuildContext context) {
    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          minimum: 0,
          maximum: 50,
          ranges: <GaugeRange>[
            GaugeRange(
              startValue: 0,
              endValue: 30,
              color: Colors.cyan,
              startWidth: 10,
              endWidth: 10,
            ),
            GaugeRange(
              startValue: 30,
              endValue: 50,
              color: Colors.redAccent,
              startWidth: 10,
              endWidth: 10,
            ),
          ],
          pointers: <GaugePointer>[
            NeedlePointer(
              value: currentTemperature,
              enableAnimation: true,
            ),
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              widget: Text(
                '${currentTemperature.toStringAsFixed(2)}°C',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              angle: 80,
              positionFactor: 0.4,
            ),
          ],
        ),
      ],
    );
  }
}