import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movieapp/style/theme.dart' as Style;

//import '../constants.dart';
//import 'Login_Screen.dart';
class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _emailEditController = TextEditingController();
  final _passwordEditController = TextEditingController();
  bool isloading = false;
  String passwordPattern = r'^[a-zA-Z0-9]{6,}$';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.Colors.mainColor,
      appBar: AppBar(
        backgroundColor: Style.Colors.mainColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.grey[600],
            size: 30,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isloading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _formKey,
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle.light,
                child: Stack(
                  children: [
                    Container(
                      height: double.infinity,
                      width: double.infinity,
                      child: SingleChildScrollView(
                        padding:
                            EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Hero(
                              tag: '1',
                              child: Image.asset(
                                'icons/logo.png',
                              ),
                            ),
                            SizedBox(height: 30),
                            TextFormField(
                              controller: _emailEditController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) => (value.isEmpty)
                                  ? ' Please enter email'
                                  : null,
                              textAlign: TextAlign.center,
                              decoration: customInputDecoration("Enter email"),
                            ),
                            SizedBox(height: 30),
                            TextFormField(
                              controller: _passwordEditController,
                              obscureText: true,
                              validator: (value) {
                                RegExp regex = RegExp(passwordPattern);
                                if (!regex.hasMatch(value)) {
                                  return 'Password should be in alphanumaric with 6 characters';
                                } else {
                                  return null;
                                }
                              },
                              textAlign: TextAlign.center,
                              decoration:
                                  customInputDecoration("Enter password"),
                            ),
                            SizedBox(height: 80),
                            SizedBox(
                              height: 50,
                              width: 290,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.deepOrange[200],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    )),
                                child: const Text(
                                  "Signup",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                                onPressed: signUp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> signUp() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        isloading = true;
      });
      try {
        await _auth
            .createUserWithEmailAndPassword(
                email: _emailEditController.text,
                password: _passwordEditController.text)
            .then((user) {
          FirebaseFirestore.instance
              .collection("users")
              .doc(_emailEditController.text)
              .set({
            'kullaniciEposta': _emailEditController.text,
            'kullaniciSifre': _passwordEditController.text,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.blueGrey,
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    'The user has been successfully added to the firestore.'),
              ),
              duration: Duration(seconds: 5),
            ),
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.blueGrey,
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Sucessfully Register.You Can Login Now'),
            ),
            duration: Duration(seconds: 5),
          ),
        );
        Navigator.of(context).pop();
        setState(() {
          isloading = false;
        });
      } on FirebaseAuthException catch (e) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Registration Failed'),
            content: Text('${e.message}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text('Okay'),
              )
            ],
          ),
        );
      }
      setState(() {
        isloading = false;
      });
    }
  }

  InputDecoration customInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.teal),
      contentPadding: const EdgeInsets.all(10),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.pink)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.pink)),
      prefixIcon: hint.contains("password")
          ? Padding(
              padding: EdgeInsets.all(0.0),
              child: Icon(
                Icons.password,
                color: Colors.grey,
              ), // icon is 48px widget.
            )
          : Padding(
              padding: EdgeInsets.all(0.0),
              child: Icon(
                Icons.email_outlined,
                color: Colors.grey,
              ), // icon is 48px widget.
            ),
    );
  }
}
