import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tugas 4 - Form Registrasi',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const FormRegistrasi(),
    );
  }
}

// 1. StatefulWidget untuk Form
class FormRegistrasi extends StatefulWidget {
  const FormRegistrasi({super.key});

  @override
  State<FormRegistrasi> createState() => _FormRegistrasiState();
}

class _FormRegistrasiState extends State<FormRegistrasi> {
  // 2. GlobalKey untuk FormState
  final _formKey = GlobalKey<FormState>();

  // Controller TextField
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 3. FocusNode untuk pindah otomatis di keyboard
  final FocusNode _namaFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  // Variabel State
  String? _jenisKelamin;
  String? _prodi;
  bool _setujuSyarat = false;

  final List<String> _listProdi = [
    'Sistem Informasi',
    'Teknik Informatika',
    'Manajemen Informatika',
  ];

  @override
  void dispose() {
    // Membersihkan memori saat form ditutup
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _namaFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submitForm() {
    // 4. Validasi Checkbox dengan SnackBar peringatan
    if (!_setujuSyarat) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Peringatan: Anda harus menyetujui Syarat & Ketentuan!',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 2. Validasi Form Input
    if (_formKey.currentState!.validate()) {
      // 5. Tampilkan AlertDialog Ringkasan Data jika semua valid
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Konfirmasi Registrasi'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nama: ${_namaController.text}'),
                Text('Email: ${_emailController.text}'),
                Text('Jenis Kelamin: ${_jenisKelamin ?? '-'}'),
                Text('Program Studi: $_prodi'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                },
                child: const Text('OK Submit'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Registrasi Mahasiswa')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Pasang GlobalKey di sini
          child: ListView(
            children: [
              // Field Nama
              TextFormField(
                controller: _namaController,
                focusNode: _namaFocus,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                onFieldSubmitted: (_) {
                  FocusScope.of(context)
                      .requestFocus(_emailFocus); // Pindah ke Email
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Field Email
              TextFormField(
                controller: _emailController,
                focusNode: _emailFocus,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                onFieldSubmitted: (_) {
                  FocusScope.of(context)
                      .requestFocus(_passwordFocus); // Pindah ke Password
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!value.contains('@')) {
                    return 'Email harus mengandung "@"';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Field Password
              TextFormField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                obscureText: true,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  if (value.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Radio Jenis Kelamin
              const Text(
                'Jenis Kelamin:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'Laki-laki',
                    groupValue: _jenisKelamin,
                    onChanged: (value) => setState(() => _jenisKelamin = value),
                  ),
                  const Text('Laki-laki'),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: 'Perempuan',
                    groupValue: _jenisKelamin,
                    onChanged: (value) => setState(() => _jenisKelamin = value),
                  ),
                  const Text('Perempuan'),
                ],
              ),
              const SizedBox(height: 10),

              // Dropdown Program Studi
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Program Studi'),
                value: _prodi,
                items: _listProdi.map((String val) {
                  return DropdownMenuItem<String>(value: val, child: Text(val));
                }).toList(),
                onChanged: (value) => setState(() => _prodi = value),
                validator: (value) =>
                    value == null ? 'Program Studi wajib dipilih' : null,
              ),
              const SizedBox(height: 10),

              // Checkbox Syarat & Ketentuan
              CheckboxListTile(
                title: const Text('Saya setuju dengan Syarat & Ketentuan'),
                value: _setujuSyarat,
                onChanged: (value) =>
                    setState(() => _setujuSyarat = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 20),

              // Tombol Daftar
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Daftar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
