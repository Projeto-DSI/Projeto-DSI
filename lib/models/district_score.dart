class DistrictScore {
  final String city;
  final String district;
  final double latitude;
  final double longitude;
  final double leisureScore;
  final double safetyScore;
  final double centerDistanceScore;
  final double premiumPriceScore;
  final double overallScore;
  final double distanceCityCenter;
  final double attractionIndex;
  final double restaurantIndex;
  final double crimeIndex;
  final double safetyIndex;
  final double averagePrice;
  final int sampleSize;

  const DistrictScore({
    required this.city,
    required this.district,
    required this.latitude,
    required this.longitude,
    required this.leisureScore,
    required this.safetyScore,
    required this.centerDistanceScore,
    required this.premiumPriceScore,
    required this.overallScore,
    required this.distanceCityCenter,
    required this.attractionIndex,
    required this.restaurantIndex,
    required this.crimeIndex,
    required this.safetyIndex,
    required this.averagePrice,
    required this.sampleSize,
  });
}
