import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tedarify/girisSayfa.dart';
import 'package:tedarify/kaydedilenler.dart';
import 'package:tedarify/profilim.dart';
import 'package:tedarify/renkler.dart';
import 'package:tedarify/tedarikYukle.dart';

class Anaakissayfa extends StatefulWidget {
  const Anaakissayfa({super.key});

  @override
  State<Anaakissayfa> createState() => _AnaakissayfaState();
}

class _AnaakissayfaState extends State<Anaakissayfa> {
  String selectedCategory = 'All';
  List<String> categories = [
    'All',
    'Automotive',
    'Food',
    'Chemical',
    'Textile',
    'Machinery'
  ];

  List<String> buttonStates = [];

  Future<void> applyForSupply(String supplyId, BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      final applicantName = '${userDoc['name']} ${userDoc['surname']}';

      final supplyDoc = await FirebaseFirestore.instance
          .collection('supplies')
          .doc(supplyId)
          .get();
      final ownerId = supplyDoc['userId'];

      // Başvuru kaydını applications koleksiyonuna ekle
      final applicationRef =
          FirebaseFirestore.instance.collection('applications').doc();
      await applicationRef.set({
        'supplyId': supplyId,
        'userId': userId,
        'status': 'Applied',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Başvuru yapılan tedarik kaydını güncelle
      await FirebaseFirestore.instance
          .collection('supplies')
          .doc(supplyId)
          .update({
        'applied': FieldValue.arrayUnion([userId]),
      });

      // Başvurulan tedarik bilgilerini kullanıcı profiline ekle
      final userApplicationsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('myApplications')
          .doc(supplyId);

      await userApplicationsRef.set({
        'supplyId': supplyId,
        'status': 'Applied',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Bildirimi tedarik sahibine gönder
      final notificationRef =
          FirebaseFirestore.instance.collection('notifications').doc();
      await notificationRef.set({
        'userId': ownerId,
        'message': '$applicantName has applied for your supply.',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Application submitted successfully.")),
      );
    }
  }

  Future<String> getUserName(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc['name'] ?? 'Unknown User';
  }

  void addToMySharings(String supplyId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final sharingRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('my_sharings')
          .doc(supplyId);

      await sharingRef.set({
        'supplyId': supplyId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> shareSupply(String supplyId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception("User not logged in");
    }

    try {
      await FirebaseFirestore.instance.collection('my_sharings').add({
        'userId': currentUser.uid, // Şu anki kullanıcı ID'si
        'supplyId': supplyId, // Paylaşılan tedarik ID'si
        'sharedAt': Timestamp.now(), // Paylaşım tarihi
      });
      debugPrint("Sharing added successfully!");
      addToMySharings(
          supplyId); // Kullanıcının 'my_sharings' koleksiyonuna ekle
    } catch (e) {
      debugPrint("Error while sharing supply: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tedArkaplan,
      appBar: AppBar(
        backgroundColor: appArkaplan,
        title: Text("HOME PAGE", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              _showNotifications(context);
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: tedArkaplan,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: appArkaplan),
              child: Padding(
                padding: const EdgeInsets.only(top: 47),
                child: Text('MENU',
                    style: TextStyle(color: Colors.white, fontSize: 36)),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: koyuYazi),
              title: Text('My Profile', style: TextStyle(color: koyuYazi)),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Profilim()));
              },
            ),
            ListTile(
              leading: Icon(Icons.upload_file, color: koyuYazi),
              title: Text('Upload Supply', style: TextStyle(color: koyuYazi)),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Tedarikyukle()));
              },
            ),
            ListTile(
              leading: Icon(Icons.bookmark, color: koyuYazi),
              title: Text('Saved', style: TextStyle(color: koyuYazi)),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Kaydedilenler()));
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: koyuYazi),
              title: Text('Log Out', style: TextStyle(color: koyuYazi)),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Girissayfa()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories
                  .map((category) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ChoiceChip(
                          label: Text(
                            category,
                            style: TextStyle(color: koyuYazi),
                          ),
                          selected: selectedCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                        ),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('supplies')
                  .where('userId',
                      isNotEqualTo: FirebaseAuth.instance.currentUser
                          ?.uid) // Giriş yapan kullanıcıyı dışla
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final supplies = snapshot.data!.docs.where((doc) {
                  if (selectedCategory == 'All') return true;
                  return doc['industry'] == selectedCategory;
                }).toList();

                if (buttonStates.length != supplies.length) {
                  buttonStates = List<String>.filled(supplies.length, 'Apply');
                }

                return ListView.builder(
                  itemCount: supplies.length,
                  itemBuilder: (context, index) {
                    final supply = supplies[index];
                    final userId = supply['userId'] ?? '';

                    return FutureBuilder<String>(
                      future: getUserName(userId),
                      builder: (context, userSnapshot) {
                        final advertiserName =
                            userSnapshot.data ?? 'Loading...';
                        return Card(
                          margin:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: ListTile(
                            title: Text(
                              supply['supplyName'] ?? '',
                              style: TextStyle(
                                  color: koyuYazi, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Sector: ${supply['industry'] ?? ''}\n'
                              'Content: ${supply['supplyContent'] ?? ''}\n'
                              'Advertiser: $advertiserName\n'
                              'Last Date: ${supply['lastDate'] ?? ''}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.share),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "${supply['supplyName']} shared!")),
                                    );
                                    shareSupply(supply
                                        .id); // supplyId tedarik ilanının ID'sidir
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.bookmark_border,
                                      color: acikYazi),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "${supply['supplyName']} saved!")),
                                    );
                                  },
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await applyForSupply(
                                        supply.id, context); // Başvuru yap
                                    setState(() {
                                      buttonStates[index] =
                                          'Applied'; // Buton metnini 'Applied' yap
                                    });
                                  },
                                  child: Text(
                                    buttonStates[index],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: appArkaplan),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Notifications"),
          content: Container(
            width: double.maxFinite,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('userId',
                      isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text("An error occurred: ${snapshot.error}");
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text("No notifications available.");
                }

                final notifications = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification =
                        notifications[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(notification['message'] ?? 'No message'),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    // Arama çubuğunda kullanıcı "clear" butonuna basınca yapılacak işlemler
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = ''; // Sorguyu temizle
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    // Arama çubuğunda geri gitme ikonu
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Arama ekranını kapat
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Kullanıcı arama yaptıktan sonra arama sonuçlarını göster
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('supplies')
          .where('supplyName', isGreaterThanOrEqualTo: query)
          .where('supplyName', isLessThanOrEqualTo: '$query\uf8ff')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        final results = snapshot.data!.docs;

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final supply = results[index];
            return ListTile(
              title: Text(supply['supplyName'] ?? ''),
              subtitle: Text('Sector: ${supply['industry']}'),
              onTap: () {
                // Arama sonuçlarına tıklandığında yapılacak işlemler
                // Örneğin, tıklanan tedarik hakkında detaylı bilgi göstermek
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Kullanıcı yazarken öneriler göstermek
    return buildResults(context);
  }
}
