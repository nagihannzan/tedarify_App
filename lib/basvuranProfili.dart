import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tedarify/renkler.dart';

class Basvuranprofili extends StatefulWidget {
  final String userId;

  const Basvuranprofili({super.key, required this.userId});

  @override
  State<Basvuranprofili> createState() => _BasvuranprofiliState();
}  

class _BasvuranprofiliState extends State<Basvuranprofili> {
  late Future<Map<String, dynamic>> _userProfileFuture;
  late Future<List<Map<String, dynamic>>> _suppliesFuture;
  late Future<List<Map<String, dynamic>>> _sharingsFuture;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _userProfileFuture = _fetchUserProfile();
    _suppliesFuture = _fetchSupplies();
    _sharingsFuture = _fetchSharings();
  }

  Future<Map<String, dynamic>> _fetchUserProfile() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>;
    } else {
      throw Exception("User not found");
    }
  }

  Future<List<Map<String, dynamic>>> _fetchSupplies() async {
    QuerySnapshot suppliesSnapshot = await FirebaseFirestore.instance
        .collection('supplies')
        .where('userId', isEqualTo: widget.userId)
        .get();

    List<Map<String, dynamic>> supplies = [];
    for (var doc in suppliesSnapshot.docs) {
      supplies.add(doc.data() as Map<String, dynamic>);
    }
    return supplies;
  }

  
  Future<List<Map<String, dynamic>>> _fetchSharings() async {
    try {
      QuerySnapshot sharingsSnapshot = await FirebaseFirestore.instance
          .collection('my_sharings') 
          .where('userId',
              isEqualTo: widget.userId) 
          .get();

      List<Map<String, dynamic>> sharings = [];
      for (var doc in sharingsSnapshot.docs) {
        sharings.add(doc.data() as Map<String, dynamic>);
      }
      return sharings;
    } catch (e) {
      debugPrint('Error fetching sharings: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appArkaplan,
        title: const Text(
          'Applicant Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userProfileFuture,
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (userSnapshot.hasError) {
            return const Center(child: Text('An error occurred'));
          } else if (!userSnapshot.hasData) {
            return const Center(child: Text('User profile not found'));
          }

          Map<String, dynamic> user = userSnapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                
                  Container(
                    color: Colors.purple.shade50,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.teal,
                          child: Text(
                            user['name'][0], 
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${user['name']} ${user['surname']}',
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              user['sector'] ?? 'Sector not specified',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              user['location'] ?? 'Location not specified',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          setState(() => selectedIndex = 0);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: selectedIndex == 0
                              ? Colors.teal.shade700
                              : Colors.grey.shade200,
                        ),
                        child: Text(
                          "Supplies",
                          style: TextStyle(
                              color:
                                  selectedIndex == 0 ? Colors.white : koyuYazi,
                              fontSize: 18),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          setState(() => selectedIndex = 1);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: selectedIndex == 1
                              ? Colors.teal.shade700
                              : Colors.grey.shade200,
                        ),
                        child: Text(
                          "Sharings",
                          style: TextStyle(
                              color:
                                  selectedIndex == 1 ? Colors.white : koyuYazi,
                              fontSize: 18),
                        ),
                      ),
                    ),
                  ]),

                  selectedIndex == 0
                      ? _buildSuppliesList()
                      : _buildSharingsList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuppliesList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _suppliesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(
              child: Text('An error occurred while fetching supplies'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No supplies found'));
        }

        List<Map<String, dynamic>> supplies = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: supplies.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> supply = supplies[index];
            return Card(
              color: Colors.purple.shade50,
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(supply['supplyName'] ?? 'Untitled'),
                subtitle: Text(supply['supplyContent'] ?? 'No description'),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSharingsList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _sharingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(
              child: Text('An error occurred while fetching sharings'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No sharings found'));
        }

        List<Map<String, dynamic>> sharings = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sharings.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> sharing = sharings[index];
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('supplies')
                  .doc(sharing[
                      'supplyId']) 
                  .get(),
              builder: (context, supplySnapshot) {
                if (supplySnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (supplySnapshot.hasError) {
                  return const Center(child: Text("Error loading supply"));
                } else if (!supplySnapshot.hasData ||
                    !supplySnapshot.data!.exists) {
                  return const Center(child: Text("Supply not found"));
                }

                Map<String, dynamic> supplyData =
                    supplySnapshot.data!.data() as Map<String, dynamic>;

                return Card(
                  color: Colors.purple.shade50,
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(supplyData['supplyName'] ?? 'Untitled'),
                    subtitle: Text(
                        'Content: ${supplyData['supplyContent'] ?? 'No Content'}'),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
