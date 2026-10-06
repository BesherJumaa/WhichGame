import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'animationroute.dart';
import 'my_drawer.dart';

class Lot extends StatefulWidget {
  const Lot({super.key});

  @override
  State<Lot> createState() => _LotState();
}

class _LotState extends State<Lot> {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  final ScrollController _scrollController = ScrollController();
  final List<String> _notes = [];
  final Random _random = Random();

  double _fontSize = 45;
  Color _textColor = Colors.white;
  Color _buttonColor = AppColor.primaryColor;

  @override
  void initState() {
    super.initState();
    _addTextField(requestFocus: false);
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _addTextField({bool requestFocus = true}) {
    final controller = TextEditingController();
    final focusNode = FocusNode();

    _controllers.add(controller);
    _focusNodes.add(focusNode);

    if (requestFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        focusNode.requestFocus();
      });
    }
  }

  void _appendTextField() {
    setState(() => _addTextField());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _updateNotes() {
    setState(() {
      _notes
        ..clear()
        ..addAll(_controllers.map((controller) => controller.text));
      _buttonColor = Color(0xFF000000 | _random.nextInt(0x01000000));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: _appendTextField,
          elevation: 10,
          backgroundColor: AppColor.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Icon(Icons.add),
        ),
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        backgroundColor: AppColor.black,
        drawer: MyDrawer(notes: _notes),
        appBar: AppBar(
          title: Center(child: Lottie.asset(AppLinks.appBar, height: 180)),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_forward_outlined),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
          backgroundColor: AppColor.primaryColor,
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ..._controllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;
                final focusNode = _focusNodes[index];

                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    icon: Lottie.asset(AppLinks.game, height: 50, width: 50),
                    hintText: 'Write Your Choice...',
                    labelText: 'Number ${index + 1}',
                  ),
                  onEditingComplete: () {
                    if (index == _controllers.length - 1) {
                      _appendTextField();
                    } else {
                      _focusNodes[index + 1].requestFocus();
                    }
                  },
                );
              }),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: InkWell(
                      focusColor: AppColor.black,
                      hoverColor: AppColor.black,
                      splashColor: AppColor.black,
                      highlightColor: AppColor.black,
                      onTap: _updateNotes,
                      child: Lottie.asset(AppLinks.button, fit: BoxFit.fill),
                    ),
                  ),
                  const Positioned(
                    top: 80,
                    child: Text(
                      'Result',
                      style: TextStyle(
                        color: AppColor.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedContainer(
                decoration: BoxDecoration(
                  color: _buttonColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.all(10),
                duration: const Duration(milliseconds: 500),
                child: AnimatedDefaultTextStyle(
                  style: TextStyle(
                    shadows: const [Shadow(blurRadius: 5)],
                    fontSize: _fontSize,
                    color: _textColor,
                    fontStyle: FontStyle.italic,
                  ),
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOutCubicEmphasized,
                  onEnd: () {
                    if (!mounted) {
                      return;
                    }
                    setState(() {
                      _fontSize = 50;
                      _textColor = AppColor.white;
                    });
                  },
                  child: Text(
                    _notes.isEmpty
                        ? 'Hello'
                        : _notes[_random.nextInt(_notes.length)],
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
