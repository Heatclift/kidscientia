// model_registry.dart
// Maps QR code text (case-insensitive) → asset path for the .glb model

class ModelRegistry {
  // ── Reusable ModelEntry instances (shared across duplicate QR keys) ──
  static const _brain = ModelEntry(
    'flutter_assets/assets/models/ANATOMY/BRAIN.glb',
    'Brain',
    ModelCategory.anatomy,
    emoji: '🧠',
    description:
        "Your brain weighs about 3 pounds and is packed with 86 billion tiny cells called neurons that send messages faster than a blink of an eye. It keeps growing until you're 18!",
  );
  static const _eye = ModelEntry(
    'flutter_assets/assets/models/ANATOMY/EYE.glb',
    'Eye',
    ModelCategory.anatomy,
    emoji: '👁️',
    description:
        "Your eyes work like amazing cameras that can spot about 10 million different colors! Each eye has six muscles that move it around, and together your eyes blink up to 1,200 times a day to stay clean and wet.",
  );
  static const _ear = ModelEntry(
    'flutter_assets/assets/models/ANATOMY/EAR.glb',
    'Ear',
    ModelCategory.anatomy,
    emoji: '👂',
    description:
        "Your ears do more than hear sounds, they also help you balance! Tiny bones inside each ear vibrate when sound reaches them, and those vibrations become messages your brain can understand.",
  );
  static const _lungs = ModelEntry(
    'flutter_assets/assets/models/ANATOMY/LUNGS.glb',
    'Lungs',
    ModelCategory.anatomy,
    emoji: '🫁',
    description:
        "Your two lungs fill up with air like balloons every time you breathe, about 22,000 times a day! Inside them are 300-500 million tiny air sacs called alveoli. Amazingly, lungs are the only organ in your body that can float on water.",
  );
  static const _stomach = ModelEntry(
    'flutter_assets/assets/models/ANATOMY/STOMACH.glb',
    'Stomach',
    ModelCategory.anatomy,
    emoji: '🩻',
    description:
        "Your stomach is only about the size of your fist when empty, but it can stretch to hold a big meal. It makes a superstrong acid that could dissolve metal, helping mash up food into fuel for your body.",
  );
  static const _heart = ModelEntry(
    'flutter_assets/assets/models/ANATOMY/heart.glb',
    'Heart',
    ModelCategory.anatomy,
    emoji: '🫀',
    description:
        "Your heart is about the size of your fist, but it's incredibly strong. It beats around 100,000 times every single day, pumping about 2,000 gallons of blood through your body without ever stopping to rest.",
  );

