/*
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// --- SERVICE CLASS ---
// Call ConsoleLogger.log("message") from anywhere in your app.
class ConsoleLogger {
  static final ConsoleLogger _instance = ConsoleLogger._internal();
  factory ConsoleLogger() => _instance;
  ConsoleLogger._internal();

  final _logController = StreamController<LogEntry>.broadcast();
  final List<LogEntry> _logs = [];

  Stream<LogEntry> get logStream => _logController.stream;
  List<LogEntry> get history => List.unmodifiable(_logs);

  static void log(String message, {String type = 'info'}) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      message: message,
      type: type,
    );
    _instance._logs.add(entry);
    _instance._logController.add(entry);

    // Also print to standard debug console
    print("[UI-LOG] $message");
  }

  static void error(String message) => log(message, type: 'error');
  static void success(String message) => log(message, type: 'success');
  static void warning(String message) => log(message, type: 'warning');

  static void clear() {
    _instance._logs.clear();
    // Notify by sending a special 'clear' entry or just rely on UI rebuilds
    // For simple stream usage, we might just want to re-emit or handle clears differently.
    // Here we'll just let the UI handle the clear state via a manual setState if needed,
    // or push a "Logs Cleared" message.
    log("Console cleared", type: 'system');
  }
}

class LogEntry {
  final DateTime timestamp;
  final String message;
  final String type; // 'info', 'error', 'success', 'warning', 'system'

  LogEntry({required this.timestamp, required this.message, this.type = 'info'});
}

// --- WIDGET ---

class ConsoleLogWidget extends StatefulWidget {
  final double? height;
  final double? width;
  final Color backgroundColor;

  const ConsoleLogWidget({
    super.key,
    this.height,
    this.width,
    this.backgroundColor = const Color(0xFF1E293B), // Dark Slate
  });

  @override
  State<ConsoleLogWidget> createState() => _ConsoleLogWidgetState();
}

class _ConsoleLogWidgetState extends State<ConsoleLogWidget> {
  final ScrollController _scrollController = ScrollController();
  final List<LogEntry> _displayedLogs = [];
  late StreamSubscription _subscription;
  bool _autoScroll = true;

  @override
  void initState() {
    super.initState();
    // Load history
    _displayedLogs.addAll(ConsoleLogger().history);

    // Listen for new logs
    _subscription = ConsoleLogger().logStream.listen((entry) {
      if (!mounted) return;
      setState(() {
        if (entry.message == "Console cleared" && entry.type == 'system') {
          if (ConsoleLogger().history.length <= 1) {
            _displayedLogs.clear();
          }
        }
        _displayedLogs.add(entry);
      });

      if (_autoScroll) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Color _getColor(String type) {
    switch (type) {
      case 'error': return const Color(0xFFEF4444); // Red
      case 'success': return const Color(0xFF10B981); // Emerald
      case 'warning': return const Color(0xFFF59E0B); // Amber
      case 'system': return const Color(0xFF94A3B8); // Slate Light
      default: return const Color(0xFFE2E8F0); // White/Slate
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.terminal, color: Color(0xFF64748B), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "SYSTEM LOGS",
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _autoScroll ? Icons.arrow_downward : Icons.pan_tool_outlined,
                        size: 16,
                        color: _autoScroll ? const Color(0xFF6366F1) : const Color(0xFF64748B),
                      ),
                      tooltip: "Auto-scroll",
                      onPressed: () => setState(() => _autoScroll = !_autoScroll),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFF64748B)),
                      tooltip: "Clear Logs",
                      onPressed: () {
                        ConsoleLogger.clear();
                        setState(() => _displayedLogs.clear());
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF334155)),

          // Log List
          Expanded(
            child: _displayedLogs.isEmpty
                ? Center(
              child: Text(
                "No logs recorded",
                style: GoogleFonts.urbanist(color: const Color(0xFF475569), fontSize: 13),
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _displayedLogs.length,
              itemBuilder: (context, index) {
                final log = _displayedLogs[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('HH:mm:ss').format(log.timestamp),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          log.message,
                          style: GoogleFonts.robotoMono(
                            fontSize: 12,
                            color: _getColor(log.type),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}*/
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// --- SERVICE CLASS ---
class ConsoleLogger {
  static final ConsoleLogger _instance = ConsoleLogger._internal();
  factory ConsoleLogger() => _instance;
  ConsoleLogger._internal();

