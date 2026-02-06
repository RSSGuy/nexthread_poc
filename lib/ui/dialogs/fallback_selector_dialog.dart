/*

import 'dart:convert';
import 'package:flutter/material.dart';

class FallbackSelectorDialog extends StatelessWidget {
  const FallbackSelectorDialog({super.key});

  static Future<String?> show(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      builder: (context) => const FallbackSelectorDialog(),
    );
  }

  // Helper to load and filter assets
  Future<List<String>> _getFeedAssets(BuildContext context) async {
    try {
      // 1. Load the AssetManifest
      final manifestContent = await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      // 2. Filter for files in 'assets/feeds/' that end with .xml
      final feedFiles = manifestMap.keys
          .where((key) => key.startsWith('assets/feeds/') && key.endsWith('.xml'))
          .toList();

      return feedFiles;
    } catch (e) {
      print("Error loading asset manifest: $e");
      return [];
    }
  }

  // Helper to make filenames pretty (e.g. "assets/feeds/modernfarmer.xml" -> "Modern Farmer")
  String _formatTitle(String assetPath) {
    final fileName = assetPath.split('/').last; // "modernfarmer.xml"
    final name = fileName.replaceAll('.xml', ''); // "modernfarmer"

    // Capitalize and replace underscores/hyphens with spaces
    return name
        .replaceAll(RegExp(r'[-_]'), ' ')
        .split(' ')
        .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Fallback Data"),
      content: SizedBox(
        width: double.maxFinite,
        child: FutureBuilder<List<String>>(
          future: _getFeedAssets(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final files = snapshot.data ?? [];

            if (files.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("No feed files found in assets/feeds/"),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              itemCount: files.length,
              separatorBuilder: (ctx, i) => const Divider(),
              itemBuilder: (context, index) {
                final path = files[index];
                final title = _formatTitle(path);

                // Customize icon based on filename keywords
                IconData icon = Icons.description;
                Color color = const Color(0xFF64748B);

                if (path.contains('crisis')) {
                  icon = Icons.warning_amber_rounded;
                  color = const Color(0xFFEF4444);
                } else if (path.contains('farmer')) {
                  icon = Icons.agriculture;
                  color = const Color(0xFF10B981);
                }

                return ListTile(
                  leading: Icon(icon, color: color),
                  title: Text(title),
                  subtitle: Text(path), // Show path as subtitle for clarity
                  onTap: () {
                    Navigator.pop(context, path);
                  },
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}*/

// lib/ui/dialogs/fallback_selector_dialog.dart

import 'dart:convert';
import 'package:flutter/material.dart';

class FallbackSelectorDialog extends StatefulWidget {
  const FallbackSelectorDialog({super.key});

  static Future<List<String>?> show(BuildContext context) async {
    return await showDialog<List<String>>(
      context: context,
      builder: (context) => const FallbackSelectorDialog(),
    );
  }

  @override
  State<FallbackSelectorDialog> createState() => _FallbackSelectorDialogState();
}

class _FallbackSelectorDialogState extends State<FallbackSelectorDialog> {
  final Set<String> _selectedPaths = {};
  late Future<List<String>> _assetsFuture;

  @override
  void initState() {
    super.initState();
    _assetsFuture = _getFeedAssets(context);
  }

  // Helper to load and filter assets
  Future<List<String>> _getFeedAssets(BuildContext context) async {
    try {
      // 1. Load the AssetManifest
      final manifestContent = await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      // 2. Filter for files in 'assets/feeds/' that end with .xml
      final feedFiles = manifestMap.keys
          .where((key) => key.startsWith('assets/feeds/') && key.endsWith('.xml'))
          .toList();

      return feedFiles;
    } catch (e) {
      print("Error loading asset manifest: $e");
      return [];
    }
  }

  // Helper to make filenames pretty
  String _formatTitle(String assetPath) {
    final fileName = assetPath.split('/').last; // "modernfarmer.xml"
    final name = fileName.replaceAll('.xml', ''); // "modernfarmer"

    // Capitalize and replace underscores/hyphens with spaces
    return name
        .replaceAll(RegExp(r'[-_]'), ' ')
        .split(' ')
        .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
        .join(' ');
  }

  void _toggleSelection(String path) {
    setState(() {
      if (_selectedPaths.contains(path)) {
        _selectedPaths.remove(path);
      } else {
        _selectedPaths.add(path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Fallback Data"),
      content: SizedBox(
        width: double.maxFinite,
        child: FutureBuilder<List<String>>(
          future: _assetsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final files = snapshot.data ?? [];

            if (files.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("No feed files found in assets/feeds/"),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              itemCount: files.length,
              separatorBuilder: (ctx, i) => const Divider(),
              itemBuilder: (context, index) {
                final path = files[index];
                final title = _formatTitle(path);
                final isSelected = _selectedPaths.contains(path);

                // Customize icon based on filename keywords
                IconData icon = Icons.description;
                Color color = const Color(0xFF64748B);

                if (path.contains('crisis')) {
                  icon = Icons.warning_amber_rounded;
                  color = const Color(0xFFEF4444);
                } else if (path.contains('farmer')) {
                  icon = Icons.agriculture;
                  color = const Color(0xFF10B981);
                }

                return CheckboxListTile(
                  secondary: Icon(icon, color: color),
                  title: Text(title),
                  subtitle: Text(path, style: const TextStyle(fontSize: 10)),
                  value: isSelected,
                  onChanged: (_) => _toggleSelection(path),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _selectedPaths.isEmpty
              ? null
              : () => Navigator.pop(context, _selectedPaths.toList()),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
          ),
          child: Text("Analyze (${_selectedPaths.length})"),
        ),
      ],
    );
  }
}