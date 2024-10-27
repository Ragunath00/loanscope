import 'package:flutter/material.dart';
class EmiPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EMI Page'),
      ),
      body: const Center(
        child: Text(
          'This is the EMI Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
