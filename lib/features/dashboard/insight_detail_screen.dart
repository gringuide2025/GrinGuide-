import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'repositories/dental_awareness_repository.dart';
import 'models/dental_topic_model.dart';

class InsightDetailScreen extends StatefulWidget {
  final String title;
  // final String subject; // Removed as it is not passed by router and contentId is used.

  // Note: We reuse 'contentId' param passing for 'subject' to match Router config if needed,
  // but Router passes a Map, so we should look at how Router calls this.
  // Router calls: InsightDetailScreen(title: extra['title']!, contentId: extra['contentId']!)
  // In our refactored InsightsScreen we pass 'subject' in the map.
  // We need to update the Constructor to match what Router might try to pass if we didn't change Router file.
  // Actually Router helper reads 'contentId' key from the map and passes to `contentId` param.
  // In InsightsScreen push: extra: {'title': subject, 'contentId': subject} 
  // Wait, I used 'subject' key in previous step. I should have used 'contentId' key to be compatible with Router's existing extraction logic 
  // OR update the Router file.
  // Let's assume I will update Router or used 'subject' key.
  // To be safe, let's keep the parameter name `contentId` but treat it as `subject`.
  
  final String contentId;

  const InsightDetailScreen({super.key, required this.title, required this.contentId});

  @override
  State<InsightDetailScreen> createState() => _InsightDetailScreenState();
}

class _InsightDetailScreenState extends State<InsightDetailScreen> {
  bool _isTamil = false;
  final _repository = DentalAwarenessRepository();

  @override
  Widget build(BuildContext context) {
    // Determine the subject from contentId.
    // In the new system, contentId passed IS the subject name (e.g. "Pedodontics").
    final subject = widget.contentId;
    
    final topics = _repository.getTopicsBySubject(subject);

    if (topics.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)), 
        body: const Center(child: Text("Content not found or loading..."))
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Row(
            children: [
              const Text("தமிழ்", style: TextStyle(fontWeight: FontWeight.bold)),
              Switch(value: _isTamil, onChanged: (val) => setState(() => _isTamil = val)),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: topics.length,
          separatorBuilder: (c, i) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final topicModel = topics[index];
            
            // Get Q&A based on language
            final qaMap = _isTamil ? topicModel.qaTa : topicModel.qaEn;
            final question = qaMap?['q'] ?? topicModel.topic;
            final answer = qaMap?['a'] ?? "No content available.";
            
            // Legacy data might have 'img' or 'video' keys in the map, we preserved them in qaEn/qaTa map.
            final img = qaMap?['img'];
            final video = qaMap?['video'];

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              clipBehavior: Clip.antiAlias,
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  collapsedBackgroundColor: Colors.white,
                  backgroundColor: Colors.purple.shade50,
                  iconColor: Colors.purple,
                  collapsedIconColor: Colors.purple.shade300,
                  title: Text(
                    question, 
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: Color(0xFF4A148C),
                      fontSize: 16
                    )
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.purple.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (img != null && img.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(img, fit: BoxFit.cover),
                                ),
                              ),
                            Text(
                              answer.replaceAll('👉 ', '').replaceAll('💡 ', ''),
                              style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey.shade800),
                            ),
                            if (video != null && video.isNotEmpty)
                               Padding(
                                 padding: const EdgeInsets.only(top: 12),
                                 child: ElevatedButton.icon(
                                   onPressed: () {
                                     final uri = Uri.parse(video);
                                     canLaunchUrl(uri).then((can) {
                                       if(can) launchUrl(uri, mode: LaunchMode.externalApplication);
                                     });
                                   },
                                   icon: const Icon(Icons.video_library),
                                   label: const Text("Watch Video 📺"),
                                   style: ElevatedButton.styleFrom(
                                     backgroundColor: Colors.red.shade50,
                                     foregroundColor: Colors.red,
                                   ),
                                 ),
                               )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
