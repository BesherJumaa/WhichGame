import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'animationroute.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({required this.notes, super.key});

  final List<String> notes;

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  int _selectedTeamCount = 2;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColor.black,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 60),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                ),
                onPressed: () {
                  setState(() => widget.notes.shuffle());
                },
                child: const Text('Split Teams'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: DropdownButton<int>(
                dropdownColor: AppColor.primaryColor,
                hint: const Text('Choose Teams Number'),
                value: _selectedTeamCount,
                items: const [2, 3, 4]
                    .map(
                      (count) => DropdownMenuItem<int>(
                        value: count,
                        child: Text('$count Teams'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() => _selectedTeamCount = value);
                },
              ),
            ),
            if (widget.notes.isNotEmpty)
              ...List.generate(
                _selectedTeamCount,
                (teamIndex) => Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text('Team ${teamIndex + 1} :'),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: (widget.notes.length / _selectedTeamCount)
                          .ceil(),
                      itemBuilder: (context, itemIndex) {
                        final itemsPerTeam =
                            (widget.notes.length / _selectedTeamCount).ceil();
                        final playerIndex =
                            teamIndex * itemsPerTeam + itemIndex;

                        if (playerIndex >= widget.notes.length) {
                          return const SizedBox.shrink();
                        }

                        return Container(
                          margin: const EdgeInsets.only(top: 5),
                          padding: const EdgeInsets.all(5),
                          color: AppColor.primaryColor,
                          child: Row(
                            children: [
                              Lottie.asset(
                                AppLinks.game,
                                height: 35,
                                width: 50,
                              ),
                              const SizedBox(width: 15),
                              Text(
                                widget.notes[playerIndex],
                                style: const TextStyle(
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
