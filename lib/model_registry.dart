// model_registry.dart
// Maps QR code text (case-insensitive) → asset path for the .glb model

class ModelRegistry {
  static const Map<String, ModelEntry> _models = {
    // ── ANATOMY ──────────────────────────────────────────
    'brain':   ModelEntry('assets/models/ANATOMY/brain.glb',   'Brain',        ModelCategory.anatomy),
    'ear':     ModelEntry('assets/models/ANATOMY/EAR.glb',     'Ear',          ModelCategory.anatomy),
    'eye':     ModelEntry('assets/models/ANATOMY/EYE.glb',     'Eye',          ModelCategory.anatomy),
    'lungs':   ModelEntry('assets/models/ANATOMY/LUNGS.glb',   'Lungs',        ModelCategory.anatomy),
    'stomach': ModelEntry('assets/models/ANATOMY/STOMACH.glb', 'Stomach',      ModelCategory.anatomy),
    'heart':   ModelEntry('assets/models/ANATOMY/heart.glb',   'Heart',        ModelCategory.anatomy),

    // ── ASTRONOMY ─────────────────────────────────────────
    'earth':   ModelEntry('assets/models/ASTRONOMY/earth.glb',   'Earth',   ModelCategory.astronomy),
    'jupiter': ModelEntry('assets/models/ASTRONOMY/jupiter.glb', 'Jupiter', ModelCategory.astronomy),
    'mars':    ModelEntry('assets/models/ASTRONOMY/mars.glb',    'Mars',    ModelCategory.astronomy),
    'mercury': ModelEntry('assets/models/ASTRONOMY/mercury.glb', 'Mercury', ModelCategory.astronomy),
    'neptune': ModelEntry('assets/models/ASTRONOMY/neptune.glb', 'Neptune', ModelCategory.astronomy),
    'saturn':  ModelEntry('assets/models/ASTRONOMY/saturn.glb',  'Saturn',  ModelCategory.astronomy),
    'uranus':  ModelEntry('assets/models/ASTRONOMY/uranus.glb',  'Uranus',  ModelCategory.astronomy),
    'venus':   ModelEntry('assets/models/ASTRONOMY/venus.glb',   'Venus',   ModelCategory.astronomy),

    // ── BOTANY ────────────────────────────────────────────
    'artichoke':    ModelEntry('assets/models/BOTANY/Artichoke.glb',    'Artichoke',    ModelCategory.botany),
    'cabbage':      ModelEntry('assets/models/BOTANY/Cabbage.glb',      'Cabbage',      ModelCategory.botany),
    'carrot':       ModelEntry('assets/models/BOTANY/Carrot.glb',       'Carrot',       ModelCategory.botany),
    'corn':         ModelEntry('assets/models/BOTANY/Corn.glb',         'Corn',         ModelCategory.botany),
    'crocus':       ModelEntry('assets/models/BOTANY/Crocus.glb',       'Crocus',       ModelCategory.botany),
    'daffodil':     ModelEntry('assets/models/BOTANY/Daffodil.glb',     'Daffodil',     ModelCategory.botany),
    'lemon':        ModelEntry('assets/models/BOTANY/Lemon.glb',        'Lemon',        ModelCategory.botany),
    'orange':       ModelEntry('assets/models/BOTANY/Orange.glb',       'Orange',       ModelCategory.botany),
    'snowdrop':     ModelEntry('assets/models/BOTANY/Snowdrop.glb',     'Snowdrop',     ModelCategory.botany),
    'sweet potato': ModelEntry('assets/models/BOTANY/SweetPotato.glb',  'Sweet Potato', ModelCategory.botany),

    // ── GEOLOGY ───────────────────────────────────────────
    'copper':      ModelEntry('assets/models/GEOLOGY/COPPER.glb',            'Copper',           ModelCategory.geology),
    'diamond':     ModelEntry('assets/models/GEOLOGY/diamondrock.glb',       'Diamond Rock',     ModelCategory.geology),
    'fossil':      ModelEntry('assets/models/GEOLOGY/FOSSIL.glb',            'Fossil',           ModelCategory.geology),
    'gold':        ModelEntry('assets/models/GEOLOGY/goldrock.glb',          'Gold Rock',        ModelCategory.geology),
    'igneous':     ModelEntry('assets/models/GEOLOGY/igneousrocks.glb',      'Igneous Rocks',    ModelCategory.geology),
    'metamorphic': ModelEntry('assets/models/GEOLOGY/metamorphicrocks.glb',  'Metamorphic Rocks',ModelCategory.geology),
    'obsidian':    ModelEntry('assets/models/GEOLOGY/obsidian.glb',          'Obsidian',         ModelCategory.geology),
    'sedimentary': ModelEntry('assets/models/GEOLOGY/sedimentaryrocks.glb',  'Sedimentary Rocks',ModelCategory.geology),
    'tectonic':    ModelEntry('assets/models/GEOLOGY/TECTONIC_PLATE.glb',    'Tectonic Plate',   ModelCategory.geology),
    'tectonic plate': ModelEntry('assets/models/GEOLOGY/TECTONIC_PLATE.glb','Tectonic Plate',   ModelCategory.geology),
    'volcano':     ModelEntry('assets/models/GEOLOGY/VOLCANO.glb',           'Volcano',          ModelCategory.geology),

    // ── ZOOLOGY ───────────────────────────────────────────
    'armadillo':        ModelEntry('assets/models/ZOOLOGY/armadillo.glb',       'Armadillo',        ModelCategory.zoology),
    'axolotl':          ModelEntry('assets/models/ZOOLOGY/axolotl.glb',         'Axolotl',          ModelCategory.zoology),
    'bear':             ModelEntry('assets/models/ZOOLOGY/bear.glb',            'Bear',             ModelCategory.zoology),
    'capybara':         ModelEntry('assets/models/ZOOLOGY/capybara.glb',       'Capybara',         ModelCategory.zoology),
    'coati':            ModelEntry('assets/models/ZOOLOGY/coati.glb',           'Coati',            ModelCategory.zoology),
    'hammerhead':       ModelEntry('assets/models/ZOOLOGY/hammerheadshark.glb', 'Hammerhead Shark', ModelCategory.zoology),
    'hammerhead shark': ModelEntry('assets/models/ZOOLOGY/hammerheadshark.glb','Hammerhead Shark', ModelCategory.zoology),
    'shark':            ModelEntry('assets/models/ZOOLOGY/hammerheadshark.glb', 'Hammerhead Shark', ModelCategory.zoology),
    'hippo':            ModelEntry('assets/models/ZOOLOGY/hippo.glb',           'Hippo',            ModelCategory.zoology),
    'red panda':        ModelEntry('assets/models/ZOOLOGY/redpanda.glb',        'Red Panda',        ModelCategory.zoology),
    'redpanda':         ModelEntry('assets/models/ZOOLOGY/redpanda.glb',        'Red Panda',        ModelCategory.zoology),
    'sea turtle':       ModelEntry('assets/models/ZOOLOGY/seaturtle.glb',       'Sea Turtle',       ModelCategory.zoology),
    'seaturtle':        ModelEntry('assets/models/ZOOLOGY/seaturtle.glb',       'Sea Turtle',       ModelCategory.zoology),
    'turtle':           ModelEntry('assets/models/ZOOLOGY/seaturtle.glb',       'Sea Turtle',       ModelCategory.zoology),
    'white rhino':      ModelEntry('assets/models/ZOOLOGY/whiterhino.glb',      'White Rhino',      ModelCategory.zoology),
    'whiterhino':       ModelEntry('assets/models/ZOOLOGY/whiterhino.glb',      'White Rhino',      ModelCategory.zoology),
    'rhino':            ModelEntry('assets/models/ZOOLOGY/whiterhino.glb',      'White Rhino',      ModelCategory.zoology),
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