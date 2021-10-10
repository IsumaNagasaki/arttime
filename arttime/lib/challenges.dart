import 'dart:convert';

import 'package:arttime/create_challenge.dart';
import 'package:arttime/model.dart';
import 'package:arttime/view_challenge.dart';
import 'package:flutter/material.dart';
import 'package:arttime/date_ext.dart';
import 'package:arttime/api.dart' as api;
import 'package:http/http.dart' as http;

class Challenges extends StatefulWidget {
  const Challenges({Key? key}) : super(key: key);

  @override
  _ChallengesState createState() => _ChallengesState();
}

class _ChallengesState extends State<Challenges> {
  var week = Week.current();
  List<Challenge> challenges = [];

  void updateChallenges() {
    http.get(Uri.parse("${api.address}/challenge/all")).then((response) async {
      final List<dynamic> list = jsonDecode(response.body)["challenges"];
      setState(() {
        challenges = list
            .map((challenge) =>
                Challenge.fromJson(challenge as Map<String, dynamic>))
            .toList();
      });
    });
  }

  @override
  void initState() {
    updateChallenges();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Challenges"),
          actions: [
            IconButton(
                onPressed: () => updateChallenges(),
                icon: const Icon(Icons.update))
          ],
        ),
        body: Column(
          children: [
            WeekDates((w) => setState(() => week = w),
                (w) => setState(() => week = w)),
            Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                child: Row(
                  children: ["M", "T", "W", "T", "F", "S", "S"]
                      .map((day) => Text(day))
                      .toList(),
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                )),
            Expanded(child: WeekView(challenges, week))
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final title = await Navigator.push(
                context,
                MaterialPageRoute<String>(
                    builder: (context) => const CreateChallenge()),
              );
              if (title != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Challenge created: $title")));
                updateChallenges();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text("Add Challenge")));
  }
}

class WeekDates extends StatefulWidget {
  final void Function(Week week) onPressNext;
  final void Function(Week week) onPressPrevious;
  const WeekDates(this.onPressNext, this.onPressPrevious, {Key? key})
      : super(key: key);

  @override
  _WeekDatesState createState() => _WeekDatesState();
}

class _WeekDatesState extends State<WeekDates> {
  var week = Week.current();

  _WeekDatesState();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
            onPressed: () {
              setState(() => week = week.prev());
              widget.onPressPrevious(week);
            },
            icon: const Icon(Icons.arrow_left)),
        Text("${week.start.formatDate()} - ${week.end.formatDate()}"),
        IconButton(
            onPressed: () {
              setState(() => week = week.next());
              widget.onPressNext(week);
            },
            icon: const Icon(Icons.arrow_right)),
      ],
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }
}

class WeekView extends StatelessWidget {
  final List<Challenge> challenges;
  final Week week;

  const WeekView(this.challenges, this.week, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final widgets = challenges
        .where((challenge) => challenge.isPresentIn(week))
        .map((challenge) => Column(
              children: [
                GestureDetector(
                  child: ChallengeProgress(week, challenge),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChallengeView(challenge)),
                    );
                  },
                ),
                const Divider()
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ))
        .toList();
    return ListView(children: widgets);
  }
}

class ChallengeProgress extends StatelessWidget {
  final Challenge challenge;
  final Week week;

  const ChallengeProgress(this.week, this.challenge, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progressColor = Theme.of(context).colorScheme.primary;
    final int startDay;
    if (challenge.start == null) {
      startDay = 1;
    } else if (week.hasDate(challenge.start!)) {
      startDay = challenge.start!.weekday;
    } else {
      startDay = 1;
    }
    final int endDay;
    if (challenge.end == null) {
      endDay = 7;
    } else if (week.hasDate(challenge.end!)) {
      endDay = challenge.end!.weekday;
    } else {
      endDay = 7;
    }
    const oneDay = 2.0 / 7;
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(oneDay * startDay - 1.0 - oneDay, 0.5),
            end: Alignment(oneDay * endDay - 1.0, 0.5),
            colors: <Color>[progressColor, progressColor],
            tileMode: TileMode.decal,
          ),
        ),
        child: Row(children: [
          Padding(
              padding: const EdgeInsets.all(8.0), child: Text(challenge.title))
        ]));
  }
}
