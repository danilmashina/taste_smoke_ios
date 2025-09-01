import 'package:equatable/equatable.dart';
import './tobacco_ingredient.dart';

class PrivateMix extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<TobaccoIngredient> ingredients;
  final String? image;
  final String strength;
  final int timestamp;

  const PrivateMix({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    this.image,
    required this.strength,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        ingredients,
        image,
        strength,
        timestamp,
      ];

  factory PrivateMix.fromJson(Map<String, dynamic> json) {
    return PrivateMix(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      ingredients: (json['ingredients'] as List?)
              ?.map((i) => TobaccoIngredient.fromJson(i))
              .toList() ??
          [],
      image: json['image'] as String?,
      strength: json['strength'] ?? '',
      timestamp: json['timestamp'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'image': image,
      'strength': strength,
      'timestamp': timestamp,
    };
  }

  PrivateMix copyWith({
    String? id,
    String? name,
    String? description,
    List<TobaccoIngredient>? ingredients,
    String? image,
    String? strength,
    int? timestamp,
  }) {
    return PrivateMix(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      image: image ?? this.image,
      strength: strength ?? this.strength,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
