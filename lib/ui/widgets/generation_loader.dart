import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GenerationLoader extends StatefulWidget {
  const GenerationLoader({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // User cannot click outside to close
      builder: (_) => const GenerationLoader(),
    );
  }

  static void hide(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  State<GenerationLoader> createState() => _GenerationLoaderState();
}

class _GenerationLoaderState extends State<GenerationLoader> with SingleTickerProviderStateMixin {
  // Animation Controller
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  // Text Cycling
  int _msgIndex = 0;
  Timer? _textTimer;

  final List<String> _messages = [
    "Establishing Secure Connection...",
    "Fetching Real-Time Market Data...",
    "Scanning Global News Feeds...",
    "Analyzing Sentiment Divergence...",
    "Consulting GPT-4 Logic Engines...",
    "Compiling Strategic Briefing...",
    "Finalizing Intelligence Report..."
  ];

  @override
  void initState() {
    super.initState();

    // 1. Setup Pulsing Animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // 2. Setup Text Cycling (Change message every 3 seconds)
    _textTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _msgIndex = (_msgIndex + 1) % _messages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _textTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back button
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ANIMATED ICON
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF6366F1), width: 2),
                  ),
                  child: const Icon(Icons.grain, size: 32, color: Color(0xFF6366F1)),
                ),
              ),
              const SizedBox(height: 24),

              // CYCLING TEXT
              Text(
                "NEX_THREAD AI",
                style: GoogleFonts.urbanist(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 1.5
                ),
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _messages[_msgIndex],
                  key: ValueKey<int>(_msgIndex),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A)
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // PROGRESS BAR
              const LinearProgressIndicator(
                backgroundColor: Color(0xFFEEF2FF),
                color: Color(0xFF6366F1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}