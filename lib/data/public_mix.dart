import 'package:equatable/equatable.dart';
import './tobacco_ingredient.dart';

class PublicMix extends Equatable {
  final String id;
  final String name;
  final String author;
  final String authorId;
  final String description;
  final List<TobaccoIngredient> ingredients;
  final String? image;
  final String strength;
  final double rating;
  final int reviews;
  final int likes;
  final int timestamp;

  const PublicMix({
    required this.id,
    required this.name,
    required this.author,
    required this.authorId,
    required this.description,
    required this.ingredients,
    this.image,
    required this.strength,
    required this.rating,
    required this.reviews,
    required this.likes,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        author,
        authorId,
        description,
        ingredients,
        image,
        strength,
        rating,
        reviews,
        likes,
        timestamp,
      ];

  factory PublicMix.fromJson(Map<String, dynamic> json) {
    return PublicMix(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      author: json['author'] ?? '',
      authorId: json['authorId'] ?? '',
      description: json['description'] ?? '',
      ingredients: (json['ingredients'] as List?)
              ?.map((i) => TobaccoIngredient.fromJson(i))
              .toList() ??
          [],
      image: json['image'] as String?,
      strength: json['strength'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: json['reviews'] ?? 0,
      likes: json['likes'] ?? 0,
      timestamp: json['timestamp'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'author': author,
      'authorId': authorId,
      'description': description,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'image': image,
      'strength': strength,
      'rating': rating,
      'reviews': reviews,
      'likes': likes,
      'timestamp': timestamp,
    };
  }
}
