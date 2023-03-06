// Everything has to match literally. The final value is not a phenotype but
// the CPIC lookupkey value. If a user has multiple of the given drugs active,
// the topmost one will be used, i.e. the inhibitors should go from most to
// least severe.

// structure: gene symbol -> drug name -> overwriting lookupkey

const Map<String, Map<String, String>> drugInhibitors = {
  'CYP2D6': {
    // 0.0 is a lookupkey for a type of poor metabolizer
    'bupropion': '0.0',
    'fluoxetine': '0.0',
    'paroxetine': '0.0',
    'quinidine': '0.0',
    'terbinafine': '0.0',
    // 1.0 is a lookupkey for a type of poor (but less poor than 0.0)
    // metabolizer
    'abiraterone': '1.0',
    'cinacalcet': '1.0',
    'duloxetine': '1.0',
    'lorcaserin': '1.0',
    'mirabegron': '1.0',
  }
};
