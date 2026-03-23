// model_registry.dart
// Maps QR code text (case-insensitive) → asset path for the .glb model

class ModelRegistry {
  static const Map<String, ModelEntry> _models = {
    // ── ANATOMY ──────────────────────────────────────────
    'brain':   ModelEntry('flutter_assets/assets/models/ANATOMY/BRAIN.glb',   'Brain',        ModelCategory.anatomy),
    'ear':     ModelEntry('flutter_assets/assets/models/ANATOMY/EAR.glb',     'Ear',          ModelCategory.anatomy),
    'eye':     ModelEntry('flutter_assets/assets/models/ANATOMY/EYE.glb',     'Eye',          ModelCategory.anatomy),
    'lungs':   ModelEntry('flutter_assets/assets/models/ANATOMY/LUNGS.glb',   'Lungs',        ModelCategory.anatomy),
    'stomach': ModelEntry('flutter_assets/assets/models/ANATOMY/STOMACH.glb', 'Stomach',      ModelCategory.anatomy),
    'heart':   ModelEntry('flutter_assets/assets/models/ANATOMY/heart.glb',   'Heart',        ModelCategory.anatomy),

    // ── ASTRONOMY ─────────────────────────────────────────
    'earth':   ModelEntry('flutter_assets/assets/models/ASTRONOMY/earth.glb',   'Earth',   ModelCategory.astronomy),
    'jupiter': ModelEntry('flutter_assets/assets/models/ASTRONOMY/jupiter.glb', 'Jupiter', ModelCategory.astronomy),
    'mars':    ModelEntry('flutter_assets/assets/models/ASTRONOMY/mars.glb',    'Mars',    ModelCategory.astronomy),
    'mercury': ModelEntry('flutter_assets/assets/models/ASTRONOMY/mercury.glb', 'Mercury', ModelCategory.astronomy),
    'neptune': ModelEntry('flutter_assets/assets/models/ASTRONOMY/neptune.glb', 'Neptune', ModelCategory.astronomy),
    'saturn':  ModelEntry('flutter_assets/assets/models/ASTRONOMY/saturn.glb',  'Saturn',  ModelCategory.astronomy),
    'uranus':  ModelEntry('flutter_assets/assets/models/ASTRONOMY/uranus.glb',  'Uranus',  ModelCategory.astronomy),
    'venus':   ModelEntry('flutter_assets/assets/models/ASTRONOMY/venus.glb',   'Venus',   ModelCategory.astronomy),

    // ── BOTANY ────────────────────────────────────────────
    'artichoke':    ModelEntry('flutter_assets/assets/models/BOTANY/Artichoke.glb',    'Artichoke',    ModelCategory.botany),
    'cabbage':      ModelEntry('flutter_assets/assets/models/BOTANY/Cabbage.glb',      'Cabbage',      ModelCategory.botany),
    'carrot':       ModelEntry('flutter_assets/assets/models/BOTANY/Carrot.glb',       'Carrot',       ModelCategory.botany),
    'corn':         ModelEntry('flutter_assets/assets/models/BOTANY/Corn.glb',         'Corn',         ModelCategory.botany),
    'crocus':       ModelEntry('flutter_assets/assets/models/BOTANY/Crocus.glb',       'Crocus',       ModelCategory.botany),
    'daffodil':     ModelEntry('flutter_assets/assets/models/BOTANY/Daffodil.glb',     'Daffodil',     ModelCategory.botany),
    'lemon':        ModelEntry('flutter_assets/assets/models/BOTANY/Lemon.glb',        'Lemon',        ModelCategory.botany),
    'orange':       ModelEntry('flutter_assets/assets/models/BOTANY/Orange.glb',       'Orange',       ModelCategory.botany),
    'snowdrop':     ModelEntry('flutter_assets/assets/models/BOTANY/Snowdrop.glb',     'Snowdrop',     ModelCategory.botany),
    'sweet potato': ModelEntry('flutter_assets/assets/models/BOTANY/SweetPotato.glb',  'Sweet Potato', ModelCategory.botany),

    // ── GEOLOGY ───────────────────────────────────────────
    'copper':      ModelEntry('flutter_assets/assets/models/GEOLOGY/COPPER.glb',            'Copper',           ModelCategory.geology),
    'diamond':     ModelEntry('flutter_assets/assets/models/GEOLOGY/diamondrock.glb',       'Diamond Rock',     ModelCategory.geology),
    'fossil':      ModelEntry('flutter_assets/assets/models/GEOLOGY/FOSSIL.glb',            'Fossil',           ModelCategory.geology),
    'gold':        ModelEntry('flutter_assets/assets/models/GEOLOGY/goldrock.glb',          'Gold Rock',        ModelCategory.geology),
    'igneous':     ModelEntry('flutter_assets/assets/models/GEOLOGY/igneousrocks.glb',      'Igneous Rocks',    ModelCategory.geology),
    'metamorphic': ModelEntry('flutter_assets/assets/models/GEOLOGY/metamorphicrocks.glb',  'Metamorphic Rocks',ModelCategory.geology),
    'obsidian':    ModelEntry('flutter_assets/assets/models/GEOLOGY/obsidian.glb',          'Obsidian',         ModelCategory.geology),
    'sedimentary': ModelEntry('flutter_assets/assets/models/GEOLOGY/sedimentaryrocks.glb',  'Sedimentary Rocks',ModelCategory.geology),
    'tectonic':    ModelEntry('flutter_assets/assets/models/GEOLOGY/TECTONIC_PLATE.glb',    'Tectonic Plate',   ModelCategory.geology),
    'tectonic plate': ModelEntry('flutter_assets/assets/models/GEOLOGY/TECTONIC_PLATE.glb','Tectonic Plate',   ModelCategory.geology),
    'volcano':     ModelEntry('flutter_assets/assets/models/GEOLOGY/VOLCANO.glb',           'Volcano',          ModelCategory.geology),

    // ── ZOOLOGY ───────────────────────────────────────────
    'armadillo':        ModelEntry('flutter_assets/assets/models/ZOOLOGY/armadillo.glb',       'Armadillo',        ModelCategory.zoology),
    'axolotl':          ModelEntry('flutter_assets/assets/models/ZOOLOGY/axolotl.glb',         'Axolotl',          ModelCategory.zoology),
    'bear':             ModelEntry('flutter_assets/assets/models/ZOOLOGY/bear.glb',            'Bear',             ModelCategory.zoology),
    'capybara':         ModelEntry('flutter_assets/assets/models/ZOOLOGY/capybara.glb',       'Capybara',         ModelCategory.zoology),
    'coati':            ModelEntry('flutter_assets/assets/models/ZOOLOGY/coati.glb',           'Coati',            ModelCategory.zoology),
    'hammerhead':       ModelEntry('flutter_assets/assets/models/ZOOLOGY/hammerheadshark.glb', 'Hammerhead Shark', ModelCategory.zoology),
    'hammerhead shark': ModelEntry('flutter_assets/assets/models/ZOOLOGY/hammerheadshark.glb','Hammerhead Shark', ModelCategory.zoology),
    'shark':            ModelEntry('flutter_assets/assets/models/ZOOLOGY/hammerheadshark.glb', 'Hammerhead Shark', ModelCategory.zoology),
    'hippo':            ModelEntry('flutter_assets/assets/models/ZOOLOGY/hippo.glb',           'Hippo',            ModelCategory.zoology),
    'red panda':        ModelEntry('flutter_assets/assets/models/ZOOLOGY/redpanda.glb',        'Red Panda',        ModelCategory.zoology),
    'redpanda':         ModelEntry('flutter_assets/assets/models/ZOOLOGY/redpanda.glb',        'Red Panda',        ModelCategory.zoology),
    'sea turtle':       ModelEntry('flutter_assets/assets/models/ZOOLOGY/seaturtle.glb',       'Sea Turtle',       ModelCategory.zoology),
    'seaturtle':        ModelEntry('flutter_assets/assets/models/ZOOLOGY/seaturtle.glb',       'Sea Turtle',       ModelCategory.zoology),
    'turtle':           ModelEntry('flutter_assets/assets/models/ZOOLOGY/seaturtle.glb',       'Sea Turtle',       ModelCategory.zoology),
    'white rhino':      ModelEntry('flutter_assets/assets/models/ZOOLOGY/whiterhino.glb',      'White Rhino',      ModelCategory.zoology),
    'whiterhino':       ModelEntry('flutter_assets/assets/models/ZOOLOGY/whiterhino.glb',      'White Rhino',      ModelCategory.zoology),
    'rhino':            ModelEntry('flutter_assets/assets/models/ZOOLOGY/whiterhino.glb',      'White Rhino',      ModelCategory.zoology),
  };

  /// Looks up a QR value. Returns null if no model matches.
  static ModelEntry? resolve(String qrValue) => _models[qrValue.trim().toLowerCase()];

  static bool isKnown(String qrValue) => resolve(qrValue) != null;
}

enum ModelCategory { anatomy, astronomy, botany, geology, zoology }

extension ModelCategoryExt on ModelCategory {
  String get label {
    switch (this) {
      case ModelCategory.anatomy:   return 'Anatomy';
      case ModelCategory.astronomy: return 'Astronomy';
      case ModelCategory.botany:    return 'Botany';
      case ModelCategory.geology:   return 'Geology';
      case ModelCategory.zoology:   return 'Zoology';
    }
  }

  String get emoji {
    switch (this) {
      case ModelCategory.anatomy:   return '🫀';
      case ModelCategory.astronomy: return '🪐';
      case ModelCategory.botany:    return '🌿';
      case ModelCategory.geology:   return '🪨';
      case ModelCategory.zoology:   return '🦎';
    }
  }
}

class ModelEntry {
  final String assetPath;
  final String displayName;
  final ModelCategory category;

  const ModelEntry(this.assetPath, this.displayName, this.category);
}