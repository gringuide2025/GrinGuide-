import 'package:flutter/material.dart';
import '../dashboard/repositories/dental_awareness_repository.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'role': 'bot', 'message': 'Hello! I am your GrinGuide Chatbot. \nAsk me anything about dental health! 🦷'}
  ];
  bool _isTyping = false;
  final ScrollController _scrollController = ScrollController();
  final _repository = DentalAwarenessRepository();

  // API Key removed (Offline Mode)
  
  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text.trim();
    setState(() {
      _messages.add({'role': 'user', 'message': userMessage});
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    // Ensure data is loaded
    await _repository.loadData();

    // Simulate thinking delay
    await Future.delayed(const Duration(seconds: 1));

    // Offline Logic (Repo + Shoba Tandon Rules)
    String? botResponse; // _getRepoResponse(userMessage);Disabled for build fix
    botResponse ??= _getBotResponse(userMessage);

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add({'role': 'bot', 'message': botResponse!});
      });
      _scrollToBottom();
    }
}

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String? _getRepoResponse(String input) {
    // Check Repo First
    final results = _repository.search(input);
    if (results.isNotEmpty) {
      // Return the best match's chatbot answer
      // Prioritize exact keyword matches if logic allows, but search() already returns relevant.
      // We pick the first one.
      final match = results.first;
      return match.chatbotAnswerEn ?? match.qaEn?['a'];
    }
    return null;
  }

  String _getBotResponse(String input) {
    final lowerInput = input.toLowerCase();
    
    // --- GREETINGS ---
    if (lowerInput.contains('hello') || lowerInput.contains('hi') || lowerInput.contains('hey') || lowerInput.contains('good morning') || lowerInput.contains('good evening')) {
      return "Hi there! I'm your GrinGuide dental assistant. I can help with:\n\n• Specific conditions (e.g., Abscess, TMJ)\n• Procedures & Costs\n• Child dental care\n• Cosmetic dentistry\n• Emergencies\n\nWhat's on your mind? 😊";
    }
    if (lowerInput.contains('thank') || lowerInput.contains('thx')) {
      return "You're very welcome! Keep smiling! ✨";
    }

    // --- MASTER PEDODONTICS (Priority > All - Shoba Tandon) ---
    // Covers: Habits, Trauma, Caries, Pulp, Space Mgmt, Eruption, Home Care.
    
    // 1. BEHAVIOR MANAGEMENT (Fear/Anxiety in Kids)
    if (lowerInput.contains('scared') || lowerInput.contains('cry') || lowerInput.contains('fear') || lowerInput.contains('refuse') || lowerInput.contains('afraid')) {
         if (lowerInput.contains('kid') || lowerInput.contains('child') || lowerInput.contains('baby') || lowerInput.contains('toddler')) {
             return "It's completely normal for children to feel anxious! 🧸 We use special techniques to help:\n\nFor example, **Tell-Show-Do** involves explaining the tool, showing it on a finger, and then using it. We also use **Voice Control** (calm tones) and distraction with cartoons. You're doing great by supporting them!";
         }
    }

    // 2. ERUPTION & SHEDDING (Timeline) - "Sensitive to single word"
    if (lowerInput.contains('erupt') || lowerInput.contains('come in') || lowerInput.contains('grow') || lowerInput.contains('growing') || lowerInput.contains('new tooth')) {
         return "Curious about those new pearly whites? 🦷\n\n**Baby teeth** usually start arriving around 6 months (bottom front ones first) and complete by age 3 (20 teeth total).\n\n**Permanent teeth** typically start erupting around age 6 with the first molars and lower incisors. Wisdom teeth come much later, around 17-25 years.";
    }
    if (lowerInput.contains('fall out') || lowerInput.contains('lose') || lowerInput.contains('shed') || lowerInput.contains('loose') || lowerInput.contains('wiggle') || lowerInput.contains('wobbly')) {
         return "It sounds like the Tooth Fairy might be visiting soon! 🧚‍♀️\n\nChildren usually start losing front teeth around **6-7 years old**. Canines and molars follow between **9-12 years**.\n\n*Tip:* Let it wiggle out naturally! Don't pull it unless it's barely hanging on.";
    }
    if (lowerInput.contains('teething') || lowerInput.contains('drool') || (lowerInput.contains('chew') && lowerInput.contains('hand'))) {
          return "Teething can be tough on everyone! 👶 You might see drooling or irritability.\n\nTo help, try offering a **chilled (not frozen) teething ring** or gently massaging their gums with a clean finger. Please avoid teething necklaces or numbing gels, as they aren't safe.";
    }

    // 3. HOME CARE & INFANT ORAL HEALTH
    if (lowerInput.contains('infant') || lowerInput.contains('newborn') || lowerInput.contains('gum pad') || (lowerInput.contains('baby') && lowerInput.contains('clean'))) {
          return "Starting early is fantastic! 🍼 For **0-6 months**, simply wipe their gum pads with a clean, damp cloth after feeds.\n\nOnce the first tooth appears, use a **rice-grain-sized** smear of fluoride toothpaste. And don't forget—first dental visit by age 1!";
    }
    if (lowerInput.contains('adolescent') || lowerInput.contains('teen') || lowerInput.contains('puberty')) {
          return "Teen years are critical for a healthy smile! 🎸\n\nWith snacks and soda, the risk for cavities goes up. It's time for them to take charge of flossing every day. Also, keep an eye out for emerging **wisdom teeth** or any sports injuries!";
    }

    // 4. PREVENTIVE & CARIES (ECC, Sealants, Fluoride)
    if (lowerInput.contains('bottle') || lowerInput.contains('nursing') || lowerInput.contains('rot') || lowerInput.contains('black teeth') || lowerInput.contains('decay')) {
          return "This sounds like **Early Childhood Caries**, sometimes called 'Nursing Bottle Rot'. 🍼\n\nIt happens when milk or juice pools around teeth during sleep. To prevent it, try only giving water in the bottle at night and lifting their lip regularly to check for white spots.";
    }
    if (lowerInput.contains('sealant') || lowerInput.contains('pit') || lowerInput.contains('groove') || lowerInput.contains('coating')) {
          return "Think of **Sealants** as a shield for teeth! 🛡️\n\nIt's a painless protective coating painted onto the deep grooves of molars where food gets stuck. It's one of the best ways to prevent cavities in kids.";
    }
    if (lowerInput.contains('fluoride') || lowerInput.contains('varnish')) {
          return "Fluoride is nature's cavity fighter! 💧\n\nFor kids under 3, use a **rice-grain** amount. For 3-6 years, a **pea size**.\n\nYour dentist might also apply a **fluoride varnish** every 6 months to strengthen enamel like armor!";
    }

    // 5. TRAUMA (Avulsion, Fractures) - CRITICAL
    if (lowerInput.contains('knocked') || lowerInput.contains('avuls') || lowerInput.contains('hit') || lowerInput.contains('injury') || lowerInput.contains('trauma')) {
          return "🚨 **Stay Calm, this is Time Sensitive!** 🚨\n\nIs it a **Permanent Tooth**? Replant it immediately if you can, or store it in **MILK**. Go to the dentist NOW (within 60 mins) to save it.\n\nIf it's a **Baby Tooth**, DO NOT put it back in! It could damage the adult tooth growing underneath. See a dentist to check.";
    }
    if (lowerInput.contains('chip') || lowerInput.contains('break') || lowerInput.contains('broken') || lowerInput.contains('fracture') || lowerInput.contains('crack') || lowerInput.contains('ellis')) {
          return "Oh no! A broken tooth? 💔\n\nIf it's just a small chip (Enamel), it might just need smoothing. If it's deeper (Dentin - sensitive to cold) or bleeding (Pulp), it needs urgent treatment.\n\n*Try to find the broken piece and keep it moist in water/milk!*";
    }
    if (lowerInput.contains('intrusion') || lowerInput.contains('pushed in') || (lowerInput.contains('gum') && lowerInput.contains('buried'))) {
          return "This is called **Intrusion** (tooth pushed into gum). 📉\n\nFor baby teeth, they often re-erupt on their own surprisingly! For permanent teeth, we might need to gently move them back. We'll need to watch it closely.";
    }

    // 6. HABITS (Thumb, Mouth breathing)
    if (lowerInput.contains('thumb') || lowerInput.contains('suck') || lowerInput.contains('finger') || lowerInput.contains('pacifier')) {
          return "Thumb sucking is very common! 👍\n\nIt's usually normal until age 3-4. If it continues, it might push teeth forward (Buck teeth). We can use gentle reminders, bitter nail polish, or a special 'Crib' appliance to help break the habit.";
    }
    if (lowerInput.contains('mouth breath') || lowerInput.contains('snore') || lowerInput.contains('open mouth')) {
          return "Breathing through the mouth instead of the nose? 😮\n\nThis can cause 'Long Face', dry lips, and crooked teeth. It's often due to allergies or large tonsils. A visit to an **ENT specialist** might be the best first step!";
    }
    if (lowerInput.contains('tongue') && (lowerInput.contains('thrust') || lowerInput.contains('push'))) {
          return "This is called **Tongue Thrust**. 👅\n\nIt's when the tongue pushes forward during swallowing, which can cause an 'Open Bite'. Speech therapy and a 'Tongue Crib' can help retrain the tongue posture.";
    }

    // 7. PULP THERAPY (Baby Root Canal)
    if (lowerInput.contains('pulpotomy') || lowerInput.contains('baby root') || lowerInput.contains('pulp')) {
          return "We can save that tooth! 💉\n\nA **Pulpotomy** is like a 'Baby Root Canal'. We remove just the infected top part of the nerve to keep the tooth alive until it falls out naturally. It's usually covered with a crown.";
    }
    if (lowerInput.contains('ssc') || lowerInput.contains('silver cap') || lowerInput.contains('stainless') || lowerInput.contains('crown')) {
          return "That's a **Stainless Steel Crown** (SSC)! 👑\n\nIt's like a 'superman suit' for the tooth. It's the strongest way to save a baby molar with a large cavity or after nerve treatment.";
    }
    
    // 8. INTERCEPTIVE ORTHO (Space Mgmt)
    if (lowerInput.contains('space') || lowerInput.contains('gap') || lowerInput.contains('maintainer') || lowerInput.contains('crowd')) {
          return "Managing space is key! 🚧\n\nIf a baby tooth is lost too early, we use a **Space Maintainer** to hold the spot open. If teeth are crowding, early expansion can sometimes prevent the need for braces later!";
    }

    // 9. DEVELOPMENTAL (MIH)
    if (lowerInput.contains('mih') || lowerInput.contains('hypomin') || lowerInput.contains('chalky') || lowerInput.contains('brown spot') || lowerInput.contains('yellow spot')) {
          return "This sounds like **Molar Incisor Hypomineralization (MIH)**. 🧀\n\nIt makes teeth look 'chalky' or brown and be very sensitive because the enamel is soft. We need to protect them with fluoride varnish or sealants ASAP.";
    }

    // General Pedodontics Catch-All (Priority 10)
     if (lowerInput.contains('child') || lowerInput.contains('kid') || lowerInput.contains('baby') || lowerInput.contains('pedodont') || lowerInput.contains('toddler')) {
          return "We love treating little smiles! 🧸\n\nPediatric dentistry focuses on prevention and guiding growth. Whether it's habits, cavities, or just a checkup, we're here to help. What specific question do you have about your child's teeth?";
    }
    
    // --- END PEDO MASTER BLOCK ---

    // --- HIGH PRIORITY SPECIALTIES (Ortho, Endo, Surgery) ---
    // These must be checked first because they often contain "pain" or "child" but need specific answers.

    // Orthodontics
    if (lowerInput.contains('brace') || lowerInput.contains('ortho') || lowerInput.contains('align') || lowerInput.contains('invisalign') || lowerInput.contains('retainer')) {
       if (lowerInput.contains('hurt') || lowerInput.contains('pain')) {
           return "Braces pain is normal after adjustments. 🩹\n\n• Eat soft foods\n• Use orthodontic wax on poking wires\n• Take OTC pain relief\n• Rinse with warm salt water";
       }
       if (lowerInput.contains('lost') && lowerInput.contains('retainer')) {
           return "Lost retainer? Call your ortho ASAP! 🚨\nTeeth can shift back quickly. Don't wait weeks.";
       }
       if (lowerInput.contains('brush') || lowerInput.contains('clean')) {
          return "Brushing with braces: 🪥\n• Angle brush above and below brackets.\n• Use a proxabrush (Christmas tree brush) for between wires.\n• Water flossers help a lot!";
       }
      return "**Orthodontics** straightens teeth! 🦷\n• Braces: 18-24 months avg\n• Invisalign: Clear aligners\n• Retainers: Vital to keep teeth straight forever!";
    }
    
    // Endodontics (Root Canal)
    if (lowerInput.contains('root canal') || lowerInput.contains('endo') || lowerInput.contains('nerve')) {
        if (lowerInput.contains('hurt') || lowerInput.contains('pain')) {
            return "Myth: Root canals hurt. ❌\nFact: They relieve pain! 💉 The procedure is done under anesthesia, similar to a filling. You'll feel better afterwards.";
        }
      return "**Endodontics** saves teeth! 🦷\nNeeded when the nerve is infected. Alternative is extraction (losing the tooth).";
    }

    // Oral Surgery (Wisdom)
    if (lowerInput.contains('surgery') || lowerInput.contains('extract') || lowerInput.contains('wisdom') || lowerInput.contains('removal')) {
       if (lowerInput.contains('pain') || lowerInput.contains('hurt') || lowerInput.contains('swollen')) {
          return "**Post-Op Pain**: 💊\nExpected for 3-4 days. Use ice packs (20 mins on/off) and prescribed meds. If severe pulsing pain starts later, it could be Dry Socket.";
       }
       if (lowerInput.contains('recovery')) {
           return "Wisdom teeth recovery: 3-4 days for basic healing. 🛌 Soft diet (yogurt, soup). Ice packs for swelling.";
       }
       if (lowerInput.contains('dry socket')) { // Specific context check
           return "**Dry Socket Prevention**: 🛑\n• NO straws\n• NO smoking\n• Gentle rinsing only\nClot protection is key!";
       }
      return "**Oral Surgery** includes extractions & implants. 🏥\nFollow post-op instructions carefully to avoid infection!";
    }

    // --- EMERGENCIES & SYMPTOMS ---
    // High priority to catch "Toothache", "Fell out", "Abscess"
    
     if (lowerInput.contains('tooth fell out') || lowerInput.contains('knocked out') || lowerInput.contains('avulsed')) {
        return "🚨 **KNOCKED OUT TOOTH**: TIME CRITICAL!\n1. Handle by crown (white part), NOT root.\n2. Rinse gently if dirty (don't scrub).\n3. Try to put back in socket.\n4. If not, store in **MILK** or cheek.\n5. Get to dentist in <60 mins!";
    }
    if (lowerInput.contains('abscess') || lowerInput.contains('swollen face') || lowerInput.contains('pus')) {
        return "⚠️ **ABSCESS (Infection)**: DANGER!\nSigns: Swelling, pimple on gum, severe pain, fever.\nACTION: See dentist IMMEDIATELY. Infection can spread. Do not wait.";
    }
    if (lowerInput.contains('dry socket')) {
           return "**Dry Socket**: Painful! ⚠️\nBlood clot dislodged after extraction. Exposed bone causes throbbing pain.\nSee dentist for medicated dressing (immediate relief).";
    }
    if (lowerInput.contains('sore') || lowerInput.contains('ulcer') || lowerInput.contains('canker')) {
        return "**Canker Sores**: ⚪\nSmall white ulcers. Painful/Not contagious. Heal in 1-2 weeks. Avoid spicy food. Salt rinse helps.";
    }
     if (lowerInput.contains('pain') || lowerInput.contains('toothache') || lowerInput.contains('hurt')) {
        return "Toothache Remedies (Temp): 💊\n• Ibuprofen/Acetaminophen\n• Warm salt water rinse\n• Clove oil (topical)\n• Cold compress\nSTILL see a dentist to treat the *cause*!";
    }
    if (lowerInput.contains('lost filling') || lowerInput.contains('broken tooth')) {
        return "Lost filling/crown? 🦷\n• Use temporary dental cement (from pharmacy) or sugar-free gum to cover it.\n• See dentist ASAP to prevent further decay.";
    }

    // --- SPECIFIC CONDITIONS ---
    if (lowerInput.contains('impacted')) {
           return "**Impacted Wisdom Teeth**: Stuck in gum/bone. 🛑\nCan cause infection, cysts, or damage neighbors. Usually removed.";
    }
    if (lowerInput.contains('resorption')) {
           return "**Resorption**: Body rejecting the tooth structure. 📉\nCan start from inside (pink spot) or outside. Often requires root canal or extraction.";
    }
    if (lowerInput.contains('hypoplasia') || lowerInput.contains('enamel')) {
           return "**Enamel Hypoplasia**: Thin/weak enamel spots. 🛡️\nGenetic or childhood illness. Keep clean, use fluoride, maybe sealants/bonding needed.";
    }
    if (lowerInput.contains('tmj') || lowerInput.contains('jaw') || lowerInput.contains('click') || lowerInput.contains('pop')) {
        return "**TMJ Disorders**: Jaw pain/clicking. 😬\n• Avoid hard foods\n• Don't chew gum\n• Warm compresses\n• Night guard if grinding";
    }
    if (lowerInput.contains('grind') || lowerInput.contains('bruxism') || lowerInput.contains('clench')) {
        return "**Bruxism (Grinding)**: 😬\nStress-related. Wears teeth flat. A **Night Guard** protects teeth while sleeping.";
    }
    if (lowerInput.contains('apnea') || lowerInput.contains('snore')) {
         return "**Sleep Apnea**: 😴\nPauses in breathing. Dental appliances can hold jaw forward to open airway (alternative to CPAP).";
    }
    // Periodontics (Gums) - placed here as a Condition category
    if (lowerInput.contains('gum') || lowerInput.contains('periodon') || (lowerInput.contains('bleed') && !lowerInput.contains('stop')) || lowerInput.contains('gingivitis')) {
       if (lowerInput.contains('reverse')) {
           return "Gingivitis (early gum disease) IS reversible! 🔄\nWith good brushing/flossing. Periodontitis (bone loss) is NOT reversible but can be managed.";
       }
      return "**Periodontics** treats gums! 🩸\n\nSigns of trouble:\n• Bleeding\n• Red/Swollen\n• Bad breath\n• Loose teeth\n\nSee a periodontist!";
    }


    
    // Seniors
     if (lowerInput.contains('bedridden') || lowerInput.contains('elderly') || lowerInput.contains('senior')) {
         return "**Care for Bedridden/Seniors**: 👴\n• Electric brush helps dexterity\n• Dentures out at night!\n• Watch for dry mouth (meds)\n• Carers may need to assist brushing.";
    }

    // --- GENERAL PROCEDURES ---
    if (lowerInput.contains('scaling') || lowerInput.contains('deep clean')) {
         return "**Scaling & Root Planing**: Deep cleaning. 🧹\nRemoves tartar BELOW gumline. Needed for gum disease. Numbing used.";
    }
    if (lowerInput.contains('antibiotic')) {
         return "**Antibiotics**: 💊\nNot for pain alone! Only for systemic swelling/fever. overuse leads to resistance.";
    }
    if (lowerInput.contains('filling') && lowerInput.contains('last')) {
         return "**Fillings**: Last 5-15 years. ⏳\nSilver (Amalgam) lasts longer than White (Composite). Avoid chewing ice to extend life.";
    }
    if (lowerInput.contains('eat') && lowerInput.contains('filling')) {
         return "**Eating after Filling**: 🍽️\nComposite (White): Eat immediately! (careful if numb)\nAmalgam (Silver): Wait 24 hours for hard foods.";
    }
    // Prosthodontics (Restoration)
    if (lowerInput.contains('denture') || lowerInput.contains('crown') || lowerInput.contains('bridge') || lowerInput.contains('implant') || lowerInput.contains('prosto')) {
      return "**Prosthodontics** replaces teeth! 🦷\n\n• Crown: Cap for damaged tooth\n• Bridge: Fills gap using neighbors\n• Implant: Titanium root (best long-term)\n• Dentures: Removable";
    }



    // --- LIFESTYLE & HABITS ---
    if (lowerInput.contains('sport') || lowerInput.contains('guard') || (lowerInput.contains('protect') && lowerInput.contains('teeth'))) {
        return "**Sports Guards**: Essential for contact sports! 🏈\n• Custom-fit (Dentist): Best protection & comfort.\n• Boil-and-bite: Cheaper alternative.\nPrevents broken teeth, lip cuts, and jaw injuries.";
    }
    if (lowerInput.contains('nail') || lowerInput.contains('bite')) {
        return "**Nail Biting**: Bad for teeth! 💅\n• Chips enamel\n• Spreads bacteria\n• Stresses jaw (TMJ)\nTry bitter polish or stress balls to quit.";
    }
    if (lowerInput.contains('piercing')) {
         return "**Oral Piercings**: Risks involved! 💍\n• Chipped teeth (common)\n• Gum recession\n• Infection\nPlastic studs are safer than metal. Keep clean!";
    }
    if (lowerInput.contains('energy drink') || lowerInput.contains('soda') || lowerInput.contains('acid') || lowerInput.contains('erosion') || lowerInput.contains('lemon')) {
         return "**Acid Erosion**: 🍋\nEnergy drinks & lemons dissolve enamel.\n• Don't brush immediately after (enamel is soft)\n• Rinse with water\n• Drink through a straw";
    }
    if (lowerInput.contains('bottle') || lowerInput.contains('tool')) {
        return "Teeth are NOT tools! 🛠️\nOpening bottles or tearing packages can fracture teeth instantly. Use scissors/openers!";
    }
    if (lowerInput.contains('coffee') || lowerInput.contains('tea') || lowerInput.contains('stain')) {
         return "**Staining Prevention**: ☕\n• Sip water after coffee/tea\n• Use a straw\n• Professional cleaning removes surface stains.\n• Whitening toothpaste helps maintain.";
    }
    if (lowerInput.contains('smok') || lowerInput.contains('tobacco') || lowerInput.contains('cigarette') || lowerInput.contains('vape')) {
      return "Smoking/tobacco harms oral health! 🚭\n• Gum disease & tooth loss\n• Oral cancer risk\n• Delayed healing\n• Stained teeth\nYour dentist can help you quit!";
    }

    // --- HEALTH CONNECTIONS ---
    if (lowerInput.contains('heart')) {
         return "**Heart & Mouth**: ❤️\nGum disease is linked to heart disease. Bacteria can enter the bloodstream. Healthy mouth = Healthy heart!";
    }
    if (lowerInput.contains('diabetes') || lowerInput.contains('diabetic')) {
         return "**Diabetes**: 🩸\nDiabetics are at higher risk for gum disease. Gum disease makes blood sugar harder to control. Two-way street!";
    }
    if (lowerInput.contains('osteo') || lowerInput.contains('bone')) {
         return "**Osteoporosis**: Weak bones affect the jaw too. 🦴\nCan lead to tooth loss or loose dentures. Inform dentist of bisphosphonate meds.";
    }
    if (lowerInput.contains('autoimmune') || lowerInput.contains('lupus') || lowerInput.contains('sjogren')) {
         return "**Autoimmune Diseases**: Often cause Dry Mouth (Sjogren's). 🌵\nIncreases cavity risk. Use saliva substitutes and fluoride.";
    }
    if (lowerInput.contains('eating disorder') || lowerInput.contains('bulimia') || lowerInput.contains('anorexia')) {
         return "**Eating Disorders**: 💜\nVomiting acid erodes inner tooth surfaces. Rinse with baking soda water. Don't brush immediately. See dentist safely.";
    }
    if (lowerInput.contains('medication') || lowerInput.contains('drug')) {
         return "**Medications**: Many cause Dry Mouth! 💊\nOthers (blood thinners) affect surgery. Always bring a list of meds to your visit.";
    }
    if (lowerInput.contains('pregnancy') || lowerInput.contains('pregnant')) {
         return "**Pregnancy**: 🤰\n• Safe & important to visit dentist!\n• 'Pregnancy gingivitis' is common.\n• Avoid x-rays in 1st trimester if possible, but safe with shield.";
    }
    if (lowerInput.contains('cancer')) {
         return "**Cancer Care**: 🎗️\nChemo can cause sores/dry mouth. Pre-treatment dental checkup is crucial to prevent infection during immunity drop.";
    }

    // --- PRODUCTS & TECH ---
    
    // --- BASIC HYGIENE (Lowest Priority) ---
    if (lowerInput.contains('brush') || lowerInput.contains('toothpaste') || lowerInput.contains('clean teeth')) {
      if (lowerInput.contains('how long') || lowerInput.contains('time')) {
         return "Ideally, wait 30 minutes after eating to brush! ⏲️\n\nWhy? Acidic foods weaken enamel temporarily. Brushing too soon can wear it away. Rinse with water first!";
      }
      if (lowerInput.contains('hard') || lowerInput.contains('much')) {
         return "Yes, you CAN brush too hard! 🛑\n\nOver-brushing causes:\n• Enamel erosion\n• Gum recession\n• Sensitivity\n\nUse a **soft** brush and gentle circular motions.";
      }
      if (lowerInput.contains('electric')) {
         return "Electric toothbrushes are often excellent! ⚡\n\nThey remove plaque more effectively and have built-in timers. Great for braces or limited dexterity. Manual works too if used correctly!";
      }
       if (lowerInput.contains('replace') || lowerInput.contains('change')) {
         return "Replace your toothbrush every 3-4 months! 📅\nOr sooner if bristles are frayed. Also replace it after being sick.";
      }
      return "Brush twice daily for 2 minutes with fluoride toothpaste! 🪥\n\n✓ Soft bristles\n✓ 45-degree angle to gums\n✓ Don't forget tongue!";
    }
    
    if (lowerInput.contains('floss') || lowerInput.contains('interdental')) {
       if (lowerInput.contains('brace')) {
          return "Flossing with braces: Use a floss threader or water flosser! 💦 It's crucial to clean around wires where plaque hides.";
       }
       if (lowerInput.contains('water')) {
          return "Water flossers are great adjuncts! 🌊\nEspecially for braces or bridges. However, traditional floss is still best for tight contacts.";
       }
      return "Floss daily to remove plaque where brushes miss! 🧵\n\nPrevents cavities and gum disease. If gums bleed, keep flossing gently—it usually means they need it!";
    }

    if (lowerInput.contains('mouthwash') || lowerInput.contains('rinse')) {
       if (lowerInput.contains('oil')) {
           return "Oil pulling (swishing coconut oil) may reduce some bacteria but is NOT a substitute for brushing or flossing! 🥥 Use it as an extra step if you like.";
       }
      return "Mouthwash is a great bonus! 💧\n\n• Antiseptic: Kills bacteria\n• Fluoride: Strengthens enamel\n• Alcohol-free: Better for dry mouth";
    }

    if (lowerInput.contains('tongue')) {
        if (lowerInput.contains('black') || lowerInput.contains('hairy')) {
            return "Black Hairy Tongue looks scary but is harmless! 👅\n\nCauses: Smoking, poor hygiene, soft diet.\nFix: Brush tongue daily, quit smoking, eat crunchy foods.";
        }
         if (lowerInput.contains('geographic')) {
            return "Geographic Tongue (map-like patches) is usually benign. 🗺️\nIt may be sensitive to spicy foods. No treatment needed unless painful.";
        }
      return "Clean your tongue daily! 👅\nRemoves bacteria causing bad breath (halitosis). Use a scraper or brush.";
    }

    // --- OTHER PRODUCTS ---
    if (lowerInput.contains('natural') || lowerInput.contains('organic') || lowerInput.contains('herbal')) {
        return "**Natural Toothpaste**: Fine if it has effective ingredients. 🌱\nCheck for Xylitol or Fluoride. Plain baking soda is too abrasive.";
    }
    if (lowerInput.contains('sanitizer') || lowerInput.contains('uv')) {
        return "**Toothbrush Sanitizers**: UV light kills bacteria. 🦠\nHelpful, but air-drying your brush is usually sufficient. Don't cover a wet brush!";
    }
    if (lowerInput.contains('probiotic')) {
        return "**Dental Probiotics**: Good bacteria! 🦠\nLozenges with *S. salivarius* can help bad breath and gum health.";
    }
    if (lowerInput.contains('sugar free') || lowerInput.contains('gum')) {
        return "**Sugar-Free Gum**: Beneficial! 🍬\nIncreases saliva flow to wash away acid. Look for Xylitol ingredient.";
    }
    if (lowerInput.contains('laser')) {
        return "**Laser Dentistry**: 🔦\nUsed for gum surgery, cavity prep, and whitening. Often less pain and faster healing.";
    }
    if (lowerInput.contains('digital') || lowerInput.contains('impression')) {
        return "**Digital Impressions**: 📸\nNo more goop! 3D wand scans teeth for crowns/aligners. More accurate and comfortable.";
    }
    if (lowerInput.contains('cerec') || lowerInput.contains('same day')) {
        return "**CEREC (Same-Day Crowns)**: 👑\nComputer mills curb-side. Walk out with permanent crown in 2 hours. No temp needed!";
    }
    if (lowerInput.contains('teledentistry') || lowerInput.contains('video')) {
         return "**Teledentistry**: Remote checkups. 📱\nGood for: Consults, triaging emergencies, follow-ups. Cannot replace cleaning/exams.";
    }
    if (lowerInput.contains('3d print')) {
         return "**3D Printing**: 🖨️\nUsed for surgical guides, models, dentures, and aligners. Precision fit!";
    }
    
    // --- COSMETIC ---
    if (lowerInput.contains('gummy') || lowerInput.contains('gum shape')) {
         return "**Gummy Smile**: 👄\nCan be fixed with:\n• Laser gum contouring (reshaping)\n• Botox (lowers lip)\n• Orthodontics";
    }
    if (lowerInput.contains('gap') || lowerInput.contains('diastema')) {
         return "**Gaps (Diastema)**: \n• Braces/Invisalign (Best)\n• Bonding\n• Veneers\nClassic 'Madonna gap' is fine if you like it!";
    }
    if (lowerInput.contains('shaving') || lowerInput.contains('contour')) {
         return "**Enamel Contouring**: 💅\nFiles down rough edges or uneven lengths. Painless & no numbing needed. Subtle but effective.";
    }
    if (lowerInput.contains('veneer') || lowerInput.contains('bonding')) {
         return "**Veneer vs Bonding**: 🖼️\n• Bonding: Resin added (Cheaper, potential stain)\n• Veneers: Porcelain shell (Permanent, best form)";
    }
    if (lowerInput.contains('makeover') || lowerInput.contains('cosmetic')) {
         return "**Smile Makeover**: Custom plan! ✨\nCombines whitening, veneers, implants, and alignment. Consult a cosmetic dentist.";
    }
    if (lowerInput.contains('white') || lowerInput.contains('stain')) {
         if (lowerInput.contains('strip') || lowerInput.contains('damage')) {
             return "Whitening strips are generally safe if used as directed. Overuse can cause sensitivity or translucent edges.";
         }
         return "**Whitening**: Professional is fastest. 🌟\nCauses of stain: Coffee, tea, smoking, aging. Prevention: Sip water after coffee!";
    }
    
    // --- PREVENTIVE & CARE (Xylitol, Fluoride, etc.) ---
    if (lowerInput.contains('oil') && lowerInput.contains('pull')) {
         return "**Oil Pulling**: 🥥\nSwishing coconut oil. May reduce bacteria but DOES NOT replace brushing/flossing. Optional extra step.";
    }
    if (lowerInput.contains('ph') || lowerInput.contains('acid')) {
         return "**pH Balance**: ⚖️\nAcid (low pH) causes cavities. Saliva neutralizes it. Eat cheese/nuts to raise pH after sugary snacks!";
    }
    if (lowerInput.contains('xylitol')) {
         return "**Xylitol**: Magic sugar! 🍬\nBacteria can't digest it -> they starve. Reduces cavities. Hazardous to DOGS though!";
    }
    if (lowerInput.contains('fluoride')) {
        return "**Fluoride**: Safe & effective! 🛡️\nStrengthens enamel. Toxic only in massive industrial doses, not toothpaste amounts.";
    }
    if (lowerInput.contains('charcoal')) {
        return "**Charcoal Toothpaste**: Caution. ⚫\nAbrasive! Can scrub away enamel. Whitens by scratching surface stains. Use sparingly.";
    }
    
    // --- SPECIAL NEEDS & MYTHS (Remaining) ---
     if (lowerInput.contains('special need') || lowerInput.contains('autism') || lowerInput.contains('wheelchair')) {
         return "**Special Care**:\n• Visual stories/Tell-Show-Do for Autism\n• Wheelchair tilts or transfer boards\n• Find a specialist 'Special Care Dentist'.";
    }
    if (lowerInput.contains('sedation') || lowerInput.contains('sleep') || lowerInput.contains('anxiety')) {
         return "**Sedation Options**: 💤\n1. Nitrous Oxide (Laughing Gas) - Light\n2. Oral sedation (Pill) - Drowsy\n3. IV Sedation - Sleep/Forget";
    }
    if (lowerInput.contains('regrow') && lowerInput.contains('enamel')) {
        return "**Regrow Enamel?**: No. 🛑\nOnce lost, it's gone. You can *remineralize* (harden) weak spots with fluoride, but holes need filling.";
    }
    if (lowerInput.contains('reverse') && lowerInput.contains('cavity')) {
        return "**Reverse Cavity?**: Only earlies! ⏳\n'White spots' (pre-cavity) can heal with fluoride/calcium. Holes cannot Heal.";
    }
    
    // --- OTHER ---
    if (lowerInput.contains('anxiety') || lowerInput.contains('scared') || lowerInput.contains('fear') || lowerInput.contains('afraid')) {
        return "Dental Anxiety is real! 😨\n• Tell your dentist!\n• Headphones/Music help\n• Ask about sedation (laughing gas)\n• Hand signals to stop";
    }
    if (lowerInput.contains('cost') || lowerInput.contains('price') || lowerInput.contains('expensive') || lowerInput.contains('afford') || lowerInput.contains('insurance')) {
        return "Dental Care Costs: 💰\n• Prevention (cleaning) is cheaper than cure (root canal)!\n• Ask about payment plans (CareCredit, etc.)\n• Look for local dental schools (often cheaper)\n• Insurance focuses on prevention.";
    }
    if (lowerInput.contains('travel') || lowerInput.contains('abroad')) {
         return "**Traveling**: ✈️\n• Pack dental kit (filling material, wax, pain meds)\n• Check travel insurance dental coverage\n• 'Find A Dentist' apps";
    }
    if (lowerInput.contains('prepare') && lowerInput.contains('appointment')) {
         return "**Prep for Dentist**: 🏥\n1. List meds/allergies\n2. Eat light meal (if not sedated)\n3. Brush beforehand\n4. Bring insurance card\n5. Arrive early!";
    }

    // Default with Specific Advice
    return "I can help with:\n\n🦷 **Topics**: Braces, Implants, Gum Disease, Whitening\n👶 **Kids**: Teething, First Visit\n🚑 **Emergency**: Knocked out tooth, Pain\n💰 **General**: Insurance, Anxiety\n\nTry asking: \"Does root canal hurt?\" or \"Is charcoal toothpaste safe?\" 😊";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chatbot 🤖"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.teal : Colors.grey.shade200,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: isUser ? const Radius.circular(12) : Radius.zero,
                        bottomRight: isUser ? Radius.zero : const Radius.circular(12),
                      ),
                    ),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    child: Text(
                      msg['message']!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isTyping)
             const Padding(
               padding: EdgeInsets.all(8.0),
               child: Align(
                 alignment: Alignment.centerLeft,
                 child: Text("Thinking... 🤔", style: TextStyle(color: Colors.grey)),
               ),
             ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 24.0),
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: "Ask about dental health...",
                        hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        filled: true,
                        fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade50,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: _sendMessage,
                    backgroundColor: Colors.teal,
                    mini: true,
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
