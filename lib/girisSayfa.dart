import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter/material.dart';
import 'package:tedarify/anaAkisSayfa.dart';
import 'package:tedarify/kayitSayfa.dart';
import 'package:tedarify/renkler.dart';

class Girissayfa extends StatefulWidget {
  const Girissayfa({super.key});

  @override
  State<Girissayfa> createState() => _GirissayfaState();
}

class _GirissayfaState extends State<Girissayfa> {
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();
  bool _isLoading = false;

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Login failed: $e',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tedArkaplan,
      appBar: AppBar(
        backgroundColor: appArkaplan,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "TEDARIFY",
              style: TextStyle(
                color: Colors.white,
                fontSize: 47,
              ),
            ),
            Transform.rotate(
              angle: 0.5,
              child: Icon(
                Icons.favorite_border,
                color: Colors.white,
                size: 50,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 
                  Text(
                    'Welcome!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: koyuYazi,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      hintText: 'Enter your email.',
                      prefixIcon: Icon(Icons.person, color: koyuYazi),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Enter your password.',
                      prefixIcon: Icon(Icons.lock, color: koyuYazi),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  _isLoading
                      ? CircularProgressIndicator() 
                      : ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });

                            String email = usernameController.text.trim();
                            String password = passwordController.text.trim();

                            User? user = await signInWithEmailAndPassword(
                                email, password);

                            setState(() {
                              _isLoading = false;
                            });

                            if (user != null) {
                             
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Anaakissayfa()),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appArkaplan,
                            padding: EdgeInsets.symmetric(
                                horizontal: 80, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: Text(
                            'LOG IN',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17),
                          ),
                        ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      print("Forgot password clicked");
                    },
                    child: Text(
                      'I forgot my password.',
                      style: TextStyle(color: Colors.purple[700]),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Don't have an account?",
                    style: TextStyle(color: Colors.purple[700]),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      print("Sign Up clicked");
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Kayitsayfa()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appArkaplan,
                      padding:
                          EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      'SIGN UP',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
