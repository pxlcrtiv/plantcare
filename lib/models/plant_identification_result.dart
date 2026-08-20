class PlantIdentificationResult {
  final String? queryId;
  final String? queryType;
  final String? queryHash;
  final String? queryImage;
  final List<PlantResult> results;
  final List<SimilarImage>? similarImages;

  PlantIdentificationResult({
    this.queryId,
    this.queryType,
    this.queryHash,
    this.queryImage,
    required this.results,
    this.similarImages,
  });

  factory PlantIdentificationResult.fromJson(Map<String, dynamic> json) {
    return PlantIdentificationResult(
      queryId: json['queryId'],
      queryType: json['queryType'],
      queryHash: json['queryHash'],
      queryImage: json['queryImage'],
      results: (json['results'] as List)
          .map((item) => PlantResult.fromJson(item))
          .toList(),
      similarImages: json['similarImages'] != null
          ? (json['similarImages'] as List)
              .map((item) => SimilarImage.fromJson(item))
              .toList()
          : null,
    );
  }
}

class PlantResult {
  final String? id;
  final double? score;
  final String? scientificName;
  final String? family;
  final String? genus;
  final Map<String, dynamic>? commonNames;
  final Map<String, dynamic>? gbif;
  final List<SpeciesImage>? images;
  final Map<String, dynamic>? links;

  PlantResult({
    this.id,
    this.score,
    this.scientificName,
    this.family,
    this.genus,
    this.commonNames,
    this.gbif,
    this.images,
    this.links,
  });

  factory PlantResult.fromJson(Map<String, dynamic> json) {
    return PlantResult(
      id: json['id'],
      score: json['score']?.toDouble(),
      scientificName: json['species']?['scientificName'] as String?,
      family: json['species']?['family']?['scientificName'] as String?,
      genus: json['species']?['genus']?['scientificName'] as String?,
      commonNames: _normalizeCommonNames(json['species']?['commonNames']),
      gbif: json['species']?['gbif'] as Map<String, dynamic>?,
      images: json['species']?['images'] != null
          ? (json['species']['images'] as List)
              .map((item) => SpeciesImage.fromJson(item))
              .toList()
          : null,
      links: json['species']?['links'] as Map<String, dynamic>?,
    );
  }

  static Map<String, dynamic>? _normalizeCommonNames(dynamic value) {
    if (value == null || value is Map<String, dynamic>) {
      return value as Map<String, dynamic>?;
    }
    if (value is List) {
      return {'en': value};
    }
    return null;
  }
}

class SpeciesImage {
  final String? url;
  final String? copyright;
  final String? author;
  final String? license;

  SpeciesImage({
    this.url,
    this.copyright,
    this.author,
    this.license,
  });

  factory SpeciesImage.fromJson(Map<String, dynamic> json) {
    return SpeciesImage(
      url: json['m']?['url'] as String?,
    );
  }
}

class SimilarImage {
  final String? url;
  final String? sourceUrl;

  SimilarImage({
    this.url,
    this.sourceUrl,
  });

  factory SimilarImage.fromJson(Map<String, dynamic> json) {
    return SimilarImage(
      url: json['url'] as String?,
      sourceUrl: json['sourceUrl'] as String?,
    );
  }
}