  final _logController = StreamController<LogEntry>.broadcast();
  final List<LogEntry> _logs = [];

  Stream<LogEntry> get logStream => _logController.stream;
  List<LogEntry> get history => List.unmodifiable(_logs);

  /// [isInternal] : If true, means this call is coming from the Zone interceptor
  /// (meaning it was already printed to console), so we should NOT print it again.
  static void log(String message, {String type = 'info', bool isInternal = false}) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      message: message,
      type: type,
    );
    _instance._logs.add(entry);
    _instance._logController.add(entry);

    // Only print to real console if this didn't come FROM the real console interceptor
    if (!isInternal) {
      // Use Zone.root.print to ensure we bypass our own interceptor if possible
      Zone.root.print("[UI-LOG] $message");
    }
  }

  static void error(String message) => log(message, type: 'error');
  static void success(String message) => log(message, type: 'success');
  static void warning(String message) => log(message, type: 'warning');

  static void clear() {
    _instance._logs.clear();
    log("Console cleared", type: 'system');
  }
}

class LogEntry {
  final DateTime timestamp;
  final String message;
  final String type;

  LogEntry({required this.timestamp, required this.message, this.type = 'info'});
}

class ConsoleLogWidget extends StatefulWidget {
  final double? height;
  final double? width;
  final Color backgroundColor;

  const ConsoleLogWidget({
    super.key,
    this.height,
    this.width,
    this.backgroundColor = const Color(0xFF1E293B),
  });

  @override
  State<ConsoleLogWidget> createState() => _ConsoleLogWidgetState();
}

class _ConsoleLogWidgetState extends State<ConsoleLogWidget> {
  final ScrollController _scrollController = ScrollController();
  final List<LogEntry> _displayedLogs = [];
  late StreamSubscription _subscription;
  bool _autoScroll = true;

  @override
  void initState() {
    super.initState();
    _displayedLogs.addAll(ConsoleLogger().history);

    _subscription = ConsoleLogger().logStream.listen((entry) {
      if (!mounted) return;
      setState(() {
        if (entry.message == "Console cleared" && entry.type == 'system') {
          if (ConsoleLogger().history.length <= 1) {
            _displayedLogs.clear();
          }
        }
        _displayedLogs.add(entry);
      });

      if (_autoScroll) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Color _getColor(String type) {
    switch (type) {
      case 'error': return const Color(0xFFEF4444);
      case 'success': return const Color(0xFF10B981);
      case 'warning': return const Color(0xFFF59E0B);
      case 'system': return const Color(0xFF94A3B8);
      default: return const Color(0xFFE2E8F0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.terminal, color: Color(0xFF64748B), size: 18),
                    const SizedBox(width: 8),
                    Text("SYSTEM LOGS", style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8), letterSpacing: 1.0)),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(_autoScroll ? Icons.arrow_downward : Icons.pan_tool_outlined, size: 16, color: _autoScroll ? const Color(0xFF6366F1) : const Color(0xFF64748B)),
                      onPressed: () => setState(() => _autoScroll = !_autoScroll),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFF64748B)),
                      onPressed: () {
                        ConsoleLogger.clear();
                        setState(() => _displayedLogs.clear());
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF334155)),
          Expanded(
            child: _displayedLogs.isEmpty
                ? Center(child: Text("No logs recorded", style: GoogleFonts.urbanist(color: const Color(0xFF475569), fontSize: 13)))
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _displayedLogs.length,
              itemBuilder: (context, index) {
                final log = _displayedLogs[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DateFormat('HH:mm:ss').format(log.timestamp), style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFF64748B))),
                      const SizedBox(width: 12),
                      Expanded(child: Text(log.message, style: GoogleFonts.robotoMono(fontSize: 12, color: _getColor(log.type)))),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}