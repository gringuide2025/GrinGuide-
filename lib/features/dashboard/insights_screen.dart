import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'repositories/dental_awareness_repository.dart';
import 'models/dental_topic_model.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final _repository = DentalAwarenessRepository();
  final _searchController = TextEditingController();
  List<DentalTopicModel> _searchResults = [];
  bool _isSearching = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadData() async {
    await _repository.loadData();
    if (mounted) setState(() => _isLoading = false);
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = _repository.search(query);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Parent Insights 💡"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search (e.g., 'bleeding gums', 'braces')",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                  ),
                ),
                
                // Content
                Expanded(
                  child: _isSearching
                      ? _buildSearchResults()
                      : _buildSubjectList(),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(child: Text("No results found."));
    }
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final topic = _searchResults[index];
        return ListTile(
          leading: const Icon(Icons.lightbulb_outline, color: Colors.orange),
          title: Text(topic.topic, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(topic.subject),
            onTap: () {
            // Navigate to detail with this specific topic
            // We can pass the subject and filter, or a new route for single topic
            // For now, let's open the Detail screen for the subject, but maybe highlight??
            // Better: Open Detail screen filtered to this subject, but that lists ALL topics.
            // Let's pass the subject so the user sees related topics too.
            context.push('/dashboard/insights/detail', 
              extra: <String, String>{'title': topic.subject, 'contentId': topic.subject});
          },
        );
      },
    );
  }

  Widget _buildSubjectList() {
    final subjects = _repository.getSubjects();
    // Sort logic? List is based on load order.
    
    // Manual mapping for icons/descriptions if possible, or generic
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.menu_book_rounded, color: Colors.purple),
            title: Text(subject, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () {
              context.push('/dashboard/insights/detail', 
                extra: <String, String>{'title': subject, 'contentId': subject});
            },
          ),
        );
      },
    );
  }
}
