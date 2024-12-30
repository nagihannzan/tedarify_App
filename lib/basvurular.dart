import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tedarify/basvuranProfili.dart';
import 'package:tedarify/renkler.dart';

class Basvurular extends StatefulWidget {
  final String supplyId;

  const Basvurular({super.key, required this.supplyId});

  @override
  State<Basvurular> createState() => _BasvurularState();
}

class _BasvurularState extends State<Basvurular> {
  late Future<List<Map<String, dynamic>>> _applicantsFuture;

  @override
  void initState() {
    super.initState();
    _applicantsFuture = _fetchApplicants();
  }

  Future<List<Map<String, dynamic>>> _fetchApplicants() async {
    QuerySnapshot applicationsSnapshot = await FirebaseFirestore.instance
        .collection('applications')
        .where('supplyId', isEqualTo: widget.supplyId)
        .get();

    List<Map<String, dynamic>> applicants = [];
    for (var doc in applicationsSnapshot.docs) {
      String userId = doc['userId'];
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        applicants.add(userDoc.data() as Map<String, dynamic>
          ..['userId'] = userId); // userId'yi ekliyoruz
      }
    }
    return applicants;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appArkaplan,
        title: const Text(
          'Applicants',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _applicantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('An error occurred'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No applicants found'));
          }

          List<Map<String, dynamic>> applicants = snapshot.data!;

          return ListView.builder(
            itemCount: applicants.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> applicant = applicants[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Text(
                      applicant['name'][0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text('${applicant['name']} ${applicant['surname']}'),
                  subtitle: Text('${applicant['sector']}'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Basvuranprofili(userId: applicant['userId'])));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
