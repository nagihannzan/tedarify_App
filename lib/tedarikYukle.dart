import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tedarify/profilim.dart';
import 'package:tedarify/renkler.dart';

class Tedarikyukle extends StatefulWidget {
  const Tedarikyukle({Key? key}) : super(key: key);

  @override
  State<Tedarikyukle> createState() => _TedarikyukleState();
}

class _TedarikyukleState extends State<Tedarikyukle> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _supplyNameController = TextEditingController();
  final TextEditingController _supplyContentController =
      TextEditingController();
  final TextEditingController _industryController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Firebase'e veri yükleme
  void _uploadData() async {
    if (_formKey.currentState?.validate() ?? false) {
      String supplyName = _supplyNameController.text;
      String supplyContent = _supplyContentController.text;
      String industry = _industryController.text;
      String lastDate = _selectedDate != null
          ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
          : "No date selected";

      // Firebase Firestore'a veri ekleme
      try {
        User? user = FirebaseAuth.instance.currentUser; // Kullanıcıyı al
        if (user != null) {
          // Veriyi Firestore'da 'supplies' koleksiyonuna ekle
          await FirebaseFirestore.instance.collection('supplies').add({
            'userId': user.uid, // Kullanıcı kimliği
            'supplyName': supplyName,
            'supplyContent': supplyContent,
            'industry': industry,
            'lastDate': lastDate,
          });

          // Başarı mesajı
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data uploaded successfully!')),
          );

          // Profil sayfasına yönlendir
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Profilim()),
          );
        } else {
          throw Exception("User not logged in");
        }
      } catch (e) {
        // Hata mesajı
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tedArkaplan,
      appBar: AppBar(
        backgroundColor: appArkaplan,
        title: const Text(
          'Upload Supply',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _supplyNameController,
                  decoration:
                      const InputDecoration(labelText: 'Enter the supply name'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter a name'
                      : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _supplyContentController,
                  decoration:
                      const InputDecoration(labelText: 'Enter supply content'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter the content'
                      : null,
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _industryController,
                  decoration: const InputDecoration(
                      labelText: 'Enter the industry of the supply'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter the industry'
                      : null,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? '   Enter the last date of the ad'
                          : "Selected Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.calendar_today,
                      color: appArkaplan,
                    ),
                    onPressed: _pickDate,
                  ),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _uploadData(); // Veri yükleme fonksiyonunu çağır.
                    }
                  },
                  child: Text(
                    'UPLOAD',
                    style: TextStyle(
                        color: appArkaplan,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
