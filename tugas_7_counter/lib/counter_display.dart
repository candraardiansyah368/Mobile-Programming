import 'package:flutter/material.dart';

class CounterDisplay extends StatelessWidget {
  final int counterValue; // Variabel penampung data dari parent

  const CounterDisplay({super.key, required this.counterValue});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Nilai Counter Saat Ini:',
          style: TextStyle(fontSize: 20),
        ),
        Text(
          '$counterValue',
          style: const TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}