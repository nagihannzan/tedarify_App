import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tedarify/detaySayfa.dart';
import 'package:tedarify/renkler.dart';

class Profilim extends StatefulWidget {
  const Profilim({Key? key}) : super(key: key);

  @override
  State<Profilim> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<Profilim> {
  int selectedIndex = 0;
  late Future<DocumentSnapshot> userProfile;
  late Future<QuerySnapshot> userSupplies;
  late Future<QuerySnapshot> userApplications;
  late Future<QuerySnapshot> userSharings; 

  @override
  void initState() {
    super.initState();
    userProfile = getUserProfile();
    userSupplies = getUserSupplies();
    userApplications = getUserApplications();
    userSharings = getUserSharings(); 
  }

  Future<DocumentSnapshot> getUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    } else {
      throw Exception("User is not logged in");
    }
  }

  Future<QuerySnapshot> getUserSupplies() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('supplies')
          .where('userId', isEqualTo: user.uid)
          .get();
    } else {
      throw Exception("User is not logged in");
    }
  }

  Future<QuerySnapshot> getUserApplications() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('applications')
          .where('userId', isEqualTo: user.uid)
          .get();
    } else {
      throw Exception("User is not logged in");
    }
  }

  Future<QuerySnapshot> getUserSharings() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection(
              'my_sharings') 
          .get();
    } else {
      throw Exception("User is not logged in");
    }
  }

  void refreshProfile() {
    setState(() {
      userProfile = getUserProfile();
      userSupplies = getUserSupplies();
      userApplications = getUserApplications();
      userSharings = getUserSharings(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: appArkaplan,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
         
          FutureBuilder<DocumentSnapshot>(
            future: userProfile,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Center(child: Text("No user data found"));
              }

              var userData = snapshot.data!.data() as Map<String, dynamic>;

              return Container(
                color: Colors.purple.shade50,
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('resimler/profil.jpg'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userData['name'] ?? 'No name',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: koyuYazi),
                          ),
                          Text(
                            userData['surname'] ?? 'No surname',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: koyuYazi),
                          ),
                          Text(
                            userData['sector'] ?? 'No sector',
                            style: TextStyle(color: koyuYazi, fontSize: 17),
                          ),
                          Text(
                            userData['location'] ?? 'No location',
                            style: TextStyle(color: koyuYazi, fontSize: 17),
                          ),
                          TextButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.edit, size: 18, color: acikYazi),
                            label: Text(
                              "Edit Profile",
                              style: TextStyle(color: acikYazi, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          Row(
            children: [
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
                    "My Supplies",
                    style: TextStyle(
                        color: selectedIndex == 0 ? Colors.white : koyuYazi,
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
                    "My Applications",
                    style: TextStyle(
                        color: selectedIndex == 1 ? Colors.white : koyuYazi,
                        fontSize: 18),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() => selectedIndex = 2);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: selectedIndex == 2
                        ? Colors.teal.shade700
                        : Colors.grey.shade200,
                  ),
                  child: Text(
                    "My Sharings", 
                    style: TextStyle(
                        color: selectedIndex == 2 ? Colors.white : koyuYazi,
                        fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
          
          Expanded(
            child: selectedIndex == 0
                ? _buildPosts()
                : selectedIndex == 1
                    ? _buildApplications()
                    : _buildSharings(), 
          ),
        ],
      ),
    );
  }

  Widget _buildSharings() {
    return FutureBuilder<QuerySnapshot>(
      future: userSharings, 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No shared supplies found"));
        }

        var sharingsData = snapshot.data!.docs;

        print('Sharings data: $sharingsData');

        return ListView.builder(
          itemCount: sharingsData.length,
          itemBuilder: (context, index) {
            var sharing = sharingsData[index].data() as Map<String, dynamic>;
            var supplyId = sharing['supplyId'];

            print('Supply ID: $supplyId');

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('supplies')
                  .doc(
                      supplyId) 
                  .get(),
              builder: (context, supplySnapshot) {
                if (supplySnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (supplySnapshot.hasError) {
                  return Center(child: Text("Error: ${supplySnapshot.error}"));
                }

                if (!supplySnapshot.hasData || !supplySnapshot.data!.exists) {
                  return Center(child: Text("Supply data not found"));
                }

                var supplyData =
                    supplySnapshot.data!.data() as Map<String, dynamic>;

                return _buildListItem(
                  title: supplyData['supplyName'] ?? 'No title',
                  description: supplyData['supplyContent'] ?? 'No description',
                  date: supplyData['lastDate'] ?? 'No date',
                  buttonLabel: "Apply",
                  onButtonPressed: () {
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPosts() {
    return FutureBuilder<QuerySnapshot>(
      future: userSupplies,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No supplies found"));
        }

        var suppliesData = snapshot.data!.docs;

        return ListView.builder(
          itemCount: suppliesData.length,
          itemBuilder: (context, index) {
            var supply = suppliesData[index].data() as Map<String, dynamic>;

            return _buildListItem(
              title: supply['supplyName'] ?? 'No title',
              description: supply['supplyContent'] ?? 'No description',
              date: supply['lastDate'] ?? 'No date',
              buttonLabel: "View Details",
              onButtonPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Detaysayfa(supplyId: suppliesData[index].id)),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildApplications() {
    return FutureBuilder<QuerySnapshot>(
      future: userApplications,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No applications found"));
        }

        var applicationsData = snapshot.data!.docs;

        return ListView.builder(
          itemCount: applicationsData.length,
          itemBuilder: (context, index) {
            var application =
                applicationsData[index].data() as Map<String, dynamic>;

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('supplies')
                  .doc(application['supplyId'])
                  .get(),
              builder: (context, supplySnapshot) {
                if (supplySnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (supplySnapshot.hasError) {
                  return Center(child: Text("Error: ${supplySnapshot.error}"));
                }

                if (!supplySnapshot.hasData || !supplySnapshot.data!.exists) {
                  return Center(child: Text("No supply data found"));
                }

                var supplyData =
                    supplySnapshot.data!.data() as Map<String, dynamic>;

                return _buildListItem(
                  title: supplyData['supplyName'] ?? 'No title',
                  description: supplyData['supplyContent'] ?? 'No description',
                  date: supplyData['lastDate'] ?? 'No date',
                  buttonLabel: "Delete",
                  onButtonPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('applications')
                        .doc(applicationsData[index].id)
                        .delete();
                    setState(() {
                      userApplications = getUserApplications();
                    });
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildListItem({
    required String title,
    required String description,
    required String date,
    required String buttonLabel,
    required VoidCallback onButtonPressed,
  }) {
    return Card(
      color: Colors.purple.shade50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: koyuYazi, fontSize: 17)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description, style: TextStyle(color: acikYazi, fontSize: 16)),
            const SizedBox(height: 4),
            Text(date,
                style: TextStyle(color: Colors.grey.shade800, fontSize: 15)),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: onButtonPressed,
          style: ElevatedButton.styleFrom(backgroundColor: appArkaplan),
          child: Text(buttonLabel,
              style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ),
    );
  }
}
