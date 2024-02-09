import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:whichgame/animationroute.dart';

class MyDrawer extends StatefulWidget {
  final List<String> notes;

  MyDrawer({required this.notes});

  @override
  _MyDrawerState createState() => _MyDrawerState(notes: notes);
}

class _MyDrawerState extends State<MyDrawer> {
  String selectedTeams = '2 Teams';
  final List<String> notes;

  _MyDrawerState({required this.notes});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 60),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    notes.shuffle();
                  });
                },
                child: Text("Split Teams"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: DropdownButton(
                dropdownColor: AppColor.primaryColor,
                hint: Text("Choose Teams Number"),
                items: ["2 Teams", "3 Teams", "4 Teams"]
                    .map((e) => DropdownMenuItem(
                          child: Text("$e"),
                          value: e,
                        ))
                    .toList(),
                onChanged: (String? val) {
                  setState(() {
                    selectedTeams = val!;
                  });
                },
                value: selectedTeams,
              ),
            ),
            if (notes.isNotEmpty)
              ...List.generate(
                int.parse(selectedTeams.split(' ')[0]),
                (index) => Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: AppColor.primaryColor,
                          borderRadius: BorderRadius.circular(30)),
                      child: Text("Team ${index + 1} :"),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: (notes.length /
                              int.parse(selectedTeams.split(' ')[0]))
                          .ceil(),
                      itemBuilder: (context, i) {
                        int playerIndex = index *
                                ((notes.length /
                                        int.parse(selectedTeams.split(' ')[0]))
                                    .ceil()) +
                            i;
                        if (playerIndex >= notes.length) {
                          return SizedBox();
                        }
                        return Container(
                          margin: EdgeInsets.only(top: 5),
                          padding: EdgeInsets.all(5),
                          color: AppColor.primaryColor,
                          child: Row(
                            children: [
                              Lottie.asset(AppLinks.game,
                                  height: 35, width: 50),
                              SizedBox(width: 15),
                              Text(
                                "${notes[playerIndex]}",
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
