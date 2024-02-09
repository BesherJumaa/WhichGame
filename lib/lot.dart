import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:whichgame/animationroute.dart';
import 'package:whichgame/my_drawer.dart';

class Lot extends StatefulWidget {
  @override
  _LotState createState() => _LotState();
}

class _LotState extends State<Lot> {
  List<TextEditingController> controllers = [];
  // List<FocusNode> focusNodes = [];
  final focusNodes = <FocusNode>[];
  final scrollController = ScrollController();
  List<String> notes = [];
  var fontsize = 45.0;
  var fontdrawer = 14.0;
  Color clr = Colors.white;
  var selectedteams;
  var t = 100.0;
  var r = 100.0;
  int changes = 0, Teams = 2;
  Color buttonColor = AppColor.primaryColor;
  @override
  void initState() {
    addTextField();
    super.initState();
  }

  @override
  void dispose() {
    controllers.forEach((controller) => controller.dispose());

    super.dispose();
  }

  void addTextField() {
    setState(() {
      TextEditingController newController = TextEditingController();
      FocusNode newFocusNode = FocusNode();
      controllers.add(newController);
      focusNodes.add(newFocusNode);
      // Focus on the newly added text field after a short delay
      Timer(Duration(milliseconds: 100), () {
        FocusScope.of(context).requestFocus(newFocusNode);
      });
    });
  }

  void updateNotes() {
    notes.clear();
    controllers.forEach((controller) {
      notes.add(controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              addTextField();
            });
            Future.delayed(Duration(milliseconds: 100), () {
              scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            });
          },
          child: Icon(Icons.add),
          elevation: 10,
          backgroundColor: AppColor.primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        backgroundColor: AppColor.black,
        drawer: MyDrawer(
          notes: notes,
        ),
        appBar: AppBar(
          title: Center(
            child: Lottie.asset(AppLinks.appBar, height: 180),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_forward_outlined),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          backgroundColor: AppColor.primaryColor,
        ),
        body: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display text form fields based on controllers list
              ...controllers.asMap().entries.map((entry) {
                int index = entry.key;
                TextEditingController controller = entry.value;
                FocusNode focusNode = focusNodes[index];
                return FocusScope(
                  node: FocusScopeNode(),
                  child: TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      icon: Lottie.asset(AppLinks.game, height: 50, width: 50),
                      hintText: 'Write Your Choice...',
                      labelText: 'Number ${index + 1}',
                    ),
                    onEditingComplete: () {
                      if (index == controllers.length - 1) {
                        addTextField();
                      } else {
                        focusNode = focusNodes[index + 1];
                        FocusScope.of(context).requestFocus(focusNode);
                      }
                    },
                  ),
                );
              }),

              Container(
                margin: EdgeInsets.only(top: 10),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      updateNotes();
                      buttonColor =
                          Color(0xFF000000 + Random().nextInt(0xFFFFFF))
                              .withOpacity(1.0);
                    });
                  },
                  child: Text('Result'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              // Display result based on notes list
              AnimatedContainer(
                decoration: BoxDecoration(
                    color: buttonColor,
                    borderRadius: BorderRadius.circular(30)),
                padding: EdgeInsets.all(10),
                duration: Duration(milliseconds: 500),
                child: AnimatedDefaultTextStyle(
                  style: TextStyle(
                    shadows: [Shadow(blurRadius: 5)],
                    fontSize: fontsize,
                    color: clr,
                    fontStyle: FontStyle.italic,
                  ),
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOutCubicEmphasized,
                  onEnd: () {
                    setState(() {
                      print("font size before : $fontsize");
                      fontsize = 50.0;
                      print("font size after : $fontsize");
                      // fontsize == 60 ? fontsize = 35 : fontsize == 60;
                      clr = AppColor.white;
                    });
                  },
                  child: Text(
                    notes.isEmpty
                        ? "Hello"
                        : "${notes[Random().nextInt(notes.length)]}",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
