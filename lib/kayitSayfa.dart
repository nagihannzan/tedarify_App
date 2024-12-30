import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth import
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import
import 'package:tedarify/renkler.dart';

class Kayitsayfa extends StatefulWidget {
  const Kayitsayfa({super.key});

  @override
  State<Kayitsayfa> createState() => _KayitsayfaState();
}

class _KayitsayfaState extends State<Kayitsayfa> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String? _selectedSector;
  final List<String> _sectors = [
    'Otomotiv',
    'Tekstil',
    'Gıda',
    'Kimya',
    'Makine'
  ];

  final _formKey = GlobalKey<FormState>();

  Future<void> _registerUser() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Kullanıcı bilgilerini Firestore'da sakla
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': _nameController.text.trim(),
        'surname': _surnameController.text.trim(),
        'email': _emailController.text.trim(),
        'sector': _selectedSector,
        'location': _locationController.text.trim(),
        'created_at': FieldValue.serverTimestamp(),
      });

      // Başarılı mesajı göster ve giriş sayfasına dön
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration successful!")),
      );
      Navigator.pop(context); // Giriş sayfasına dönmek için
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: tedArkaplan,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: koyuYazi),
        ),
      ),
      backgroundColor: Colors.purple.shade50,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'TEDARIFY',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: appArkaplan,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  buildTextField('Enter your name', _nameController),
                  SizedBox(height: 20),
                  buildTextField('Enter your surname', _surnameController),
                  SizedBox(height: 20),
                  buildEmailField(),
                  SizedBox(height: 20),
                  buildDropdownMenu(),
                  SizedBox(height: 20),
                  buildTextField('Enter your location', _locationController),
                  SizedBox(height: 20),
                  buildTextField('Enter your password', _passwordController,
                      isPassword: true),
                  SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _registerUser(); // Firebase'e kullanıcı kaydı
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appArkaplan,
                        padding: EdgeInsets.symmetric(
                            horizontal: 50.0, vertical: 15.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'SIGN UP',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String hint, TextEditingController controller,
      {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field cannot be empty';
        }
        return null;
      },
    );
  }

  Widget buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        hintText: 'Enter your e-mail',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an e-mail';
        }
        String emailPattern =
            r'^[a-zA-Z0-9.a-zA-Z0-9.!#$%&’*+-/=?^_{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+';
        RegExp regex = RegExp(emailPattern);
        if (!regex.hasMatch(value)) {
          return 'Please enter a valid e-mail address';
        }
        return null;
      },
    );
  }

  Widget buildDropdownMenu() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedSector,
        hint: Text('Enter your sector'),
        isExpanded: true,
        decoration: InputDecoration.collapsed(hintText: ''),
        items: _sectors.map((sector) {
          return DropdownMenuItem<String>(
            value: sector,
            child: Text(sector),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedSector = value;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please select a sector';
          }
          return null;
        },
      ),
    );
  }
}
