
/*

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ui/screens/dashboard_screen.dart';
import 'core/storage_service.dart'; // IMPORT STORAGE

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive (This is CRITICAL for persistent storage)
  await StorageService.init();

  runApp(const NexThreadApp());
}

class NexThreadApp extends StatelessWidget {
  const NexThreadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexThread POC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF1F5F9), // Slate-100
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Indigo
          primary: const Color(0xFF6366F1),
          secondary: const Color(0xFF10B981), // Emerald
          error: const Color(0xFFEF4444), // Rose
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const DashboardScreen(),
    );
  }
}*/

import 'dart:async'; // REQUIRED for runZonedGuarded
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ui/screens/dashboard_screen.dart';
import 'core/storage_service.dart';
import 'ui/widgets/console_log_widget.dart'; // REQUIRED for ConsoleLogger

void main() async {
  // Capture global errors and prints
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await StorageService.init();

    runApp(const NexThreadApp());
  }, (error, stack) {
    // Catch unhandled async errors
    ConsoleLogger.error("Unhandled Error: $error");
    // Also print to console via root zone to avoid recursion if necessary,
    // but standard print is fine as long as we use isInternal:true in logger
    Zone.root.print("Unhandled Error: $error\n$stack");
  }, zoneSpecification: ZoneSpecification(
    print: (self, parent, zone, line) {
      // 1. Print to standard console (terminal)
      parent.print(zone, line);

      // 2. Send to UI Console Widget
      // We pass isInternal: true to prevent ConsoleLogger from printing again
      // and causing an infinite loop.
      ConsoleLogger.log(line, isInternal: true);
    },
  ));
}

class NexThreadApp extends StatelessWidget {
  const NexThreadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexThread POC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF1F5F9), // Slate-100
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Indigo
          primary: const Color(0xFF6366F1),
          secondary: const Color(0xFF10B981), // Emerald
          error: const Color(0xFFEF4444), // Rose
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const DashboardScreen(),
    );
  }
}