  static const _earth = ModelEntry(
    'flutter_assets/assets/models/ASTRONOMY/earth.glb',
    'Earth',
    ModelCategory.astronomy,
    emoji: '🌍',
    description:
        "Earth is the only planet we know of with life, oceans, and air to breathe! About 70% of its surface is covered in water, and it takes exactly one year to zoom all the way around the Sun.",
  );
  static const _jupiter = ModelEntry(
    'flutter_assets/assets/models/ASTRONOMY/jupiter.glb',
    'Jupiter',
    ModelCategory.astronomy,
    emoji: '🟠',
    description:
        "Jupiter is the biggest planet in our solar system, so huge that over 1,300 Earths could fit inside it! It has a giant storm called the Great Red Spot that's bigger than Earth and has been swirling for hundreds of years.",
  );
  static const _mars = ModelEntry(
    'flutter_assets/assets/models/ASTRONOMY/mars.glb',
    'Mars',
    ModelCategory.astronomy,
    emoji: '🔴',
    description:
        "Mars is called the Red Planet because rusty iron dust covers its surface. It's home to Olympus Mons, the tallest volcano in the whole solar system, standing almost three times taller than Mount Everest!",
  );
  static const _mercury = ModelEntry(
    'flutter_assets/assets/models/ASTRONOMY/mercury.glb',
    'Mercury',
    ModelCategory.astronomy,
    emoji: '⚪',
    description:
        "Mercury is the smallest planet and also the fastest, zooming around the Sun at 31 miles per second! During the day it can reach 800°F, but at night it plunges to -290°F since it has almost no atmosphere to trap heat.",
  );
  static const _neptune = ModelEntry(
    'flutter_assets/assets/models/ASTRONOMY/neptune.glb',
    'Neptune',
    ModelCategory.astronomy,
    emoji: '🔵',
    description:
        "Neptune is the farthest planet from the Sun and also the windiest, with gusts blasting up to 1,200 miles per hour, faster than the speed of sound! Its bright blue color comes from methane gas in its atmosphere.",
  );
  static const _saturn = ModelEntry(
    'flutter_assets/assets/models/ASTRONOMY/saturn.glb',
    'Saturn',
    ModelCategory.astronomy,
    emoji: '🪐',
    description:
        "Saturn is famous for its dazzling rings made of billions of pieces of ice and rock, some as tiny as dust and others as big as mountains. The rings stretch 175,000 miles wide but are surprisingly thin.",
  );
  static const _uranus = ModelEntry(
    'flutter_assets/assets/models/ASTRONOMY/uranus.glb',
    'Uranus',
    ModelCategory.astronomy,
    emoji: '🔵',
    description:
        "Uranus is the sideways planet, it spins on its side like a rolling ball, tilted 98 degrees! This icy giant is a chilly -320°F on average and is circled by 13 thin rings and 28 moons.",
  );
  static const _venus = ModelEntry(
    'flutter_assets/assets/models/ASTRONOMY/venus.glb',
    'Venus',
    ModelCategory.astronomy,
    emoji: '🟡',
    description:
        "Venus is the hottest planet in our solar system, even hotter than Mercury, with surface temperatures reaching 869°F, hot enough to melt metal! Thick clouds trap heat like a blanket, and Venus even spins backwards compared to most planets.",
  );

  static const _artichoke = ModelEntry(
    'flutter_assets/assets/models/BOTANY/Artichoke.glb',
    'Artichoke',
    ModelCategory.botany,
    emoji: '🌿',
    description:
        "An artichoke is actually a giant flower bud from a thistle plant, if you let it keep growing, it blooms into a big purple flower! People eat the soft base of its leaves and its tender heart before that happens.",
  );
  static const _cabbage = ModelEntry(
    'flutter_assets/assets/models/BOTANY/Cabbage.glb',
    'Cabbage',
    ModelCategory.botany,
    emoji: '🥬',
    description:
        "Cabbage grows into a tight, round ball of crunchy leaves and comes in green, red, and purple colors. It's packed with vitamin C, and people have been growing this leafy vegetable for over 3,000 years!",
  );
  static const _carrot = ModelEntry(
    'flutter_assets/assets/models/BOTANY/Carrot.glb',
    'Carrot',
    ModelCategory.botany,
    emoji: '🥕',
    description:
        "Crunchy carrots are famous for being orange, but they can also be purple, red, or white! They're full of vitamin A, which helps keep your eyes healthy, and their seeds are so tiny that 2,000 can fit in one teaspoon.",
  );
  static const _corn = ModelEntry(
    'flutter_assets/assets/models/BOTANY/Corn.glb',
    'Corn',
    ModelCategory.botany,
    emoji: '🌽',
    description:
        "Corn, also called maize, grows tall stalks that can reach up to 8 feet high, with an average ear holding about 800 juicy kernels. Every single kernel has its own silky thread connecting it to the cob!",
  );
  static const _crocus = ModelEntry(
    'flutter_assets/assets/models/BOTANY/Crocus.glb',
    'Crocus',
    ModelCategory.botany,
    emoji: '🌸',
    description:
        "The crocus is one of the very first flowers to bloom in spring, sometimes popping up right through melting snow! It grows from an underground bulb called a corm, and one type even gives us the spice saffron.",
  );
  static const _daffodil = ModelEntry(
    'flutter_assets/assets/models/BOTANY/Daffodil.glb',
    'Daffodil',
    ModelCategory.botany,
    emoji: '🌼',
    description:
        "Daffodils are cheerful yellow or white flowers with a trumpet-shaped center called a corona. They're one of the first signs that spring has arrived, and they're even the national flower of Wales!",
  );
  static const _lemon = ModelEntry(
    'flutter_assets/assets/models/BOTANY/Lemon.glb',
    'Lemon',
    ModelCategory.botany,
    emoji: '🍋',
    description:
        "Lemons are sour fruits packed with vitamin C, sailors used to eat them to stay healthy on long voyages! A single lemon tree can grow up to 600 pounds of lemons in just one year.",
  );
  static const _orange = ModelEntry(
    'flutter_assets/assets/models/BOTANY/Orange.glb',
    'Orange',
    ModelCategory.botany,
    emoji: '🍊',
    description:
        "Oranges are sweet, juicy fruits loaded with vitamin C that help your body heal and fight germs. An orange tree can grow up to 33 feet tall, and no other word in English rhymes with 'orange'!",
  );
  static const _snowdrop = ModelEntry(
    'flutter_assets/assets/models/BOTANY/Snowdrop.glb',
    'Snowdrop',
    ModelCategory.botany,
    emoji: '🤍',
    description:
        "Snowdrops are tiny white bell-shaped flowers that bravely bloom in the middle of winter, sometimes even in January! They have a natural antifreeze inside that lets them survive icy, frosty nights.",
  );
  static const _sweetPotato = ModelEntry(
    'flutter_assets/assets/models/BOTANY/SweetPotato.glb',
    'Sweet Potato',
    ModelCategory.botany,
    emoji: '🍠',
    description:
        "Sweet potatoes aren't really potatoes at all, they're actually roots related to morning glory flowers! They come in orange, white, and purple, and they're packed with vitamin A, which is great for your eyes.",
  );

