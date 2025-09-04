import 'package:cloud_firestore/cloud_firestore.dart';

class Mix {
  final String id;
  final String name;
  final String description;
  final String? image;
  final List<Ingredient> ingredients;
  final String userId;
  final int likes;
  final int views;
  final DateTime createdAt;

  Mix({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    required this.ingredients,
    required this.userId,
    this.likes = 0,
    this.views = 0,
    required this.createdAt,
  });

  factory Mix.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Mix(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      image: data['image'],
      ingredients: (data['ingredients'] as List? ?? [])
          .map((i) => Ingredient.fromMap(i))
          .toList(),
      userId: data['userId'] ?? '',
      likes: data['likes'] ?? 0,
      views: data['views'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'image': image,
      'ingredients': ingredients.map((i) => i.toMap()).toList(),
      'userId': userId,
      'likes': likes,
      'views': views,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class Ingredient {
  final String tobacco;
  final int percentage;

  Ingredient({
    required this.tobacco,
    required this.percentage,
  });

  factory Ingredient.fromMap(Map<String, dynamic> data) {
    return Ingredient(
      tobacco: data['tobacco'] ?? '',
      percentage: data['percentage'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tobacco': tobacco,
      'percentage': percentage,
    };
  }
}
