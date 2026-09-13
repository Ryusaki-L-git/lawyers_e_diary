import 'package:flutter/material.dart';

class AppSnackbar {
  const AppSnackbar._();

  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
