import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movieapp/style/theme.dart' as Style;
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
                      //color: Colors.black,
                      child: SingleChildScrollView(
                        padding:
                            EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'icons/logo.png',
                            ),
                            SizedBox(height: 10),
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
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                                onPressed: login,
                              ),
                            ),
                            SizedBox(height: 90),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => SignupScreen(),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Text(
                                    "Don't have an Account ?",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                  SizedBox(width: 10),
                                  Hero(
                                    tag: '1',
                                    child: Text(
                                      'Sign up',
                                      style: TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepOrange[200]),
                                    ),
                                  )
                                ],
                              ),
                            )
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

  Future<void> login() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        isloading = true;
      });
      try {
        await _auth.signInWithEmailAndPassword(
            email: _emailEditController.text,
            password: _passwordEditController.text);
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (contex) => HomeScreen(),
          ),
        );
        setState(() {
          isloading = false;
        });
      } on FirebaseAuthException catch (e) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("Login Failed"),
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
        print(e);
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
