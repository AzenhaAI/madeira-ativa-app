import 'package:flutter/material.dart';

/// Web has no file system: club puzzles are not available there.
class ClubPuzzlesPage extends StatelessWidget {
  const ClubPuzzlesPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(), body: const Center(child: Text('Not available on the web.')));
}
