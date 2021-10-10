import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:arttime/model.dart' as model;
import 'package:arttime/api.dart' as api;
import 'package:http/http.dart' as http;

class CreateChallenge extends StatefulWidget {
  const CreateChallenge({Key? key}) : super(key: key);

  @override
  _CreateChallengeState createState() => _CreateChallengeState();
}

String? validateDate(String? value) =>
    (value == null || value.isEmpty || DateTime.tryParse(value) != null)
        ? null
        : "Invalid date";

class _CreateChallengeState extends State<CreateChallenge> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String title = "";
  String author = "";
  String imageUrl = "";
  String description = "";
  model.Category category = model.Category.single;
  DateTime? start;
  DateTime? end;

  Future<bool> submitChallenge() async {
    final challenge = model.Challenge(
        title, description, imageUrl, author, category,
        start: start, end: end);
    final response = await http.post(Uri.parse("${api.address}/challenge/add"),
        body: jsonEncode(challenge.toJson()));
    return response.statusCode == 200;
  }

  @override
  Widget build(BuildContext context) {
    const requiredField = "This is a required field.";
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () async {
                  _formKey.currentState!.save();
                  if (_formKey.currentState!.validate()) {
                    if (start == null || end == null || start!.isBefore(end!)) {
                      if (await submitChallenge()) {
                        Navigator.pop(context, title);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Failed to submit challenge.")));
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                              Text("Start date should be before end date.")));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Challlenge contains invalid data.")));
                  }
                },
                icon: const Icon(Icons.check))
          ],
          title: const Text("New challenge"),
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.always,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                              hintText: "Input event title",
                              labelText: "Title *"),
                          validator: (value) => (value == null || value.isEmpty)
                              ? requiredField
                              : null,
                          onSaved: (value) =>
                              setState(() => title = value ?? ""),
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                              hintText:
                                  "Input author contact (twitter, email, etc.)",
                              labelText: "Author *"),
                          validator: (value) => (value == null || value.isEmpty)
                              ? requiredField
                              : null,
                          onSaved: (value) =>
                              setState(() => author = value ?? ""),
                        ),
                        Row(children: [
                          const Text("Category: "),
                          const Padding(padding: EdgeInsets.only(left: 8.0)),
                          DropdownButton<model.Category>(
                              value: category,
                              onChanged: (c) => setState(() => category = c!),
                              items: model.categoryValues
                                  .map((c) => DropdownMenuItem(
                                      value: c, child: Text(c.format())))
                                  .toList())
                        ]),
                        TextFormField(
                          decoration: const InputDecoration(
                              hintText: "Valid image web url",
                              labelText: "Image Url *"),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return requiredField;
                            } else if (!(Uri.tryParse(value)?.hasAbsolutePath ??
                                false)) {
                              return "Invalid URL";
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) =>
                              setState(() => imageUrl = value ?? ""),
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                              hintText: "Date in the form YYYY-MM-DD",
                              labelText: "Start date",
                              icon: Icon(Icons.event)),
                          onSaved: (value) => setState(
                              () => start = DateTime.tryParse(value ?? "")),
                          validator: validateDate,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                              hintText: "Date in the form YYYY-MM-DD",
                              labelText: "End date",
                              icon: Icon(Icons.event)),
                          onSaved: (value) => setState(
                              () => end = DateTime.tryParse(value ?? "")),
                          validator: validateDate,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                              hintText: "Describe the challenge",
                              labelText: "Description"),
                          keyboardType: TextInputType.multiline,
                          minLines: 1,
                          maxLines: 5,
                          onSaved: (value) =>
                              setState(() => description = value ?? ""),
                        ),
                      ],
                    )))));
  }
}
