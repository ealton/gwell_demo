import 'package:flutter/material.dart';

class LoginDialogPanel extends StatefulWidget {
  const LoginDialogPanel({super.key});

  @override
  State<LoginDialogPanel> createState() => _LoginDialogPanelState();
}

class _LoginDialogPanelState extends State<LoginDialogPanel> {
  String _unionId = "";

  @override
  void initState() {
    super.initState();
  }

  void _displaySuccess(String content) {
    final snackBar = SnackBar(content: Center(child: Text(content)));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _onLoginTap() async {
    if (_unionId.isEmpty) {
      _displaySuccess("Missing _unionId");
      return;
    }

    Navigator.pop(context, _unionId);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Sign In"),
      content: TextField(
        decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Enter unionId'),
        onChanged: (content) => _unionId = content,
      ),
      actions: [OutlinedButton(onPressed: _onLoginTap, child: Text("Log In"))],
    );
  }
}
