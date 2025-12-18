import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/insights_data.dart';
import '../models/dental_topic_model.dart';

class DentalAwarenessRepository {
  List<DentalTopicModel> _allTopics = [];
  bool _isLoaded = false;

  // Singleton
  static final DentalAwarenessRepository _instance =
      DentalAwarenessRepository._internal();
  factory DentalAwarenessRepository() => _instance;
  DentalAwarenessRepository._internal();

  Future<void> loadData() async {
    if (_isLoaded) return;
    _allTopics = [];

    // 1. Load Legacy Data
    _loadLegacyData();

    // 2. Load New JSON Data
    await _loadJsonData();

    _isLoaded = true;
  }

  void _loadLegacyData() {
    try {
      final data = InsightData.content;
      data.forEach((key, langMap) {
        final enList = langMap['en'] ?? [];
        final taList = langMap['ta'] ?? [];

        for (int i = 0; i < enList.length; i++) {
          final enItem = Map<String, String>.from(enList[i] as Map);
          Map<String, String>? taItem;
          if (i < taList.length) {
            taItem = Map<String, String>.from(taList[i] as Map);
          }
          
          _allTopics.add(DentalTopicModel.fromLegacy(key, enItem, taItem));
        }
      });
    } catch (e) {
      debugPrint("Error loading legacy data: $e");
    }
  }

  Future<void> _loadJsonData() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/dental_awareness.json');
      final List<dynamic> jsonList = json.decode(response);
      
      final newTopics = jsonList.map((json) => DentalTopicModel.fromJson(json)).toList();
      _allTopics.addAll(newTopics);
    } catch (e) {
      debugPrint("Error loading JSON data: $e");
    }
  }

  List<DentalTopicModel> getAllTopics() {
    return _allTopics;
  }

  List<String> getSubjects() {
    return _allTopics.map((t) => t.subject).toSet().toList();
  }

  List<DentalTopicModel> getTopicsBySubject(String subject) {
    return _allTopics.where((t) => t.subject == subject).toList();
  }

  List<DentalTopicModel> search(String query) {
    if (query.isEmpty) return [];
    
    final q = query.toLowerCase();
    
    // Simple scoring
    return _allTopics.where((topic) {
      // 1. Check Topic Title
      if (topic.topic.toLowerCase().contains(q)) return true;
      
      // 2. Check Display Questions
      if (topic.displayQuestions.any((dq) => dq.toLowerCase().contains(q))) return true;
      
      // 3. Check Search Phrases
      if (topic.searchPhrases.any((phrase) => phrase.contains(q))) return true;

      // 4. Check Keywords (Exact match preferred)
      if (topic.intentKeywords.any((k) => k == q)) return true;

      return false;
    }).toList();
  }
}
