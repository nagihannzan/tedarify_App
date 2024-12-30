import 'package:flutter/material.dart';
import 'package:tedarify/renkler.dart';

class Kaydedilenler extends StatefulWidget {
  const Kaydedilenler({Key? key}) : super(key: key);

  @override
  State<Kaydedilenler> createState() => _KaydedilenlerState();
}

class _KaydedilenlerState extends State<Kaydedilenler> {
  List<Map<String, dynamic>> savedSupplies = [
    {
      'name': 'Demir Çubuklar',
      'description': '50 adet demir çubuk hazır',
      'lastDate': '2024-06-30',
      'applied': false,
    },
    {
      'name': 'Pamuk Kumaş',
      'description': '2 ton pamuk kumaş',
      'lastDate': '2024-07-10',
      'applied': false,
    },
    {
      'name': 'Kimyasal Ürün',
      'description': 'Patlayıcı özellikte kimyasal',
      'lastDate': '2024-08-15',
      'applied': false,
    },
  ];

  void _showApplyDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Apply"),
        content: const Text(
            "Applications will be made for this posting. Do you approve?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                savedSupplies[index]['applied'] = true;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Application has been made.")),
              );
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tedArkaplan,
      appBar: AppBar(
        backgroundColor: appArkaplan,
        title: const Text(
          'Saved',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        itemCount: savedSupplies.length,
        itemBuilder: (context, index) {
          final supply = savedSupplies[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(
                supply['name'],
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Description: ${supply['description']}\nLast Date: ${supply['lastDate']}',
              ),
              trailing: ElevatedButton(
                onPressed: supply['applied']
                    ? null
                    : () => _showApplyDialog(context, index),
                child: Text(
                  supply['applied'] ? "Applied" : "Apply",
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: appArkaplan,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
