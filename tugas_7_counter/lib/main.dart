import 'package:flutter/material.dart';

import 'counter_display.dart'; // Memanggil file widget angka
import 'counter_buttons.dart'; // Memanggil file widget tombol

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tugas 7 - Counter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CounterScreen(),
    );
  }
}

// Parent Widget yang mengelola State
class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _counter = 0; // State untuk menyimpan angka

  // 1. Lifecycle: Dijalankan pertama kali saat layar dibuka
  @override
  void initState() {
    super.initState();
    debugPrint("Counter dimulai"); // Output ke console/terminal
  }

  // 2. Lifecycle: Dijalankan saat layar/aplikasi ditutup
  @override
  void dispose() {
    debugPrint("Counter ditutup"); // Output ke console/terminal
    super.dispose();
  }

  // Fungsi Tambah
  void _increment() {
    setState(() {
      _counter++;
    });
  }

  // Fungsi Kurang (Ada validasi tidak boleh minus)
  void _decrement() {
    setState(() {
      if (_counter > 0) {
        _counter--;
      }
    });
  }

  // Fungsi Reset
  void _reset() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aplikasi Counter Tugas 7')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Passing Data (mengirim nilai _counter) ke widget CounterDisplay
            CounterDisplay(counterValue: _counter),

            const SizedBox(height: 50),

            // Passing Callback (mengirim fungsi) ke widget CounterButtons
            CounterButtons(
              onAdd: _increment,
              onSubtract: _decrement,
              onReset: _reset,
            ),
          ],
        ),
      ),
    );
  }
}
