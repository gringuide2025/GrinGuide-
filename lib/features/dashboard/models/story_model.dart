class StoryScene {
  final String imagePath;
  final String englishText;
  final String tamilText;
  final String englishAudio;
  final String tamilAudio;

  StoryScene({
    required this.imagePath,
    required this.englishText,
    required this.tamilText,
    required this.englishAudio,
    required this.tamilAudio,
  });
}

class StoryModel {
  final String id;
  final String title;
  final String description;
  final String coverImage;
  final List<StoryScene> scenes;

  StoryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.coverImage,
    required this.scenes,
  });
}
