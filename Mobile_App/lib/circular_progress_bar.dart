import 'package:flutter/material.dart';
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';

class CircularProgressBar extends StatefulWidget {
  final double currenthumidity;

  CircularProgressBar({required this.currenthumidity});

  @override
  _CircularProgressBarState createState() => _CircularProgressBarState();
}

class _CircularProgressBarState extends State<CircularProgressBar> {
  late ValueNotifier<double> _valueNotifier;

  @override
  void initState() {
    super.initState();
    _valueNotifier = ValueNotifier(widget.currenthumidity);
  }

  @override
  void didUpdateWidget(CircularProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currenthumidity != widget.currenthumidity) {
      _valueNotifier.value = widget.currenthumidity;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashedCircularProgressBar.aspectRatio(
      aspectRatio: 1, // width ÷ height
      valueNotifier: _valueNotifier,
      progress: widget.currenthumidity,
      startAngle: 225,
      sweepAngle: 270,
      foregroundColor: Colors.blue,
      backgroundColor: const Color(0xffeeeeee),
      foregroundStrokeWidth: 15,
      backgroundStrokeWidth: 15,
      animation: true,
      seekSize: 6,
      seekColor: const Color(0xffeeeeee),
      child: Center(
        child: ValueListenableBuilder<double>(
          valueListenable: _valueNotifier,
          builder: (_, double value, __) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${value.toInt()}%',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                  fontSize: 60,
                ),
              ),
              Text(
                'Humidity',
                style: const TextStyle(
                  color: Color(0xffeeeeee),
                  fontWeight: FontWeight.w400,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
