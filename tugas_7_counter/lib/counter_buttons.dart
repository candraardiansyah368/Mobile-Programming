import 'package:flutter/material.dart';

class CounterButtons extends StatelessWidget {
  // Menyiapkan slot untuk 3 fungsi callback
  final VoidCallback onAdd;
  final VoidCallback onSubtract;
  final VoidCallback onReset;

  const CounterButtons({
    super.key,
    required this.onAdd,
    required this.onSubtract,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: onSubtract, // Panggil fungsi kurang
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('-1', style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
        ElevatedButton(
          onPressed: onReset, // Panggil fungsi reset
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
          child: const Text('Reset', style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
        ElevatedButton(
          onPressed: onAdd, // Panggil fungsi tambah
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('+1', style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ],
    );
  }
}