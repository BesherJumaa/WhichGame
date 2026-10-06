import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'animationroute.dart';
import 'lot.dart';

void main() {
  runApp(const WhichGameApp());
}

class WhichGameApp extends StatelessWidget {
  const WhichGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Which Game?',
      debugShowCheckedModeBanner: false,
      routes: {
        'lot': (context) => const Lot(),
        'Main': (context) => const DicePage(),
      },
      home: const DicePage(),
    );
  }
}

class DicePage extends StatefulWidget {
  const DicePage({super.key});

  @override
  State<DicePage> createState() => _DicePageState();
}

class _DicePageState extends State<DicePage> {
  final Random _random = Random();

  int _leftDiceNumber = 0;
  final int _minNumber = 17;
  final int _maxNumber = 26;
  bool _isGeneralTeams = false;
  String _modeText = 'Turn on to choose between CS & General & BattleField';
  String _teamsText = 'Turn on to choose Teams in GENERAL ';
  bool _valueSwitch = false;
  bool _isStarted = false;
  Color _resultColor = AppColor.white;
  double _size = 400;

  void _changeDiceFace() {
    _leftDiceNumber = _random.nextInt(11) + 1;
  }

  Color _nextRandomColor() {
    return Color(0xFF000000 | _random.nextInt(0x01000000));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.secondColor,
        onPressed: () {
          Navigator.of(context).push(SlideRight<void>(page: const Lot()));
        },
        child: Lottie.asset(AppLinks.floating),
      ),
      backgroundColor: AppColor.white,
      appBar: AppBar(
        title: const Text(
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
              const Divider(color: AppColor.white),
              SwitchListTile(
                controlAffinity: ListTileControlAffinity.trailing,
                secondary: Lottie.asset(AppLinks.play),
                title: Center(
                  child: Text(
                    _modeText,
                    style: const TextStyle(
                      color: AppColor.primaryColor,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                activeThumbColor: AppColor.primaryColor,
                value: _valueSwitch,
                onChanged: (value) {
                  setState(() {
                    _resultColor = _nextRandomColor();
                    _valueSwitch = value;
                    _modeText = value
                        ? 'Turn off to choose between All Games'
                        : 'Turn on to choose between CS & General & BattleField';
                  });
                },
              ),
              const Divider(color: AppColor.black, thickness: 0.8),
              AnimatedContainer(
                color: AppColor.primaryColor,
                duration: const Duration(seconds: 1),
                height: _size,
                width: _size,
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.secondColor,
                      maximumSize: Size(_size, _size),
                    ),
                    onPressed: _handlePrimaryTap,
                    onLongPress: _handleLongPress,
                    child: Center(
                      child: !_isStarted
                          ? Lottie.asset(AppLinks.start)
                          : DecoratedBox(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.scaleDown,
                                  image: AssetImage(
                                    'images/Dice$_leftDiceNumber.png',
                                  ),
                                ),
                              ),
                              child: const SizedBox.expand(),
                            ),
                    ),
                  ),
                ),
              ),
              const Divider(color: AppColor.black, thickness: 0.8),
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.trailing,
                secondary: Lottie.asset(AppLinks.game),
                title: Center(
                  child: Text(
                    _teamsText,
                    style: const TextStyle(
                      color: AppColor.primaryColor,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                value: _isGeneralTeams,
                onChanged: (value) {
                  setState(() {
                    _isGeneralTeams = value ?? false;
                    _teamsText = _isGeneralTeams
                        ? 'Turn off to choose between All Games'
                        : 'Turn on to choose Teams in GENERAL ';
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handlePrimaryTap() {
    setState(() {
      _resultColor = _nextRandomColor();
      _isStarted = true;

      if (_isGeneralTeams) {
        _size = 340;
        _leftDiceNumber =
            _minNumber + _random.nextInt(_maxNumber - _minNumber + 1);
      } else if (_valueSwitch) {
        _size = 360;
        _leftDiceNumber = _random.nextInt(3) + 1;
      } else {
        _changeDiceFace();
        _size = 420;
        _modeText = 'Turn on to choose between CS and General';
      }
    });

    if (_leftDiceNumber == 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColor.primaryColor,
          content: Row(
            children: [
              Lottie.asset(AppLinks.play, height: 70, width: 70),
              const SizedBox(width: 20),
              AnimatedDefaultTextStyle(
                style: TextStyle(
                  shadows: const [Shadow(blurRadius: 5)],
                  color: _resultColor,
                  fontStyle: FontStyle.italic,
                ),
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOutCubicEmphasized,
                child: const Text('Yes!!! General Lets Go'),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(label: 'Undo', onPressed: () {}),
        ),
      );
    }
  }

  void _handleLongPress() {
    setState(() {
      _isStarted = true;
      _leftDiceNumber = _random.nextInt(5) + 12;
    });
  }
}
