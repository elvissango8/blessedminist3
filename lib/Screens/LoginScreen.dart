import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mev/main.dart';

import 'SignUpScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        Get.off(() => HomeScreen());
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text('Login', style: TextStyle(color: Colors.lightBlue,fontSize: 36)),
                SizedBox(height: 20,),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email', fillColor: Colors.white, filled: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password', fillColor: Colors.white, filled: true),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,child:   ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                  onPressed: _login,
                  child: Text('Login',style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold)),
                )),
                TextButton(
                  onPressed: () {
                    Get.to(() => SignUpScreen());
                  },
                  child: Text('Dont have an account ? Sign Up', style: TextStyle(color: Colors.red,fontSize: 18))),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
