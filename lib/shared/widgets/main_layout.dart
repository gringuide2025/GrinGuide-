import 'package:flutter/material.dart';

import 'app_drawer.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final bool hideAppBar;

  const MainLayout({
    super.key, 
    required this.child, 
    required this.title,
    this.hideAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: hideAppBar ? null : AppBar(
        title: Text(title),
      ),
      drawer: const AppDrawer(),
      body: child,
    );
  }
}
