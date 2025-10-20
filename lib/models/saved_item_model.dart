class SavedItem {
  final String id;
  final String itemType; // 'post' or 'reel'
  final String itemId;
  final String userId; // ID of the user who created the post/reel
  final DateTime savedAt;
  final String? collectionName; // For organizing into collections later

  SavedItem({
    required this.id,
    required this.itemType,
    required this.itemId,
    required this.userId,
    required this.savedAt,
    this.collectionName,
  });

  // Create from JSON (if you need database persistence later)
  factory SavedItem.fromJson(Map<String, dynamic> json) {
    return SavedItem(
      id: json['id'] as String,
      itemType: json['itemType'] as String,
      itemId: json['itemId'] as String,
      userId: json['userId'] as String,
      savedAt: DateTime.parse(json['savedAt'] as String),
      collectionName: json['collectionName'] as String?,
    );
  }

  // Convert to JSON (if you need database persistence later)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemType': itemType,
      'itemId': itemId,
      'userId': userId,
      'savedAt': savedAt.toIso8601String(),
      'collectionName': collectionName,
    };
  }

  // Compare two SavedItems
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          itemId == other.itemId &&
          itemType == other.itemType;

  @override
  int get hashCode => id.hashCode ^ itemId.hashCode ^ itemType.hashCode;

  // Copy with modifications
  SavedItem copyWith({
    String? id,
    String? itemType,
    String? itemId,
    String? userId,
    DateTime? savedAt,
    String? collectionName,
  }) {
    return SavedItem(
      id: id ?? this.id,
      itemType: itemType ?? this.itemType,
      itemId: itemId ?? this.itemId,
      userId: userId ?? this.userId,
      savedAt: savedAt ?? this.savedAt,
      collectionName: collectionName ?? this.collectionName,
    );
  }
}