  static const _copper = ModelEntry(
    'flutter_assets/assets/models/GEOLOGY/COPPER.glb',
    'Copper',
    ModelCategory.geology,
    emoji: '🟠',
    description:
        "Copper was the very first metal humans ever used, over 10,000 years ago! This reddish-orange metal is found in almost every wire and electronic device because it's amazing at carrying electricity.",
  );
  static const _diamond = ModelEntry(
    'flutter_assets/assets/models/GEOLOGY/diamondrock.glb',
    'Diamond Rock',
    ModelCategory.geology,
    emoji: '💎',
    description:
        "Diamonds are the hardest natural material on Earth, so hard that only another diamond can scratch one! They form deep underground, more than 75 miles down, under intense heat and pressure over billions of years.",
  );
  static const _fossil = ModelEntry(
    'flutter_assets/assets/models/GEOLOGY/FOSSIL.glb',
    'Fossil',
    ModelCategory.geology,
    emoji: '🦴',
    description:
        "Fossils are the preserved remains or traces of ancient plants and animals, some are millions of years old! They form when minerals slowly replace bone or shell, turning living things into stone time capsules.",
  );
  static const _gold = ModelEntry(
    'flutter_assets/assets/models/GEOLOGY/goldrock.glb',
    'Gold Rock',
    ModelCategory.geology,
    emoji: '🪙',
    description:
        "Gold is a shiny, soft metal that never rusts and can be stretched incredibly thin, one ounce can be pulled into a thread five miles long! People have treasured gold for over 5,000 years.",
  );
  static const _igneous = ModelEntry(
    'flutter_assets/assets/models/GEOLOGY/igneousrocks.glb',
    'Igneous Rocks',
    ModelCategory.geology,
    emoji: '🌋',
    description:
        "Igneous rock forms when scorching hot melted rock, called magma or lava, cools down and turns solid. Granite, used for kitchen countertops, is one famous example that took millions of years to form underground.",
  );
  static const _metamorphic = ModelEntry(
    'flutter_assets/assets/models/GEOLOGY/metamorphicrocks.glb',
    'Metamorphic Rocks',
    ModelCategory.geology,
    emoji: '🪨',
    description:
        "Metamorphic rock starts as one kind of rock but gets 'changed' by intense heat and crushing pressure deep underground. Marble, the shiny stone used to build the Taj Mahal, is a beautiful example.",
  );
  static const _obsidian = ModelEntry(
    'flutter_assets/assets/models/GEOLOGY/obsidian.glb',
    'Obsidian',
    ModelCategory.geology,
    emoji: '⚫',
    description:
        "Obsidian is natural volcanic glass formed when lava cools so fast that no crystals have time to form! It's so smooth and sharp that ancient people used it to make cutting tools and blades.",
  );
  static const _sedimentary = ModelEntry(
    'flutter_assets/assets/models/GEOLOGY/sedimentaryrocks.glb',
    'Sedimentary Rocks',
    ModelCategory.geology,
    emoji: '🪨',
    description:
        "Sedimentary rock forms from layers of sand, mud, and tiny shells that pile up and press together over time, like a stack of pancakes! Most fossils are found inside this layered rock.",
  );
  static const _tectonicPlate = ModelEntry(
    'flutter_assets/assets/models/GEOLOGY/TECTONIC_PLATE.glb',
    'Tectonic Plate',
    ModelCategory.geology,
    emoji: '🗺️',
    description:
        "The ground beneath your feet is actually part of a giant slab called a tectonic plate, and it's slowly moving, about as fast as your fingernails grow! These plates cause earthquakes, volcanoes, and towering mountains.",
  );
  static const _volcano = ModelEntry(
    'flutter_assets/assets/models/GEOLOGY/VOLCANO.glb',
    'Volcano',
    ModelCategory.geology,
    emoji: '🌋',
    description:
        "A volcano is an opening in Earth's crust where scorching hot melted rock called magma can burst out. Lava can reach temperatures of 1,250°C, and the biggest volcano on Earth, Mauna Loa, rises over 4,000 meters tall!",
  );

