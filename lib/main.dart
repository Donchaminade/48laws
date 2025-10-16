import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'route_observer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '48 Lois',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark(
          primary: Color.fromARGB(150, 1, 18, 173),
          secondary: Color.fromARGB(255, 1, 4, 156),
          surface: Colors.grey.shade900,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          centerTitle: true,
          titleTextStyle: TextStyle(color: Color.fromARGB(255, 243, 242, 241), fontSize: 20),
        ),
      ),
      home: const SplashScreen(),
      navigatorObservers: [routeObserver],
    );
  }
}
