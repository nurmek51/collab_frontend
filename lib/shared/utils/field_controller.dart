import 'package:flutter/material.dart';

/// Wrapper for TextEditingController with FocusNode to handle field focusing
class FieldController {
  final TextEditingController textController;
  final FocusNode focusNode;

  FieldController({String? initialText, FocusNode? focusNode})
    : textController = TextEditingController(text: initialText),
      focusNode = focusNode ?? FocusNode();

  String get text => textController.text;
  set text(String value) => textController.text = value;

  void requestFocus() => focusNode.requestFocus();

  void dispose() {
    textController.dispose();
    focusNode.dispose();
  }
}
