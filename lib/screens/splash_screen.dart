import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../main.dart';
import '../../api/apis.dart';
import 'auth/login_screen.dart';
import 'home_screen.dart';

//splash screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Start animation
    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      //exit full-screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          statusBarColor: Colors.white));

      log('\nUser: ${APIs.auth.currentUser}');

      //navigate
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => APIs.auth.currentUser != null
              ? const HomeScreen()
              : const LoginScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //initializing media query (for getting device screen size)
    mq = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Stack(
        children: [
          // app logo with animation
          Positioned(
            top: mq.height * .15,
            right: mq.width * .25,
            width: mq.width * .5,
            child: FadeTransition(
              opacity: _animation,
              child: Image.asset('assets/images/SecureTalkLogo.png'),
            ),
          ),

          // styled text at the bottom
          Positioned(
            bottom: mq.height * .1,
            width: mq.width,
            child: const Text(
              'Made by CryptoMates ❤️',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18, // increased font size for better visibility
                fontWeight: FontWeight.bold, // make text bold
                color: Colors.black87,
                letterSpacing: 1.0, // increase letter spacing for aesthetics
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.grey, // shadow color
                    offset: Offset(2.0, 2.0), // shadow offset
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
