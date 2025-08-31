import 'package:equatable/equatable.dart';

class TobaccoIngredient extends Equatable {
  final String tobacco;
  final String flavor;
  final int percentage;

  const TobaccoIngredient({
    required this.tobacco,
    required this.flavor,
    required this.percentage,
  });

  @override
  List<Object?> get props => [tobacco, flavor, percentage];

  factory TobaccoIngredient.fromJson(Map<String, dynamic> json) {
    return TobaccoIngredient(
      tobacco: json['tobacco'] ?? '',
      flavor: json['flavor'] ?? '',
      percentage: json['percentage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tobacco': tobacco,
      'flavor': flavor,
      'percentage': percentage,
    };
  }
}
