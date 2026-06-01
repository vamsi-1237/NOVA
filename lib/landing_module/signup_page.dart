import 'package:flutter/material.dart';
import 'package:nova_app/utils/api_caller.dart';
import 'dart:convert';
import 'package:nova_app/routes/routes.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});


  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black87,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(top: 15, left: 10, child: CustomBackButton()),
            Center(
              child: Container(
                width: 550,
                height: 450,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 40),
                child: Form(
                  key: _formKey,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            "Sign up",
                            style: TextStyle(
                              fontSize: 35,
                            )
                        ),
                        SizedBox(height: 40),
                        TextFormField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            labelText: "Username",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value){
                            if(value!.length<5){
                              return "Email field is required";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 30),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Password",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return "Password too short";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                try {
                                  final jsonResp = await ApiCaller.post(
                                    '/signup',
                                    body: {
                                      "username": usernameController.text,
                                      "password": passwordController.text,
                                    },
                                  );

                                  // Some backends return an empty body on success, so only
                                  // decode JSON when there is actually content.
                                  if (jsonResp.trim().isNotEmpty) {
                                    final data = jsonDecode(jsonResp);

                                    if (data is Map && data["error"] != null) {
                                      throw Exception(data["error"]);
                                    }
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Signup successful — please login')),
                                  );

                                  Navigator.of(context).pushNamed(Routes.login);
                                } catch (e) {
                                  final msg = e.toString();
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Signup failed: $msg')));
                                  print("Signup failed: $e");
                                }
                              }
                            },
                            child: SizedBox(
                              width: 80,
                              child: Center(
                                child: Text(
                                  "Sign up",
                                ),
                              ),
                            )
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        )
    );
  }
}

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white10,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(15),
        shape: CircleBorder(),
      ),
      child: Icon(
        Icons.chevron_left,
        size: 30,
      ),
    );
  }
}
