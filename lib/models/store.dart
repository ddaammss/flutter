class Store {
  final String id;
  final String name;
  final String category;
  final double rating;
  final int reviewCount;
  final String location;
  final String description;
  final List<String> services;
  final String operatingHours;
  final int price;

  Store({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.location,
    required this.description,
    required this.services,
    required this.operatingHours,
    required this.price,
  });
}
