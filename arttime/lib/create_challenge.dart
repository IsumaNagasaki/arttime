import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:arttime/model.dart' as model;

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

  @override
  Widget build(BuildContext context) {
    const requiredField = "This is a required field.";
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  _formKey.currentState!.save();
                  if (_formKey.currentState!.validate()) {
                    if (start == null || end == null || start!.isBefore(end!)) {
                      Navigator.pop(context, title);
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
