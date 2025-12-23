import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'models/story_model.dart';
import '../profile/models/child_model.dart';
import '../profile/profile_controller.dart';

class StoriesListScreen extends ConsumerWidget {
  final ChildModel child;
  const StoriesListScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stories = [
      StoryModel(
        id: 'tommy_story_1',
        title: 'Tommy & The Brush 🪥',
        description: 'Watch the English video adventure of Tommy!',
        coverImage: 'assets/images/stories/tommy_video_poster.png',
        scenes: [
          StoryScene(
            imagePath: 'assets/images/stories/tommy_1.png',
            englishText: 'Hello! Meet Tommy. Tommy is a happy little boy who loves to play all day.',
            tamilText: 'வணக்கம்! டாமியை சந்தியுங்கள். டாமி நாள் முழுவதும் விளையாட விரும்பும் மகிழ்ச்சியான சிறுவன்.',
            englishAudio: 'audio/stories/tommy/English/tommy_en_1.mp3',
            tamilAudio: 'audio/stories/tommy/Tamil/tommy_ta_1.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/tommy_2.png',
            englishText: 'One night, Tommy wanted to sleep without brushing his teeth.',
            tamilText: 'ஒரு இரவு, டாமி பற்களை துலக்காமல் தூங்க நினைத்தான்.',
            englishAudio: 'audio/stories/tommy/English/tommy_en_2.mp3',
            tamilAudio: 'audio/stories/tommy/Tamil/tommy_ta_2.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/tommy_3.png',
            englishText: 'Suddenly, the toothbrush spoke! “Hi Tommy! I’m Mr. Brush. Come on, pick me up and let\'s go for a ride to hunt some sugar monsters!” it said.',
            tamilText: 'அந்த நேரத்தில் பல் துலக்கி பேசத் தொடங்கியது! “வணக்கம் டாமி! நான் மிஸ்டர் பிரஷ். என்னை எடுத்துக்கொள், நாம் சேர்ந்து அந்த சர்க்கரை அரக்கர்களை வேட்டையாடுவோம்!” என்று அது சொன்னது.',
            englishAudio: 'audio/stories/tommy/English/tommy_en_3.mp3',
            tamilAudio: 'audio/stories/tommy/Tamil/tommy_ta_3.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/tommy_4.png',
            englishText: 'Tommy smiled and started brushing his teeth. Up and down… Round and round!',
            tamilText: 'டாமி சிரித்துக்கொண்டு பற்களை துலக்க ஆரம்பித்தான். மேலே… கீழே… சுற்றி சுற்றி!',
            englishAudio: 'audio/stories/tommy/English/tommy_en_4.mp3',
            tamilAudio: 'audio/stories/tommy/Tamil/tommy_ta_4.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/tommy_5.png',
            englishText: 'The naughty germs ran away shouting, “Oh no! Clean teeth!”',
            tamilText: 'தீய கிருமிகள் ஓடிக்கொண்டே கத்தின, “அய்யோ! சுத்தமான பற்கள்!”',
            englishAudio: 'audio/stories/tommy/English/tommy_en_5.mp3',
            tamilAudio: 'audio/stories/tommy/Tamil/tommy_ta_5.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/tommy_6.png',
            englishText: 'After two minutes, Tommy’s teeth were shiny and clean.',
            tamilText: 'இரண்டு நிமிடங்களுக்கு பிறகு, டாமியின் பற்கள் பளிச்சென சுத்தமாக இருந்தன.',
            englishAudio: 'audio/stories/tommy/English/tommy_en_6.mp3',
            tamilAudio: 'audio/stories/tommy/Tamil/tommy_ta_6.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/tommy_7.png',
            englishText: 'From that day on, Tommy brushed every morning and every night!',
            tamilText: 'அந்த நாளிலிருந்து, டாமி தினமும் காலை மற்றும் இரவு பற்களை துலக்கினான்.',
            englishAudio: 'audio/stories/tommy/English/tommy_en_7.mp3',
            tamilAudio: 'audio/stories/tommy/Tamil/tommy_ta_7.mp3',
          ),
        ],
      ),
      StoryModel(
        id: 'sparkle_rescue_1',
        title: 'The Great Sparkle Rescue 🛡️',
        description: 'Help Captain Sparkle save his city from the Sugar Monsters!',
        coverImage: 'assets/images/stories/sparkle_rescue_poster.png',
        scenes: [
          StoryScene(
            imagePath: 'assets/images/stories/sparkle_1.png',
            englishText: 'Welcome to Sparkle City! A beautiful land where every tooth shines like a star. Meet Sparkle, the bravest tooth in the city.',
            tamilText: 'மின்னும் நகரத்திற்கு உங்களை வரவேற்கிறோம்! ஒவ்வொரு பல்லும் நட்சத்திரத்தைப் போல ஜொலிக்கும் அழகான தேசம். இந்த நகரத்தின் துணிச்சலான பல்லான ‘ஸ்பார்கிள்’-ஐச் சந்தியுங்கள்.',
            englishAudio: 'audio/stories/sparkle/English/sparkle_en_1.mp3',
            tamilAudio: 'audio/stories/sparkle/Tamil/sparkle_ta_1.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/sparkle_2.png',
            englishText: 'Oh no! The Sticky Sugar Monsters have arrived. They are covering the city in yellow slime and sticky goo!',
            tamilText: 'ஐயோ! ஒட்டும் சர்க்கரை அரக்கர்கள் வந்துவிட்டனர். அவர்கள் நகரம் முழுவதும் மஞ்சள் நிற அழுக்கையும் ஒட்டும் கழிவுகளையும் பரப்புகிறார்கள்!',
            englishAudio: 'audio/stories/sparkle/English/sparkle_en_2.mp3',
            tamilAudio: 'audio/stories/sparkle/Tamil/sparkle_ta_2.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/sparkle_3.png',
            englishText: 'Sparkle is losing his shine! He feels weak. The Sugar Monsters are laughing because they think they have won.',
            tamilText: 'ஸ்பார்கிள் தனது ஜொலிப்பை இழக்கிறான்! அவன் பலவீனமாக உணர்கிறான். தாங்கள் வெற்றி பெற்றுவிட்டதாக நினைத்து சர்க்கரை அரக்கர்கள் சிரிக்கிறார்கள்.',
            englishAudio: 'audio/stories/sparkle/English/sparkle_en_3.mp3',
            tamilAudio: 'audio/stories/sparkle/Tamil/sparkle_ta_3.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/sparkle_4.png',
            englishText: 'But look! A giant magic toothbrush falls from the sky. It’s the "Brush of Power"! Sparkle needs a hero to pick it up.',
            tamilText: 'ஆனால் பாருங்கள்! வானத்திலிருந்து ஒரு ராட்சத மந்திர பல் துலக்கி விழுகிறது. அதுதான் \'சக்திவாய்ந்த துலக்கி\'! அதை எடுக்க ஸ்பார்கிளுக்கு ஒரு மாவீரன் தேவை.',
            englishAudio: 'audio/stories/sparkle/English/sparkle_en_4.mp3',
            tamilAudio: 'audio/stories/sparkle/Tamil/sparkle_ta_4.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/sparkle_5.png',
            englishText: 'That hero is YOU! Take the brush and move it up and down. Feel the minty bubbles blasting the monsters away!',
            tamilText: 'அந்த மாவீரன் நீங்கள்தான்! துலக்கியை எடுத்து மேலே மற்றும் கீழே நகர்த்துங்கள். புதினா குமிழ்கள் அரக்கர்களைத் தூக்கி எறிவதை உணருங்கள்!',
            englishAudio: 'audio/stories/sparkle/English/sparkle_en_5.mp3',
            tamilAudio: 'audio/stories/sparkle/Tamil/sparkle_ta_5.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/sparkle_6.png',
            englishText: 'Scrub-a-dub-dub! The monsters are running away. "We hate clean teeth!" they scream as they disappear.',
            tamilText: 'நன்கு தேயுங்கள்! அரக்கர்கள் ஓடுகிறார்கள். "சுத்தமான பற்களைக் கண்டால் எங்களுக்குப் பிடிக்காது!" என்று அலறிக்கொண்டே அவர்கள் மறைகிறார்கள்.',
            englishAudio: 'audio/stories/sparkle/English/sparkle_en_6.mp3',
            tamilAudio: 'audio/stories/sparkle/Tamil/sparkle_ta_6.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/sparkle_7.png',
            englishText: 'Look at that shine! Sparkle City is safe again. Thanks to you, every tooth is sparkling bright!',
            tamilText: 'அந்த ஜொலிப்பைப் பாருங்கள்! மின்னும் நகரம் மீண்டும் பாதுகாப்பாக உள்ளது. உங்களுக்கு நன்றி, ஒவ்வொரு பல்லும் பிரகாசமாக மின்னுகிறது!',
            englishAudio: 'audio/stories/sparkle/English/sparkle_en_7.mp3',
            tamilAudio: 'audio/stories/sparkle/Tamil/sparkle_ta_7.mp3',
          ),
        ],
      ),
      StoryModel(
        id: 'floss_island_1',
        title: 'The Treasure of Floss Island 🏝️',
        description: 'Join Captain Floss on a hunt for the legendary shiny pearls!',
        coverImage: 'assets/images/stories/floss_island_poster.png',
        scenes: [
          StoryScene(
            imagePath: 'assets/images/stories/floss_1.png',
            englishText: 'Ahoy, matey! Captain Floss is sailing to the mysterious "Gingival Sea." He is looking for the lost pearls.',
            tamilText: 'அஹோய் மாலுமியே! கேப்டன் பிளாஸ் மர்மமான \'ஜிஞ்சிவல் கடலுக்கு\' (Gingival Sea) பயணம் செய்கிறார். அவர் தொலைந்து போன முத்துக்களைத் தேடுகிறார்.',
            englishAudio: 'audio/stories/floss/English/floss_en_1.mp3',
            tamilAudio: 'audio/stories/floss/Tamil/floss_ta_1.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/floss_2.png',
            englishText: 'But wait! The "Gummy Vines" (food stuck between teeth) have trapped the pearls. We can\'t see them!',
            tamilText: 'ஆனால் சற்று பொறுங்கள்! ஒட்டும் கொடிகள் (பற்களுக்கு இடையில் சிக்கிய உணவு) முத்துக்களைச் சிறைப்பிடித்துள்ளன. நம்மால் அவற்றைப் பார்க்க முடியவில்லை!',
            englishAudio: 'audio/stories/floss/English/floss_en_2.mp3',
            tamilAudio: 'audio/stories/floss/Tamil/floss_ta_2.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/floss_3.png',
            englishText: '"We need the Magic Thread!" shouts the Captain. Only the string can slide between the vines and set the pearls free.',
            tamilText: '"நமக்கு மந்திரக் கயிறு தேவை!" என்று கேப்டன் கத்துகிறார். அந்த நூல் மட்டுமே கொடிகளுக்கு இடையில் நழுவிச் சென்று முத்துக்களை விடுவிக்க முடியும்.',
            englishAudio: 'audio/stories/floss/English/floss_en_3.mp3',
            tamilAudio: 'audio/stories/floss/Tamil/floss_ta_3.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/floss_4.png',
            englishText: 'Up and down... Side to side... The thread works its magic. The pearls are starting to shine again!',
            tamilText: 'மேலே மற்றும் கீழே... பக்கவாட்டில்... மந்திரக் கயிறு தனது வேலையைக் காட்டுகிறது. முத்துக்கள் மீண்டும் ஜொலிக்கத் தொடங்குகின்றன!',
            englishAudio: 'audio/stories/floss/English/floss_en_4.mp3',
            tamilAudio: 'audio/stories/floss/Tamil/floss_ta_4.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/floss_5.png',
            englishText: 'Look! The treasure is revealed! Shiny, white pearls that make the perfect smile for our Captain.',
            tamilText: 'பாருங்கள்! புதையல் கிடைத்துவிட்டது! ஜொலிக்கும் வெள்ளை முத்துக்கள் நமது கேப்டனுக்குச் சிறந்த புன்னகையைத் தருகின்றன.',
            englishAudio: 'audio/stories/floss/English/floss_en_5.mp3',
            tamilAudio: 'audio/stories/floss/Tamil/floss_ta_5.mp3',
          ),
        ],
      ),
      StoryModel(
        id: 'cavity_caution_1',
        title: 'Cavity Caution ⚠️',
        description: 'Watch out! The Driller Monsters are trying to make holes in your teeth!',
        coverImage: 'assets/images/stories/cavity_poster.png',
        scenes: [
          StoryScene(
            imagePath: 'assets/images/stories/cavity_1.png',
            englishText: 'Welcome to the Sweet Forest! It’s full of chocolates, candies, and sticky treats. They look delicious, don’t they?',
            tamilText: 'மிட்டாய் காட்டிற்கு உங்களை வரவேற்கிறோம்! இங்கே சாக்லேட்டுகள், மிட்டாய்கள் மற்றும் ஒட்டும் தின்பண்டங்கள் நிறைந்துள்ளன. அவை சுவையாகத் தெரிகின்றன அல்லவா?',
            englishAudio: 'audio/stories/cavity/English/cavity_en_1.mp3',
            tamilAudio: 'audio/stories/cavity/Tamil/cavity_ta_1.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/cavity_2.png',
            englishText: 'But wait! When we leave the sugar on our teeth, the "Driller Monsters" appear. They love to eat the leftovers.',
            tamilText: 'ஆனால் சற்று பொறுங்கள்! நமது பற்களில் சர்க்கரையை அப்படியே விட்டுவிட்டால், \'துளை போடும் அரக்கர்கள்\' (Driller Monsters) தோன்றுவார்கள். மீதமுள்ள உணவை உண்ண அவர்கள் விரும்புகிறார்கள்.',
            englishAudio: 'audio/stories/cavity/English/cavity_en_2.mp3',
            tamilAudio: 'audio/stories/cavity/Tamil/cavity_ta_2.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/cavity_3.png',
            englishText: 'Look! They are starting to dig tiny black holes called cavities. Ouch! That’s going to hurt later.',
            tamilText: 'பாருங்கள்! அவர்கள் பற்களில் கருப்பான சிறிய துளைகளைத் தோண்டத் தொடங்குகிறார்கள். ஐயோ! இது பிறகு வலியை உண்டாக்கும்.',
            englishAudio: 'audio/stories/cavity/English/cavity_en_3.mp3',
            tamilAudio: 'audio/stories/cavity/Tamil/cavity_ta_3.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/cavity_4.png',
            englishText: 'Quick! We need the "Shield of Foam" (toothpaste) and the "Scrubbing Hero." Let\'s wash those drillers away before they finish!',
            tamilText: 'சீக்கிரம்! நமக்கு நுரை கவசம் (பற்பசை) மற்றும் துலக்கும் மாவீரன் தேவை. அவர்கள் துளையிட்டு முடிப்பதற்குள் அந்த அரக்கர்களைக் கழுவி விரட்டுவோம்!',
            englishAudio: 'audio/stories/cavity/English/cavity_en_4.mp3',
            tamilAudio: 'audio/stories/cavity/Tamil/cavity_ta_4.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/cavity_5.png',
            englishText: 'Great job! No more monsters, and no more holes. Remember: enjoy your sweets, but always brush them away!',
            tamilText: 'சிறப்பான வேலை! இனி அரக்கர்களும் இல்லை, துளைகளும் இல்லை. நினைவில் கொள்ளுங்கள்: மிட்டாய்களைச் சாப்பிடுங்கள், ஆனால் எப்போதும் பற்களைத் துலக்க மறக்காதீர்கள்!',
            englishAudio: 'audio/stories/cavity/English/cavity_en_5.mp3',
            tamilAudio: 'audio/stories/cavity/Tamil/cavity_ta_5.mp3',
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("GrinStories 📖")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.only(bottom: 20),
            elevation: 5,
            child: InkWell(
              onTap: () {
                context.push('/story-player', extra: {'story': story, 'child': child});
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Image.asset(
                        story.coverImage,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black87, Colors.transparent],
                            ),
                          ),
                          child: Text(
                            story.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.description,
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.play_circle_fill, color: Colors.orange, size: 28),
                            const SizedBox(width: 8),
                            Text(
                              "Play Video",
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
