import 'package:flutter/material.dart';
import '../../core/models.dart';
import '../../core/news_registry.dart';
import '../../core/feed_service.dart';

class FeedTesterScreen extends StatefulWidget {
  const FeedTesterScreen({super.key});

  @override
  State<FeedTesterScreen> createState() => _FeedTesterScreenState();
}

class _FeedTesterScreenState extends State<FeedTesterScreen> {
  final FeedService _feedService = FeedService();

  // State
  bool _isLoading = false;
  List<FeedHealthResult> _results = [];
  Map<String, FeedHealthResult> _resultsMap = {}; // fast lookup

  // Filtering
  bool _showFailingOnly = false;
  String _searchQuery = "";

  // Stats
  int get _total => _results.length;
  int get _success => _results.where((r) => r.isSuccess).length;
  int get _failed => _results.where((r) => !r.isSuccess).length;

  Future<void> _runFullAudit() async {
    setState(() {
      _isLoading = true;
      _results.clear();
      _resultsMap.clear();
    });

    final allSources = NewsRegistry.allSources;

    // Process in batches of 5 to avoid overwhelming network/UI
    const batchSize = 5;
    for (var i = 0; i < allSources.length; i += batchSize) {
      final end = (i + batchSize < allSources.length) ? i + batchSize : allSources.length;
      final batch = allSources.sublist(i, end);

      final futures = batch.map((source) => _feedService.diagnoseFeed(source));
      final batchResults = await Future.wait(futures);

      if (!mounted) return;

      setState(() {
        _results.addAll(batchResults);
        for (var r in batchResults) {
          _resultsMap[r.sourceName] = r;
        }
      });
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Filter logic
    final displayedResults = _results.where((r) {
      if (_showFailingOnly && r.isSuccess) return false;
      if (_searchQuery.isNotEmpty &&
          !r.sourceName.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("RSS Health Check"),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _runFullAudit,
              tooltip: "Run Audit",
            )
        ],
      ),
      body: Column(
        children: [
          _buildStatsHeader(),
          _buildFilterBar(),
          if (_isLoading && _results.isEmpty)
            const Expanded(child: Center(child: CircularProgressIndicator())),
          Expanded(
            child: ListView.separated(
              itemCount: displayedResults.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final res = displayedResults[index];
                return _buildResultTile(res);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      color: Colors.blueGrey.shade50,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("Total", _total.toString(), Colors.black),
          _buildStatItem("Healthy", _success.toString(), Colors.green),
          _buildStatItem("Broken", _failed.toString(), Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String val, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search sources...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          const SizedBox(width: 10),
          FilterChip(
            label: const Text("Errors Only"),
            selected: _showFailingOnly,
            onSelected: (val) => setState(() => _showFailingOnly = val),
            checkmarkColor: Colors.red,
            selectedColor: Colors.red.shade100,
          ),
        ],
      ),
    );
  }

  Widget _buildResultTile(FeedHealthResult res) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: res.isSuccess ? Colors.green.shade100 : Colors.red.shade100,
        child: Icon(
          res.isSuccess ? Icons.check : Icons.error_outline,
          color: res.isSuccess ? Colors.green : Colors.red,
        ),
      ),
      title: Text(res.sourceName, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(res.url, style: const TextStyle(fontSize: 10, color: Colors.grey), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "${res.latencyMs}ms",
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                res.statusMessage,
                style: TextStyle(
                    fontSize: 11,
                    color: res.isSuccess ? Colors.green.shade700 : Colors.red.shade700
                ),
              ),
            ],
          ),
          if (res.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "Error: ${res.error}",
                style: const TextStyle(fontSize: 11, color: Colors.red),
              ),
            ),
        ],
      ),
      trailing: res.isSuccess
          ? Badge(
        label: Text("${res.itemsFound}"),
        backgroundColor: Colors.blue,
      )
          : null,
    );
  }
}