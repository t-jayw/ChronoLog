import 'package:flutter/material.dart';
import 'package:chronolog/components/analog_clock.dart';

class ClockScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analog Clock'),
      ),
      body: Center(
        child: AnalogClock(), // Assuming AnalogClock is a widget you have
      ),
    );
  }
}