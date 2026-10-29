/// Photographer categories and role specializations.
class PhotographerCategory {
  const PhotographerCategory({
    required this.id,
    required this.name,
    this.isOperator = false,
  });

  final String id;
  final String name;
  final bool isOperator;

  @override
  String toString() => name;
}

class PhotographerCategories {
  PhotographerCategories._();

  /// Photography & Videography Services
  static const List<String> services = [
    'Traditional Photographer',
    'Traditional Videographer',
    'Candid Photographer',
    'Cinematic Videographer',
    'LED Screens',
    'Drones',
    'Internet Live Streaming',
    'Traditional Photographer Taker',
    'Album Designer',
    'Video Editor',
    'Reels',
    'Printing Labs',
  ];

  /// Operators
  static const List<String> operators = [
    'Candid Photographer',
    'Cinematic Videographer',
    'Traditional Photo Operator',
    'Traditional Video Operator',
    'Candid Photo Operator',
    'Candid Video Operator',
  ];

  /// Backward-compatible aliases
  static const List<String> primaryRoles = services;
  static const List<String> operatorRoles = operators;
  static const List<String> formattedOperatorRoles = operators;

  /// Ordered list of all distinct categories (deduped)
  static const List<String> all = [
    'Traditional Photographer',
    'Traditional Videographer',
    'Candid Photographer',
    'Cinematic Videographer',
    'LED Screens',
    'Drones',
    'Internet Live Streaming',
    'Album Designer',
    'Video Editor',
    'Reels',
    'Photographer',
    'Videography',
    'Traditional Photo Operator',
    'Traditional Video Operator',
    'Candid Photo Operator',
    'Candid Video Operator',
  ];

  /// A generic "Other" category for custom roles
  static const String otherCategory = 'Other';

  /// Canonical check whether a category belongs to operators
  static bool isOperatorRole(String category) {
    final lower = category.trim().toLowerCase();
    return lower == 'photographer' ||
        lower == 'videography' ||
        lower.contains('operator') ||
        lower.contains('taker');
  }
}
