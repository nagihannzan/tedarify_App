import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tedarify/basvurular.dart';
import 'package:tedarify/profilim.dart';
import 'package:tedarify/renkler.dart';

class Detaysayfa extends StatefulWidget {
  final String supplyId;
  const Detaysayfa({super.key, required this.supplyId});

  @override
  State<Detaysayfa> createState() => _DetaysayfaState();
}

class _DetaysayfaState extends State<Detaysayfa> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  DateTime? _selectedDate;

  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _supplyData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchSupplyData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        _userData = userDoc.data() as Map<String, dynamic>?;
      });
    }
  }

  Future<void> _fetchSupplyData() async {
    DocumentSnapshot supplyDoc = await FirebaseFirestore.instance
        .collection('supplies')
        .doc(widget.supplyId)
        .get();
    if (supplyDoc.exists) {
      setState(() {
        _supplyData = supplyDoc.data() as Map<String, dynamic>?;
        _nameController.text = _supplyData?['supplyName'] ?? '';
        _contentController.text = _supplyData?['supplyContent'] ?? '';
        if (_supplyData?['lastDate'] != null) {
          List<String> dateParts =
              (_supplyData!['lastDate'] as String).split('/');
          _selectedDate = DateTime(
            int.parse(dateParts[2]),
            int.parse(dateParts[1]),
            int.parse(dateParts[0]),
          );
        }
      });
    }
  }

  Future<void> _updateSupply() async {
    if (_formKey.currentState?.validate() ?? false) {
      String lastDate = _selectedDate != null
          ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
          : "No date selected";

      await FirebaseFirestore.instance
          .collection('supplies')
          .doc(widget.supplyId)
          .update({
        'supplyName': _nameController.text,
        'supplyContent': _contentController.text,
        'lastDate': lastDate,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Supply updated successfully!')),
      );

      // Profilim sayfasına dön ve veriyi güncelle
      Navigator.pop(
          context, true); // true göndererek profil sayfasında güncelleme yap
    }
  }

  Future<void> _deleteSupply() async {
    // Tedarik kaydını Firestore'dan sil
    await FirebaseFirestore.instance
        .collection('supplies')
        .doc(widget.supplyId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Supply deleted successfully!')),
    );

    // Profilim sayfasına dön ve güncelleme yapılacak bilgiyi gönder
    Navigator.pop(context, true); // true göndererek profil sayfasını güncelle
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appArkaplan,
        title: const Text(
          "Supply Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_userData != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('resimler/profil.jpg'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${_userData?['name']} ${_userData?['surname']}",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: koyuYazi,
                    ),
                  ),
                  Text(
                    "${_userData?['sector']} | ${_userData?['location']}",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            if (_supplyData != null)
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration:
                          const InputDecoration(labelText: "Supply name"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a supply name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(labelText: "Content"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter content';
                        }
                        return null;
                      },
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
                          icon: const Icon(Icons.calendar_today,
                              color: Colors.purple),
                          onPressed: _pickDate,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade700),
                          onPressed: _updateSupply,
                          child: const Text(
                            "Update",
                            style: TextStyle(color: Colors.white, fontSize: 17),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          onPressed: _deleteSupply,
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.white, fontSize: 17),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: appArkaplan),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Basvurular(supplyId: widget.supplyId),
                          ),
                        );
                      },
                      child: Text(
                        "Applicants",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