  static const _armadillo = ModelEntry(
    'flutter_assets/assets/models/ZOOLOGY/armadillo.glb',
    'Armadillo',
    ModelCategory.zoology,
    emoji: '🦔',
    description:
        "The armadillo wears its own suit of armor made of bony plates! Some kinds can even roll into a tight ball to protect themselves, and armadillo babies are usually born as identical quadruplets.",
  );
  static const _axolotl = ModelEntry(
    'flutter_assets/assets/models/ZOOLOGY/axolotl.glb',
    'Axolotl',
    ModelCategory.zoology,
    emoji: '🦎',
    description:
        "The axolotl is a smiling salamander that never grows up, it keeps its feathery gills and lives underwater its whole life! It has an amazing superpower: it can regrow lost legs, its tail, and even parts of its heart and brain.",
  );
  static const _bear = ModelEntry(
    'flutter_assets/assets/models/ZOOLOGY/bear.glb',
    'Bear',
    ModelCategory.zoology,
    emoji: '🐻',
    description:
        "There are eight kinds of bears around the world, from towering polar bears to small sun bears. Even though they look slow and cuddly, bears can run up to 35 miles per hour, faster than most humans can sprint!",
  );
  static const _capybara = ModelEntry(
    'flutter_assets/assets/models/ZOOLOGY/capybara.glb',
    'Capybara',
    ModelCategory.zoology,
    emoji: '🐹',
    description:
        "The capybara is the world's largest rodent, growing over 4 feet long, about the size of a large dog! These friendly, chill animals love swimming and can hold their breath underwater for up to five minutes.",
  );
  static const _coati = ModelEntry(
    'flutter_assets/assets/models/ZOOLOGY/coati.glb',
    'Coati',
    ModelCategory.zoology,
    emoji: '🦝',
    description:
        "The coati is a curious relative of the raccoon with a long, flexible snout and a tail as long as its whole body. It can twist its ankles more than 180 degrees, letting it climb down trees headfirst!",
  );
  static const _hammerhead = ModelEntry(
    'flutter_assets/assets/models/ZOOLOGY/hammerheadshark.glb',
    'Hammerhead Shark',
    ModelCategory.zoology,
    emoji: '🦈',
    description:
        "The hammerhead shark's wide, flat head lets it see almost all the way around itself, above, below, and to both sides at once! These sharks can grow up to 20 feet long and love hunting stingrays.",
  );
  static const _hippo = ModelEntry(
    'flutter_assets/assets/models/ZOOLOGY/hippo.glb',
    'Hippo',
    ModelCategory.zoology,
    emoji: '🦛',
    description:
        "Hippos may look slow, but they can outrun a human, reaching speeds of 19 miles per hour on land! Despite their huge size, they're excellent swimmers and can hold their breath underwater for up to five minutes.",
  );
  static const _redPanda = ModelEntry(
    'flutter_assets/assets/models/ZOOLOGY/redpanda.glb',
    'Red Panda',
    ModelCategory.zoology,
    emoji: '🐼',
    description:
        "The red panda has thick reddish fur, a bushy striped tail, and a secret extra 'thumb' that helps it grip bamboo. Even though it eats mostly bamboo, it's actually more closely related to raccoons than to giant pandas!",
  );
  static const _seaTurtle = ModelEntry(
    'flutter_assets/assets/models/ZOOLOGY/seaturtle.glb',
    'Sea Turtle',
    ModelCategory.zoology,
    emoji: '🐢',
    description:
        "Sea turtles have been swimming in Earth's oceans for over 100 million years, since the age of dinosaurs! They can swim up to 25 miles per hour and travel thousands of miles across the ocean to nest.",
  );
  static const _whiteRhino = ModelEntry(
    'flutter_assets/assets/models/ZOOLOGY/whiterhino.glb',
    'White Rhino',
    ModelCategory.zoology,
    emoji: '🦏',
    description:
        "The white rhino is the largest of all rhino species and can weigh as much as 30 grown men! Its name actually comes from a mix-up: 'white' really meant 'wide,' describing its broad, square lips used for grazing grass.",
  );

