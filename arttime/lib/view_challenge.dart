import 'package:arttime/model.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:arttime/date_ext.dart';

class ChallengeView extends StatelessWidget {
  static const double imageHeight = 400;

  final Challenge challenge;

  const ChallengeView(this.challenge, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const bold = TextStyle(fontWeight: FontWeight.bold);
    const normal = TextStyle(fontWeight: FontWeight.normal);
    const topPadding = Padding(padding: EdgeInsets.only(top: 8.0));
    return Scaffold(
        appBar: AppBar(title: Text(challenge.title)),
        body: Column(
          children: [
            SizedBox(
                height: imageHeight,
                child: Stack(
                  children: <Widget>[
                    const Center(child: CircularProgressIndicator()),
                    Center(
                      child: FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        image: challenge.imageUrl,
                      ),
                    ),
                  ],
                )),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      topPadding,
                      Text.rich(
                          TextSpan(style: bold, text: "Author: ", children: [
                        TextSpan(text: challenge.authorContact, style: normal)
                      ])),
                      topPadding,
                      Text.rich(TextSpan(
                          style: bold,
                          text: "Category: ",
                          children: [
                            TextSpan(
                                text: challenge.category.format(),
                                style: normal)
                          ])),
                      topPadding,
                      Text.rich(
                          TextSpan(style: bold, text: "Dates: ", children: [
                        TextSpan(
                          text:
                              "${challenge.start?.formatDate() ?? "no start"} - ${challenge.end?.formatDate() ?? "no end"}",
                          style: normal,
                        ),
                      ])),
                      topPadding,
                      Text(challenge.description)
                    ],
                  )
                ]))
          ],
        ));
  }
}
