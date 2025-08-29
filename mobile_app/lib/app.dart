import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/camera_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/history_screen.dart';

class AppScreen extends StatefulWidget {
  final CameraDescription camera;

  const AppScreen({super.key, required this.camera});

  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      CameraScreen(camera: widget.camera),
      const GalleryScreen(),
      const HistoryScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Камера',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Галерея',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'История',
          ),
        ],
      ),
    );
  }
}