  static const Map<String, ModelEntry> _models = {
    // ── ANATOMY ──────────────────────────────────────────
    'brain': _brain,
    'eye': _eye,
    'ear': _ear,
    'lungs': _lungs,
    'stomach': _stomach,
    'heart': _heart,

    // ── ASTRONOMY ─────────────────────────────────────────
    'earth': _earth,
    'jupiter': _jupiter,
    'mars': _mars,
    'mercury': _mercury,
    'neptune': _neptune,
    'saturn': _saturn,
    'uranus': _uranus,
    'venus': _venus,

    // ── BOTANY ────────────────────────────────────────────
    'artichoke': _artichoke,
    'cabbage': _cabbage,
    'carrot': _carrot,
    'corn': _corn,
    'crocus': _crocus,
    'daffodil': _daffodil,
    'lemon': _lemon,
    'orange': _orange,
    'snowdrop': _snowdrop,
    'sweet potato': _sweetPotato,

    // ── GEOLOGY ───────────────────────────────────────────
    'copper': _copper,
    'diamond': _diamond,
    'fossil': _fossil,
    'gold': _gold,
    'igneous': _igneous,
    'metamorphic': _metamorphic,
    'obsidian': _obsidian,
    'sedimentary': _sedimentary,
    'tectonic': _tectonicPlate,
    'tectonic plate': _tectonicPlate,
    'volcano': _volcano,

    // ── ZOOLOGY ───────────────────────────────────────────
    'armadillo': _armadillo,
    'axolotl': _axolotl,
    'bear': _bear,
    'capybara': _capybara,
    'coati': _coati,
    'hammerhead': _hammerhead,
    'hammerhead shark': _hammerhead,
    'shark': _hammerhead,
    'hippo': _hippo,
    'red panda': _redPanda,
    'redpanda': _redPanda,
    'sea turtle': _seaTurtle,
    'seaturtle': _seaTurtle,
    'turtle': _seaTurtle,
    'white rhino': _whiteRhino,
    'whiterhino': _whiteRhino,
    'rhino': _whiteRhino,
  };

  static const Map<String, String> _aliases = {
    'diamondrock': 'diamond',
    'diamond rock': 'diamond',
    'goldrock': 'gold',
    'gold rock': 'gold',
    'igneous rock': 'igneous',
    'igneousrocks': 'igneous',
    'igneous rocks': 'igneous',
    'metamorphic rock': 'metamorphic',
    'metamorphicrocks': 'metamorphic',
    'metamorphic rocks': 'metamorphic',
    'sedimentary rock': 'sedimentary',
    'sedimentaryrocks': 'sedimentary',
    'sedimentary rocks': 'sedimentary',
    'hammer head': 'hammerhead',
    'hammer head shark': 'hammerhead shark',
    'hammerheadshark': 'hammerhead shark',
    'sweetpotato': 'sweet potato',
    'newbeard': 'bear',
  };

  /// Looks up a QR value. Returns null if no model matches.
  static ModelEntry? resolve(String qrValue) {
    final key = resolveKey(qrValue);
    return key == null ? null : _entryForKey(key);
  }

