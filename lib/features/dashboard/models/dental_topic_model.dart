class DentalTopicModel {
  final String subject;
  final String topic;
  final List<String> displayQuestions;
  final List<String> searchPhrases;
  final List<String> intentKeywords;
  final Map<String, String>? qaEn; // {q: '', a: ''}
  final Map<String, String>? qaTa; // {q: '', a: ''}
  final String? chatbotAnswerEn;
  final String? chatbotAnswerTa;
  final String safetyLevel;
  final List<String> suggestDoctorVisitIf;

  DentalTopicModel({
    required this.subject,
    required this.topic,
    required this.displayQuestions,
    required this.searchPhrases,
    required this.intentKeywords,
    this.qaEn,
    this.qaTa,
    this.chatbotAnswerEn,
    this.chatbotAnswerTa,
    this.safetyLevel = 'awareness',
    this.suggestDoctorVisitIf = const [],
  });

  factory DentalTopicModel.fromJson(Map<String, dynamic> json) {
    return DentalTopicModel(
      subject: json['subject'] ?? 'General',
      topic: json['topic'] ?? '',
      displayQuestions: List<String>.from(json['display_questions'] ?? []),
      searchPhrases: List<String>.from(json['search_phrases'] ?? []),
      intentKeywords: List<String>.from(json['intent_keywords'] ?? []),
      qaEn: {
        'q': json['qa']?['question_en'] ?? '',
        'a': json['qa']?['answer_en'] ?? '',
      },
      qaTa: {
        'q': json['qa']?['question_ta'] ?? '',
        'a': json['qa']?['answer_ta'] ?? '',
      },
      chatbotAnswerEn: json['chatbot_answer_short']?['en'],
      chatbotAnswerTa: json['chatbot_answer_short']?['ta'],
      safetyLevel: json['safety_level'] ?? 'awareness',
      suggestDoctorVisitIf:
          List<String>.from(json['suggest_doctor_visit_if'] ?? []),
    );
  }

  // Convert Legacy InsightData to this model
  factory DentalTopicModel.fromLegacy(
      String subjectId, Map<String, String> enItem, Map<String, String>? taItem) {
    
    // Subject Mapping to preserve exact original titles
    const titleMap = {
      'dental_tips': 'Daily Dental Tips 🦷',
      'growth_dev': 'Growth & Development 📏',
      'diet_nutrition': 'Diet & Nutrition 🍎',
      'eruption_guide': 'Tooth Eruption 🗓️',
      'emergency_aid': 'First Aid 🚑',
      'abuse_neglect': 'Child Safety 🛡️',
    };

    String readableSubject = titleMap[subjectId] ?? 
        subjectId
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' '); 

    return DentalTopicModel(
      subject: readableSubject,
      topic: enItem['q'] ?? '',
      displayQuestions: [enItem['q'] ?? ''],
      searchPhrases: _generatePhrases(enItem['q'] ?? ''),
      intentKeywords: [],
      qaEn: enItem,
      qaTa: taItem ?? enItem, 
      // Legacy data doesn't have dedicated chatbot short answers, use main answer or substring
      chatbotAnswerEn: enItem['a'], 
      chatbotAnswerTa: taItem?['a'] ?? enItem['a'],
    );
  }

  static List<String> _generatePhrases(String text) {
    // Simple tokenizer for legacy data
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(' ')
        .where((w) => w.length > 3)
        .toList();
  }
}
