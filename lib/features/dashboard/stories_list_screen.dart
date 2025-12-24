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
      StoryModel(
        id: 'crunchy_carrot_1',
        title: 'Crunchy the Carrot 🥕',
        description: 'See how Crunchy cleans sticky sugar off Sam\'s teeth!',
        coverImage: 'assets/images/stories/carrot_poster.png',
        scenes: [
          StoryScene(
            imagePath: 'assets/images/stories/carrot_1.png',
            englishText: 'Meet Crunchy! He is a bright orange carrot with a green leafy hat. He lives in the "Crispy Garden" with his vegetable friends.',
            tamilText: 'கிரஞ்சியை சந்தியுங்கள்! அவர் பச்சை இலைத் தொப்பியுடன் கூடிய பிரகாசமான ஆரஞ்சு நிற கேரட்.',
            englishAudio: 'audio/stories/carrot/English/carrot_en_1.mp3',
            tamilAudio: 'audio/stories/carrot/Tamil/carrot_ta_1.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/carrot_2.png',
            englishText: 'One day, a little boy named Sam was eating sticky toffees. His teeth felt fuzzy and dirty. "Yuck!" said Sam.',
            tamilText: 'ஒரு நாள், சாம் என்ற சிறுவன் மிட்டாய்களை சாப்பிட்டான். அவனது பற்கள் அழுக்காக இருந்தன. "ச்சீ!" என்றான் சாம்.',
            englishAudio: 'audio/stories/carrot/English/carrot_en_2.mp3',
            tamilAudio: 'audio/stories/carrot/Tamil/carrot_ta_2.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/carrot_3.png',
            englishText: 'Crunchy jumped out of the basket! "Don\'t worry, Sam! I have a special power," he said. "Bite me!"',
            tamilText: 'கிரஞ்சி குதித்து வந்தார்! "கவலைப்படாதே சாம்! என்னிடம் ஒரு சிறப்பு சக்தி இருக்கிறது. என்னை கடித்துச் சாப்பிடு!"',
            englishAudio: 'audio/stories/carrot/English/carrot_en_3.mp3',
            tamilAudio: 'audio/stories/carrot/Tamil/carrot_ta_3.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/carrot_4.png',
            englishText: 'CRUNCH! MUNCH! As Sam ate the carrot, Crunchy cleaned the sticky sugar off Sam\'s teeth like a natural toothbrush.',
            tamilText: 'மொறு மொறு! சாம் கேரட்டை சாப்பிட்டபோது, கிரஞ்சி பற்களில் இருந்த சர்க்கரையைச் சுத்தம் செய்தார்.',
            englishAudio: 'audio/stories/carrot/English/carrot_en_4.mp3',
            tamilAudio: 'audio/stories/carrot/Tamil/carrot_ta_4.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/carrot_5.png',
            englishText: '"Wow!" shouted Sam. "My teeth feel strong and clean!" Crunchy winked. "Eat healthy, smile brightly!"',
            tamilText: '"வாவ்!" என்றான் சாம். "என் பற்கள் சுத்தமாக இருக்கின்றன!" கிரஞ்சி கண் சிமிட்டினார்.',
            englishAudio: 'audio/stories/carrot/English/carrot_en_5.mp3',
            tamilAudio: 'audio/stories/carrot/Tamil/carrot_ta_5.mp3',
          ),
        ],
      ),
      StoryModel(
        id: 'dino_habit_1',
        title: 'Dino\'s Big Change 🦖',
        description: 'Dino stops sucking his thumb and learns to breathe right!',
        coverImage: 'assets/images/stories/dino_poster.png',
        scenes: [
          StoryScene(
            imagePath: 'assets/images/stories/dino_1.png',
            englishText: 'Meet Dino the Dinosaur. He is big and green, but he has two small problems. He sucks his thumb and breathes through his mouth!',
            tamilText: 'டைனோ என்ற டைனோசரைச் சந்தியுங்கள். அவர் பெரியவர், ஆனால் அவருக்கு இரண்டு சிறிய பிரச்சினைகள் உள்ளன. அவர் விரல் சூப்புகிறார் மற்றும் வாய் வழியாக சுவாசிக்கிறார்!',
            englishAudio: 'audio/stories/habit/English/habit_en_1.mp3',
            tamilAudio: 'audio/stories/habit/Tamil/habit_ta_1.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/dino_2.png',
            englishText: 'Because of this, Dino’s teeth started to stick out, and his throat felt dry like a desert. He felt tired all the time.',
            tamilText: 'இதனால், டைனோவின் பற்கள் வெளியே துருத்தத் தொடங்கின, அவனது தொண்டை பாலைவனம் போல வறண்டு போனது. அவர் எப்போதும் சோர்வாக இருக்கிறார்.',
            englishAudio: 'audio/stories/habit/English/habit_en_2.mp3',
            tamilAudio: 'audio/stories/habit/Tamil/habit_ta_2.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/dino_3.png',
            englishText: 'Dr. Rabbit looked at Dino\'s teeth. "Stop the thumb! And close your lips! Breathe through your nose for super power."',
            tamilText: 'டாக்டர் ராபிட் டைனோவைப் பார்த்தார். "விரல் வைப்பதை நிறுத்துங்கள்! உதடுகளை மூடுங்கள்! சூப்பர் சக்திக்காக உங்கள் மூக்கு வழியாக சுவாசியுங்கள்."',
            englishAudio: 'audio/stories/habit/English/habit_en_3.mp3',
            tamilAudio: 'audio/stories/habit/Tamil/habit_ta_3.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/dino_4.png',
            englishText: 'It was hard! Dino wanted to suck his thumb, but he hugged his teddy bear instead. He kept his lips zipped tight.',
            tamilText: 'அது கடினமாக இருந்தது! டைனோ விரலைச் சூப்ப விரும்பினான், ஆனால் கரடி பொம்மையைக் கட்டிக்கொண்டான். அவன் உதடுகளை இறுக்கமாக மூடி வைத்திருந்தான்.',
            englishAudio: 'audio/stories/habit/English/habit_en_4.mp3',
            tamilAudio: 'audio/stories/habit/Tamil/habit_ta_4.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/dino_5.png',
            englishText: 'Now Dino breathes through his nose. His teeth are straight, and he can roar loudly again! ROAR!',
            tamilText: 'இப்போது டைனோ மூக்கு வழியாக சுவாசிக்கிறான். அவனது பற்கள் நேராக உள்ளன, அவனால் மீண்டும் சத்தமாக கர்ஜிக்க முடிகிறது! ரோர்!',
            englishAudio: 'audio/stories/habit/English/habit_en_5.mp3',
            tamilAudio: 'audio/stories/habit/Tamil/habit_ta_5.mp3',
          ),
        ],
      ),
      StoryModel(
        id: 'ben_checkup_1',
        title: 'Ben\'s Cool Checkup 🦷',
        description: 'See why Ben loves visiting Dr. Smile\'s clinic!',
        coverImage: 'assets/images/stories/ben_poster.png',
        scenes: [
          StoryScene(
            imagePath: 'assets/images/stories/ben_1.png',
            englishText: 'Ben is nervous. Today is his first visit to Dr. Smile\'s Dental Clinic. He holds his mom\'s hand tightly.',
            tamilText: 'பென் பயப்படுகிறான். இன்று அவனது முதல் பல் மருத்துவமனை வருகை. அவன் அம்மா கையை இறுக்கமாகப் பிடிக்கிறான்.',
            englishAudio: 'audio/stories/ben/English/ben_en_1.mp3',
            tamilAudio: 'audio/stories/ben/Tamil/ben_ta_1.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/ben_2.png',
            englishText: 'Inside, there is a big, colorful chair that looks like a spaceship! "Hop on, Captain Ben!" says Dr. Smile.',
            tamilText: 'உள்ளே ஒரு விண்கலம் போன்ற பெரிய நாற்காலி! "ஏறுங்கள் கேப்டன் பென்!" என்கிறார் டாக்டர்.',
            englishAudio: 'audio/stories/ben/English/ben_en_2.mp3',
            tamilAudio: 'audio/stories/ben/Tamil/ben_ta_2.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/ben_3.png',
            englishText: 'Dr. Smile turns on a bright light. "Open wide like a lion!" Awwwww! Ben opens his mouth big and wide.',
            tamilText: 'டாக்டர் விளக்கை ஏற்றுகிறார். "சிங்கம் போல வாயைத் திறங்கள்!" ஆஆஆ! பென் வாயைத் திறக்கிறான்.',
            englishAudio: 'audio/stories/ben/English/ben_en_3.mp3',
            tamilAudio: 'audio/stories/ben/Tamil/ben_ta_3.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/ben_4.png',
            englishText: 'The doctor counts Ben\'s teeth with a tiny mirror. "One, two, three... perfectly clean!" It tickles a little bit.',
            tamilText: 'டாக்டர் கண்ணாடியால் பற்களை எண்ணுகிறார். "ஒன்று, இரண்டு, மூன்று... மிகச் சுத்தம்!" அது கூச்சமாக இருந்தது.',
            englishAudio: 'audio/stories/ben/English/ben_en_4.mp3',
            tamilAudio: 'audio/stories/ben/Tamil/ben_ta_4.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/ben_5.png',
            englishText: 'Ben hops off the chair. "That was easy!" he says. Dr. Smile gives him a sticker that says \'Super Brusher\'.',
            tamilText: 'பென் குதித்து இறங்கினான். "இது மிகச் சுலபம்!" என்றான். டாக்டர் அவனுக்கு ஒரு ஸ்டிக்கர் கொடுத்தார்.',
            englishAudio: 'audio/stories/ben/English/ben_en_5.mp3',
            tamilAudio: 'audio/stories/ben/Tamil/ben_ta_5.mp3',
          ),
        ],
      ),
      StoryModel(
        id: 'sharing_squirrel_1',
        title: 'The Sharing Squirrel 🐿️',
        description: 'Nutty learns that sharing makes everything better!',
        coverImage: 'assets/images/stories/sharing_poster.png',
        scenes: [
          StoryScene(
            imagePath: 'assets/images/stories/sharing_1.png',
            englishText: 'Nutty the Squirrel had a big pile of shiny acorns. He hugged them tight. "Mine! All mine!" he said.',
            tamilText: 'நட்டி என்ற அணில் ஒரு பெரிய பளபளப்பான அக்ரூட் பருப்புகளை வைத்திருந்தது. அது அவற்றை இறுக்கமாகக் கட்டியணைத்தது. "என்னுடையது! எல்லாம் என்னுடையது!" என்றது.',
            englishAudio: 'audio/stories/sharing/English/sharing_en_1.mp3',
            tamilAudio: 'audio/stories/sharing/Tamil/sharing_ta_1.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/sharing_2.png',
            englishText: 'Little Bird asked, "Can I have one please? I am hungry." Nutty shook his head. "No! Go away!"',
            tamilText: 'சின்னப் பறவை கேட்டது, "தயவுசெய்து எனக்கு ஒன்று கிடைக்குமா? எனக்கு பசிக்கிறது." நட்டி மறுத்தது. "இல்லை! போய்விடு!"',
            englishAudio: 'audio/stories/sharing/English/sharing_en_2.mp3',
            tamilAudio: 'audio/stories/sharing/Tamil/sharing_ta_2.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/sharing_3.png',
            englishText: 'Nutty sat alone. He had many nuts but no friends to play with. He felt sad and lonely.',
            tamilText: 'நட்டி தனியாக அமர்ந்திருந்தது. அதனிடம் நிறைய பருப்புகள் இருந்தன, ஆனால் விளையாட நண்பர்கள் இல்லை. அது வருத்தமாகவும் தனிமையாகவும் உணர்ந்தது.',
            englishAudio: 'audio/stories/sharing/English/sharing_en_3.mp3',
            tamilAudio: 'audio/stories/sharing/Tamil/sharing_ta_3.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/sharing_4.png',
            englishText: 'He saw Little Bird crying. Nutty felt sorry. He gave her a big nut. "Here, let\'s share!"',
            tamilText: 'சின்னப் பறவை அழுவதைப் பார்த்தது. நட்டிக்கு வருத்தமாக இருந்தது. அது அவளுக்கு ஒரு பெரிய பருப்பைக் கொடுத்தது. "இதோ, நாம் பகிர்ந்து கொள்வோம்!"',
            englishAudio: 'audio/stories/sharing/English/sharing_en_4.mp3',
            tamilAudio: 'audio/stories/sharing/Tamil/sharing_ta_4.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/sharing_5.png',
            englishText: 'Little Bird smiled. They played tag together. Nutty learned that sharing brings happiness and friends!',
            tamilText: 'சின்னப் பறவை சிரித்தது. அவர்கள் ஒன்றாக விளையாடினார்கள். பகிர்வது மகிழ்ச்சியையும் நண்பர்களையும் தரும் என்று நட்டி கற்றுக்கொண்டது!',
            englishAudio: 'audio/stories/sharing/English/sharing_en_5.mp3',
            tamilAudio: 'audio/stories/sharing/Tamil/sharing_ta_5.mp3',
          ),
        ],
      ),
      StoryModel(
        id: 'tidy_up_1',
        title: 'Tidy Up Time 🧸',
        description: 'Learning to clean up toys after playing!',
        coverImage: 'assets/images/stories/tidy_poster.png',
        scenes: [
          StoryScene(
            imagePath: 'assets/images/stories/tidy_1.png',
            englishText: 'Leo the Lion loved to play. Blocks, cars, and balls were everywhere! The floor was covered in toys.',
            tamilText: 'லியோ சிங்கத்திற்கு விளையாட மிகவும் பிடிக்கும். பொம்மைகள், கார்கள் மற்றும் பந்துகள் எங்கும் சிதறிக் கிடந்தன! தரை முழுவதும் பொம்மைகளால் நிரம்பியிருந்தது.',
            englishAudio: 'audio/stories/tidy/English/tidy_en_1.mp3',
            tamilAudio: 'audio/stories/tidy/Tamil/tidy_ta_1.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/tidy_2.png',
            englishText: 'Mommy Lion came in. "Oh my! Who will clean this big mess?" Leo looked at his paws. "Not me," he thought.',
            tamilText: 'அம்மா சிங்கம் உள்ளே வந்தார். "ஐயோ! இந்த பெரிய குப்பையை யார் சுத்தம் செய்வார்கள்?" லியோ தன் பாதங்களைப் பார்த்தான். "நான் இல்லை," என்று நினைத்தான்.',
            englishAudio: 'audio/stories/tidy/English/tidy_en_2.mp3',
            tamilAudio: 'audio/stories/tidy/Tamil/tidy_ta_2.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/tidy_3.png',
            englishText: 'But then he tripped on a truck! Ouch! "Okay," Leo said. "I will tidy up so we can be safe."',
            tamilText: 'ஆனால் அப்போது அவன் ஒரு லாரியின் மீது தடுக்கி விழுந்தான்! அம்மா! "சரி," லியோ சொன்னான். "நாங்கள் பாதுகாப்பாக இருக்க நான் சுத்தம் செய்கிறேன்."',
            englishAudio: 'audio/stories/tidy/English/tidy_en_3.mp3',
            tamilAudio: 'audio/stories/tidy/Tamil/tidy_ta_3.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/tidy_4.png',
            englishText: 'Pick up the blocks, one by one. Put them in the box, it is actually fun! Zoom go the cars into the garage.',
            tamilText: 'கட்டைகளை ஒவ்வொன்றாக எடுங்கள். அவற்றை பெட்டியில் போடுங்கள், இது உண்மையில் வேடிக்கையாக இருக்கிறது! கார்கள் கேரேஜுக்குள் "ஜூம்" என்று செல்கின்றன.',
            englishAudio: 'audio/stories/tidy/English/tidy_en_4.mp3',
            tamilAudio: 'audio/stories/tidy/Tamil/tidy_ta_4.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/tidy_5.png',
            englishText: 'Look! The room is clean and big. Leo smiles. "Now I have space to dance!" Good job, Leo!',
            tamilText: 'பார்! அறை சுத்தமாகவும் பெரியதாகவும் இருக்கிறது. லியோ சிரிக்கிறான். "இப்போது எனக்கு நடனமாட இடம் இருக்கிறது!" நன்று லியோ!',
            englishAudio: 'audio/stories/tidy/English/tidy_en_5.mp3',
            tamilAudio: 'audio/stories/tidy/Tamil/tidy_ta_5.mp3',
          ),
        ],
      ),
      StoryModel(
        id: 'brave_butterfly_1',
        title: 'The Brave Little Butterfly 🦋',
        description: 'Bella learns to believe in herself and fly high!',
        coverImage: 'assets/images/stories/butterfly_poster.png',
        scenes: [
          StoryScene(
            imagePath: 'assets/images/stories/butterfly_1.png',
            englishText: 'Bella the Butterfly was small. She was afraid to fly high. "My wings are too tiny," she said.',
            tamilText: 'பெல்லா ஒரு சிறிய வண்ணத்துப்பூச்சி. அவளுக்கு உயரே பறக்க பயம். "என் இறக்கைகள் மிகவும் சிறியவை," என்று அவள் சொன்னாள்.',
            englishAudio: 'audio/stories/butterfly/English/butterfly_en_1.mp3',
            tamilAudio: 'audio/stories/butterfly/Tamil/butterfly_ta_1.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/butterfly_2.png',
            englishText: 'All her friends flew to the top of the big flower. "Come up, Bella!" they called. Bella looked down.',
            tamilText: 'அவளுடைய நண்பர்கள் அனைவரும் பெரிய பூவின் உச்சிக்கு பறந்து சென்றனர். "மேலே வா, பெல்லா!" என்று அவர்கள் அழைத்தார்கள். பெல்லா கீழே பார்த்தாள்.',
            englishAudio: 'audio/stories/butterfly/English/butterfly_en_2.mp3',
            tamilAudio: 'audio/stories/butterfly/Tamil/butterfly_ta_2.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/butterfly_3.png',
            englishText: 'Mama Butterfly said, "Believe in yourself, Bella. You are stronger than you think." Bella took a deep breath.',
            tamilText: 'அம்மா வண்ணத்துப்பூச்சி சொன்னார், "உன்னை நம்பு, பெல்லா. நீ நினைப்பதை விட வலுவானவள்." பெல்லா ஆழமாக மூச்சு விட்டாள்.',
            englishAudio: 'audio/stories/butterfly/English/butterfly_en_3.mp3',
            tamilAudio: 'audio/stories/butterfly/Tamil/butterfly_ta_3.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/butterfly_4.png',
            englishText: 'Flap, flap, flap! She tried hard. Slowly, she went up, up, up! She was flying!',
            tamilText: 'பட பட பட! அவள் கடினமாக முயன்றாள். மெதுவாக, அவள் மேலே, மேலே, மேலே சென்றாள்! அவள் பறந்து கொண்டிருந்தாள்!',
            englishAudio: 'audio/stories/butterfly/English/butterfly_en_4.mp3',
            tamilAudio: 'audio/stories/butterfly/Tamil/butterfly_ta_4.mp3',
          ),
          StoryScene(
            imagePath: 'assets/images/stories/butterfly_5.png',
            englishText: 'She reached the top! "I did it!" Bella cheered. She learned that she can do anything if she tries.',
            tamilText: 'அவள் உச்சியை அடைந்தாள்! "நான் செய்துவிட்டேன்!" என்று பெல்லா உற்சாகப்படுத்தினாள். முயற்சி செய்தால் எதையும் செய்ய முடியும் என்று அவள் கற்றுக்கொண்டாள்.',
            englishAudio: 'audio/stories/butterfly/English/butterfly_en_5.mp3',
            tamilAudio: 'audio/stories/butterfly/Tamil/butterfly_ta_5.mp3',
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
