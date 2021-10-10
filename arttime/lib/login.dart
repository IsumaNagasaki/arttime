import 'package:arttime/challenges.dart';
import 'package:flutter/material.dart';
import 'package:arttime/api.dart' as api;
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? username;
  String? password;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(72.0),
            child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Enter your username',
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? "Username can not be empty"
                          : null,
                      onSaved: (text) => setState(() {
                        username = text;
                      }),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Enter your password',
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? "Password can not be empty"
                          : null,
                      onSaved: (text) => setState(() {
                        password = text;
                      }),
                      obscureText: true,
                    ),
                    LoginButton("Login", () async {
                      _formKey.currentState!.save();
                      if (_formKey.currentState!.validate()) {
                        final response = await http
                            .get(Uri.parse("${api.address}/login"), headers: {
                          "Username": username!,
                          "Password": password!
                        });
                        if (response.statusCode == 200) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Challenges()),
                          );
                        } else {
                          showDialog(
                              context: context,
                              builder: (context) => const AlertDialog(
                                    content: Text("User not found"),
                                  ));
                        }
                      }
                    }),
                    LoginButton("Register", () async {
                      _formKey.currentState!.save();
                      if (_formKey.currentState!.validate()) {
                        final response = await http.post(
                            Uri.parse("${api.address}/register"),
                            headers: {
                              "Username": username!,
                              "Password": password!
                            });
                        if (response.statusCode == 200) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Challenges()),
                          );
                        } else {
                          showDialog(
                              context: context,
                              builder: (context) => const AlertDialog(
                                    content: Text("User already exists"),
                                  ));
                        }
                      }
                    })
                  ],
                ))));
  }
}

@immutable
class LoginButton extends StatelessWidget {
  const LoginButton(this.text, this.onPressed, {Key? key}) : super(key: key);

  final String text;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        children: [
          Expanded(
              child: ElevatedButton(
            onPressed: onPressed,
            child: Text(text),
          ))
        ],
        mainAxisSize: MainAxisSize.max,
      ),
    );
  }
}