  static String? resolveKey(String qrValue) {
    for (final key in candidateKeys(qrValue)) {
      if (_entryForKey(key) != null) return key;
    }
    return null;
  }

  static String normalizeQrValue(String qrValue) {
    return resolveKey(qrValue) ?? candidateKeys(qrValue).first;
  }

  static Iterable<String> get registeredKeys => _models.keys;

  static Iterable<String> get aliasKeys => _aliases.keys;

  static Iterable<ModelEntry> get registeredEntries => _models.values.toSet();

  static List<String> candidateKeys(String qrValue) {
    final candidates = <String>[];

    void addCandidate(String value) {
      final normalized = _normalizeCandidate(value);
      if (normalized.isNotEmpty && !candidates.contains(normalized)) {
        candidates.add(normalized);
      }
    }

    var value = qrValue
        .trim()
        .toLowerCase()
        .replaceAll('\\', '/')
        .replaceAll(RegExp(r'&(?:#x20|#32|nbsp);', caseSensitive: false), ' ')
        .replaceAll(RegExp('[“”]'), '"')
        .replaceAll(RegExp('[‘’]'), "'");

    addCandidate(value);

    final uri = Uri.tryParse(value.contains('://') ? value : 'https://$value');
    if (uri != null) {
      for (final segment in uri.pathSegments.reversed) {
        addCandidate(segment);
      }
      for (final values in uri.queryParametersAll.values) {
        for (final queryValue in values) {
          addCandidate(queryValue);
        }
      }
    }

    final queryStart = value.indexOf(RegExp(r'[?#]'));
    if (queryStart >= 0) {
      value = value.substring(0, queryStart);
    }

    while (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }

    if (value.contains('/')) {
      for (final segment in value.split('/').reversed) {
        addCandidate(segment);
      }
    }

    addCandidate(value);
    return candidates;
  }

  static ModelEntry? _entryForKey(String key) =>
      _models[key] ?? _models[_aliases[key]];

  static String _normalizeCandidate(String value) {
    value = value.trim();

    while (value.length >= 2 &&
        ((_isWrappingQuote(value.codeUnitAt(0)) &&
                _isWrappingQuote(value.codeUnitAt(value.length - 1))) ||
            (value.startsWith('<') && value.endsWith('>')) ||
            (value.startsWith('(') && value.endsWith(')')) ||
            (value.startsWith('[') && value.endsWith(']')))) {
      value = value.substring(1, value.length - 1).trim();
    }

    value = value.replaceAll(RegExp(r'^[^\w]+|[^\w]+$'), '');

    try {
      value = Uri.decodeComponent(value);
    } catch (_) {
      // Keep the scanned value when it is not valid URI encoding.
    }

    if (value.endsWith('.glb')) {
      value = value.substring(0, value.length - 4);
    }

    return value
        .replaceAll(RegExp(r'[-_]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static bool _isWrappingQuote(int codeUnit) =>
      codeUnit == 0x22 || codeUnit == 0x27;

  static bool isKnown(String qrValue) => resolve(qrValue) != null;
}

enum ModelCategory { anatomy, astronomy, botany, geology, zoology }

extension ModelCategoryExt on ModelCategory {
  String get label {
    switch (this) {
      case ModelCategory.anatomy:
        return 'Anatomy';
      case ModelCategory.astronomy:
        return 'Astronomy';
      case ModelCategory.botany:
        return 'Botany';
      case ModelCategory.geology:
        return 'Geology';
      case ModelCategory.zoology:
        return 'Zoology';
    }
  }

  String get emoji {
    switch (this) {
      case ModelCategory.anatomy:
        return '🫀';
      case ModelCategory.astronomy:
        return '🪐';
      case ModelCategory.botany:
        return '🌿';
      case ModelCategory.geology:
        return '🪨';
      case ModelCategory.zoology:
        return '🦎';
    }
  }
}

class ModelEntry {
  final String assetPath;
  final String displayName;
  final ModelCategory category;
  final String emoji;
  final String description;

  const ModelEntry(
    this.assetPath,
    this.displayName,
    this.category, {
    required this.emoji,
    required this.description,
  });
}
