import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:whichgame/animationroute.dart';
import 'lot.dart';

void main() {
  return runApp(
    MaterialApp(
      title: "Which Game ? ",
      debugShowCheckedModeBanner: false,
      routes: {
        "lot": (context) => Lot(),
        "Main": (context) => DicePage(),
      },
      home: DicePage(),
    ),
  );
}

class DicePage extends StatefulWidget {
  @override
  _DicePageState createState() => _DicePageState();
}

class _DicePageState extends State<DicePage> {
  int leftDiceNumber = 0;
  int minNumber = 17;
  int maxNumber = 26;
  bool isGeneralTeams = false;
  void ChangeDiceFace() {
    leftDiceNumber = Random().nextInt(11) + 1;
  }

  String text = 'Turn on to choose between CS & General & BattleField';
  String text1 = 'Turn on to choose Teams in GENERAL ';
  var _valslider = 0.5;
  bool valswitch = false;
  bool isStarted = false;
  Color clr = AppColor.white;
  var size = 400.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.secondColor,
        child: Lottie.asset(AppLinks.start),
        onPressed: () {
          Navigator.of(context).push(SlideRight(Page: Lot()));
        },
      ),
      backgroundColor: AppColor.white,
      appBar: AppBar(
        title: Text(
          'Which game i have to play ? ',
          style: TextStyle(color: AppColor.white),
        ),
        backgroundColor: AppColor.primaryColor,
        leading: Lottie.asset(AppLinks.appBar),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Divider(
                color: AppColor.white,
              ),
              SwitchListTile(
                  controlAffinity: ListTileControlAffinity.trailing,
                  secondary: Lottie.asset(AppLinks.play),
                  title: Center(
                    child: Text(
                      '$text',
                      style: TextStyle(
                        color: AppColor.primaryColor,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  activeColor: AppColor.primaryColor,
                  value: valswitch,
                  onChanged: (val) {
                    setState(() {
                      clr = Color(0xFF000000 + Random().nextInt(0xFFFFFF))
                          .withOpacity(1.0);
                      valswitch = val;
                      valswitch
                          ? text = 'Turn off to choose between All Games'
                          : text =
                              'Turn on to choose between CS & General & BattleField';
                    });
                  }),
              Divider(
                color: AppColor.black,
                thickness: 0.8,
              ),
              AnimatedContainer(
                color: AppColor.primaryColor,
                duration: Duration(seconds: 1),
                height: size,
                width: size,
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.secondColor,
                      maximumSize: Size(size, size),
                    ),
                    onPressed: () {
                      setState(
                        () {
                          clr = Color(0xFF000000 + Random().nextInt(0xFFFFFF))
                              .withOpacity(1.0);
                          isStarted = true;
                          if (isGeneralTeams) {
                            size = 340;

                            leftDiceNumber = minNumber +
                                Random().nextInt(maxNumber - minNumber + 1);
                          } else if (valswitch == true) {
                            size = 360;

                            leftDiceNumber = Random().nextInt(3) + 1;
                          } else {
                            ChangeDiceFace();
                            size = 420;
                            text = 'Turn on to choose between CS and General';
                            print(' Button is. $leftDiceNumber .');
                          }
                          ;
                        },
                      );
                      if (leftDiceNumber == 2) {
                        final snackBar = SnackBar(
                          backgroundColor: AppColor.primaryColor,
                          content: Row(
                            children: [
                              Lottie.asset(AppLinks.play,
                                  height: 70, width: 70),
                              SizedBox(
                                width: 20,
                              ),
                              AnimatedDefaultTextStyle(
                                style: TextStyle(
                                  shadows: [Shadow(blurRadius: 5)],
                                  color: clr,
                                  fontStyle: FontStyle.italic,
                                ),
                                duration: Duration(seconds: 1),
                                curve: Curves.easeInOutCubicEmphasized,
                                child: Text(
                                  'Yes!!! General Lets Go',
                                ),
                              ),
                            ],
                          ),
                          duration: Duration(
                              seconds: 3), // Adjust the duration as needed
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              // Perform some action when the "Undo" button is pressed
                              // For example, you can undo the previous action
                            },
                          ),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    },
                    onLongPress: () {
                      setState(
                        () {
                          isStarted = true;
                          leftDiceNumber = Random().nextInt(5) + 12;
                          print(' long Button is. $leftDiceNumber .');
                        },
                      );
                    },
                    child: Center(
                      child: isStarted == false
                          ? Lottie.asset(AppLinks.start)
                          : Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.scaleDown,
                                  image: AssetImage(
                                      'images/Dice$leftDiceNumber.png'),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              Divider(
                color: AppColor.black,
                thickness: 0.8,
              ),
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.trailing,
                secondary: Lottie.asset(AppLinks.game),
                title: Center(
                  child: Text(
                    '$text1',
                    style: TextStyle(
                      color: AppColor.primaryColor,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                value: isGeneralTeams,
                onChanged: (bool? value) {
                  setState(() {
                    isGeneralTeams = value!;
                    isGeneralTeams
                        ? text1 = 'Turn off to choose between All Games'
                        : text1 = 'Turn on to choose Teams in GENERAL ';
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
