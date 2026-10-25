import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tugas 5 CRUD API',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const UserListScreen(),
    );
  }
}

class UserModel {
  final int? id;
  final String email;
  final String firstName;
  final String lastName;
  final String avatar;

  UserModel({
    this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      avatar: json['avatar'] ?? 'https://reqres.in/img/faces/1-image.jpg',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'avatar': avatar,
    };
  }
}


class UserService {
  static const String baseUrl = 'https://reqres.in/api/users';

  Future<List<UserModel>> getUsers() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> usersJson = data['data'];
        return usersJson.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil data.');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet.');
    }
  }

  Future<UserModel> createUser(String firstName, String lastName, String email) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        body: {'first_name': firstName, 'last_name': lastName, 'email': email},
      );
      if (response.statusCode == 201) {
        return UserModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Gagal membuat user.');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet.');
    }
  }

  Future<UserModel> updateUser(int id, String firstName, String lastName, String email) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        body: {'first_name': firstName, 'last_name': lastName, 'email': email},
      );
      if (response.statusCode == 200) {
        return UserModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Gagal update user.');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet.');
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      if (response.statusCode != 204) {
        throw Exception('Gagal menghapus user.');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet.');
    }
  }
}


class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final UserService _userService = UserService();
  List<UserModel> _localUsers = [];
  late Future<List<UserModel>> _futureUsers;

  @override
  void initState() {
    super.initState();
    _futureUsers = _loadData();
  }

  Future<List<UserModel>> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('saved_users_db');

    if (savedData != null) {
      List<dynamic> decoded = json.decode(savedData);
      _localUsers = decoded.map((e) => UserModel.fromJson(e)).toList();
      return _localUsers;
    } else {
      final users = await _userService.getUsers();
      _localUsers = users;
      await _saveToLocal();
      return _localUsers;
    }
  }

  Future<void> _saveToLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonData = _localUsers.map((u) => u.toJson()).toList();
    await prefs.setString('saved_users_db', json.encode(jsonData));
  }

  void _deleteUser(int id) async {
    try {
      await _userService.deleteUser(id);
      setState(() {
        _localUsers.removeWhere((user) => user.id == id);
        _futureUsers = Future.value(_localUsers);
      });
      await _saveToLocal();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil dihapus (DELETE)'), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  void _resetData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_users_db');
    setState(() {
      _futureUsers = _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas 5 CRUD API'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Data',
            onPressed: _resetData,
          )
        ],
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _futureUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final user = snapshot.data![index];
                return ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage(user.avatar)),
                  title: Text('${user.firstName} ${user.lastName}'),
                  subtitle: Text(user.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () async {
                          final updatedUser = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UpdateUserScreen(user: user)),
                          );
                          if (updatedUser != null && updatedUser is UserModel) {
                            setState(() {
                              _localUsers[index] = updatedUser;
                              _futureUsers = Future.value(_localUsers);
                            });
                            await _saveToLocal();
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteUser(user.id ?? 0),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const Center(child: Text('Data Kosong'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newUser = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateUserScreen()),
          );
          if (newUser != null && newUser is UserModel) {
            setState(() {
              _localUsers.insert(0, newUser);
              _futureUsers = Future.value(_localUsers);
            });
            await _saveToLocal();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}


class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  

  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  final UserService _userService = UserService();
  bool _isLoading = false;

  @override
  void dispose() {
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _submitData() async {
   
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final apiUser = await _userService.createUser(
          _firstNameCtrl.text,
          _lastNameCtrl.text,
          _emailCtrl.text,
        );
        
        final finalUser = UserModel(
          id: DateTime.now().millisecondsSinceEpoch,
          email: _emailCtrl.text.toLowerCase().trim(),
          firstName: apiUser.firstName,
          lastName: apiUser.lastName,
          avatar: apiUser.avatar,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil membuat user (POST)'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, finalUser);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah User'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameCtrl,
                decoration: const InputDecoration(labelText: 'First Name'),
                textInputAction: TextInputAction.next,
             
                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_lastNameFocus),
                validator: (val) => val == null || val.trim().isEmpty ? 'First Name wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastNameCtrl,
                focusNode: _lastNameFocus,
                decoration: const InputDecoration(labelText: 'Last Name'),
                textInputAction: TextInputAction.next,
               
                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocus),
                validator: (val) => val == null || val.trim().isEmpty ? 'Last Name wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                focusNode: _emailFocus,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
           
                onFieldSubmitted: (_) => _submitData(),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Email wajib diisi';
                  
                 
                  String emailInput = val.trim().toLowerCase();
                  if (!emailInput.endsWith('@gmail.com') && 
                      !emailInput.endsWith('@hotmail.com') && 
                      !emailInput.endsWith('@yahoo.com')) {
                    return 'Gunakan akhiran @gmail.com, @hotmail.com, atau @yahoo.com';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitData,
                  child: _isLoading ? const CircularProgressIndicator() : const Text('Simpan'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


class UpdateUserScreen extends StatefulWidget {
  final UserModel user;
  const UpdateUserScreen({super.key, required this.user});

  @override
  State<UpdateUserScreen> createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _emailCtrl;
  
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  final UserService _userService = UserService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController(text: widget.user.firstName);
    _lastNameCtrl = TextEditingController(text: widget.user.lastName);
    _emailCtrl = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _submitUpdate() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _userService.updateUser(
          widget.user.id ?? 0,
          _firstNameCtrl.text,
          _lastNameCtrl.text,
          _emailCtrl.text,
        );
        
        final updatedUser = UserModel(
          id: widget.user.id,
          firstName: _firstNameCtrl.text,
          lastName: _lastNameCtrl.text,
          email: _emailCtrl.text.toLowerCase().trim(),
          avatar: widget.user.avatar,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil diupdate (PUT)'), backgroundColor: Colors.blue),
        );
        Navigator.pop(context, updatedUser);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update User'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameCtrl,
                decoration: const InputDecoration(labelText: 'First Name'),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_lastNameFocus),
                validator: (val) => val == null || val.trim().isEmpty ? 'First Name wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastNameCtrl,
                focusNode: _lastNameFocus,
                decoration: const InputDecoration(labelText: 'Last Name'),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocus),
                validator: (val) => val == null || val.trim().isEmpty ? 'Last Name wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                focusNode: _emailFocus,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submitUpdate(),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Email wajib diisi';
                  
                  String emailInput = val.trim().toLowerCase();
                  if (!emailInput.endsWith('@gmail.com') && 
                      !emailInput.endsWith('@hotmail.com') && 
                      !emailInput.endsWith('@yahoo.com')) {
                    return 'Gunakan akhiran @gmail.com, @hotmail.com, atau @yahoo.com';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitUpdate,
                  child: _isLoading ? const CircularProgressIndicator() : const Text('Simpan Perubahan'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
