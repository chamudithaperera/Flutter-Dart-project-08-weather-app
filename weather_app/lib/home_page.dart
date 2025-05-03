import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.search, size: 30, color: Colors.black),
              onPressed: () {
                // TODO: Implement search functionality
                print('Search icon pressed');
              },
              tooltip: 'Search',
            ),
          ),
        ],
      ),

      body: Center(child: Text('Home Page')),
    );
  }
}
