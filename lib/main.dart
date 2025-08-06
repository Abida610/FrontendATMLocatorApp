import 'package:dab_app/screens/recommended_atms_screen.dart';
import 'package:flutter/material.dart';
import 'package:dab_app/screens/home_map_screen.dart';
import 'package:dab_app/screens/location_screen.dart';
import 'package:dab_app/screens/navigation_screen.dart';
import 'package:dab_app/screens/complaint_form_screen.dart';

void main(){

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.indigo, // Sets the primary color (e.g., AppBar, buttons)
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black), // Default body text color
          bodyMedium: TextStyle(color: Colors.black), // Default secondary text color
          bodySmall: TextStyle(color: Colors.black), // Default AppBar title color
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.indigo,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20), // White text for contrast
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.transparent, // Background color for text fields
          labelStyle: TextStyle(color: Colors.indigo), // Label text color
          hintStyle: TextStyle(color: Colors.white70), // Hint text color

        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo, // Button background color
            foregroundColor: Colors.white, // Text/icon color on button
          ),
        ),

      ),
      title: 'Recommandation de DAB',
      initialRoute: '/',
      routes: {
        '/': (context) => SplashLocationScreen(),
        '/home_map': (context) => HomeMapScreen(),
        '/recommandation':(context) => RecommendedATMsScreen(),
        '/navigation': (context) => NavigationScreen(),
        '/complaints': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return ComplaintFormScreen(atmId: args['atmId']);
        }
      }
    );
  }
}
