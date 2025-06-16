import 'package:flutter/material.dart';

class EmptyStateView extends StatelessWidget {
  final String message;

  const EmptyStateView({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message));
  }
}