import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'repositories/dental_awareness_repository.dart';

import 'models/category_meta.dart';
import 'models/dental_topic_model.dart';

class InsightDetailScreen extends StatefulWidget {
  final String title;
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
    final meta = CategoryMeta.mapping[widget.contentId];
    final topics = _repository.getTopicsByCategory(widget.contentId);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final themeColor = meta?.gradient.last ?? Colors.purple;
    final themeGradient = meta?.gradient ?? [Colors.purple.shade300, Colors.purple];

    if (topics.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)), 
        body: const Center(child: Text("Content not found or loading..."))
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.05),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Column(
        children: [
          // Custom Premium Header
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 15),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.transparent : Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).iconTheme.color),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                        letterSpacing: -0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Tamil Toggle
                  GestureDetector(
                    onTap: () => setState(() => _isTamil = !_isTamil),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: themeColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "தமிழ்", 
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: themeColor
                            )
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 32,
                            height: 18,
                            child: Switch(
                              value: _isTamil,
                              onChanged: (val) => setState(() => _isTamil = val),
                              activeColor: themeColor,
                              activeTrackColor: themeColor.withOpacity(0.3),
                              inactiveThumbColor: Colors.grey.shade400,
                              inactiveTrackColor: isDark ? Colors.white10 : Colors.grey.shade200,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: topics.length,
              separatorBuilder: (c, i) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
            final topicModel = topics[index];
            
            final qaMap = _isTamil ? topicModel.qaTa : topicModel.qaEn;
            final question = qaMap?['q'] ?? topicModel.topic;
            final answer = qaMap?['a'] ?? "No content available.";
            
            final img = qaMap?['img'];
            final video = qaMap?['video'];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border(
                  left: BorderSide(color: themeColor, width: 6),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.transparent : Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      meta?.icon ?? Icons.help_outline_rounded,
                      color: themeColor,
                      size: 20,
                    ),
                  ),
                    title: Text(
                    question, 
                    style: TextStyle(
                      fontWeight: FontWeight.w700, 
                      // color: Colors.black.withOpacity(0.85), // REMOVED hardcoded color
                      fontSize: 15,
                    )
                  ),
                  iconColor: themeColor,
                  collapsedIconColor: themeColor.withOpacity(0.5),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          if (img != null && img.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(img, fit: BoxFit.cover),
                              ),
                            ),
                          Text(
                            answer.replaceAll('👉 ', '').replaceAll('💡 ', ''),
                            style: TextStyle(
                              fontSize: 15, 
                              height: 1.6, 
                              // color: Colors.black.withOpacity(0.7), // REMOVED hardcoded color
                            ),
                          ),
                          if (video != null && video.isNotEmpty)
                             Padding(
                               padding: const EdgeInsets.only(top: 16),
                               child: InkWell(
                                 onTap: () {
                                   final uri = Uri.parse(video);
                                   canLaunchUrl(uri).then((can) {
                                     if(can) launchUrl(uri, mode: LaunchMode.externalApplication);
                                   });
                                 },
                                 child: Container(
                                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                   decoration: BoxDecoration(
                                     gradient: LinearGradient(colors: themeGradient),
                                     borderRadius: BorderRadius.circular(12),
                                   ),
                                   child: Row(
                                     mainAxisSize: MainAxisSize.min,
                                     children: const [
                                       Icon(Icons.play_circle_fill, color: Colors.white, size: 20),
                                       SizedBox(width: 8),
                                       Text(
                                         "Watch Video 📺", 
                                         style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                                       ),
                                     ],
                                   ),
                                 ),
                               ),
                             )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
            ),
          ),
        ],
      ),
     ),
    );
  }
}


