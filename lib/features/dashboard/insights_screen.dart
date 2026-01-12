import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'repositories/dental_awareness_repository.dart';
import 'models/dental_topic_model.dart';

import 'models/category_meta.dart';

class InsightsScreen extends StatefulWidget {
  final TextEditingController? searchController;
  const InsightsScreen({super.key, this.searchController});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final _repository = DentalAwarenessRepository();
  late final TextEditingController _searchController;
  List<DentalTopicModel> _searchResults = [];
  bool _isSearching = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController = widget.searchController ?? TextEditingController();
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
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchResults = [];
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isSearching = true;
        _searchResults = _repository.search(query);
      });
    }
  }

  @override
  void dispose() {
    if (widget.searchController == null) {
      _searchController.dispose();
    } else {
      _searchController.removeListener(_onSearchChanged);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: _isSearching
              ? _buildSearchResults()
              : _buildCategoryGrid(),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(child: Text("No results found."));
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final topic = _searchResults[index];
        final meta = CategoryMeta.mapping[topic.categoryKey];
        
        return ListTile(
          leading: Icon(
            meta?.icon ?? Icons.lightbulb_outline, 
            color: meta?.gradient.last ?? Colors.orange
          ),
          title: Text(topic.topic, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(meta?.title ?? topic.subject),
          onTap: () {
            context.push('/dashboard/insights/detail', 
              extra: <String, String>{
                'title': meta?.title ?? topic.subject, 
                'contentId': topic.categoryKey
              });
          },
        );
      },
    );
  }

  Widget _buildCategoryGrid() {
    final categoryKeys = _repository.getSubjects();
    
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: categoryKeys.length,
      itemBuilder: (context, index) {
        final key = categoryKeys[index];
        final meta = CategoryMeta.mapping[key];
        
        // Fallback for missing meta
        final title = meta?.title ?? key.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
        final icon = meta?.icon ?? Icons.menu_book_rounded;
        final colors = meta?.gradient ?? [Colors.grey.shade300, Colors.grey.shade500];

        return InkWell(
          onTap: () {
            context.push('/dashboard/insights/detail', 
              extra: <String, String>{'title': title, 'contentId': key});
          },
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: colors.last.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 36, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


