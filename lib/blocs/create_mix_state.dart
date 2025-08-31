import 'package:equatable/equatable.dart';
import '../../data/tobacco_ingredient.dart';

enum FormStatus { initial, invalid, valid, submissionInProgress, submissionSuccess, submissionFailure }

class CreateMixState extends Equatable {
  final String description;
  final List<TobaccoIngredient> ingredients;
  final String strength;
  final FormStatus status;
  final String? errorMessage;

  const CreateMixState({
    this.description = '',
    this.ingredients = const [],
    this.strength = '',
    this.status = FormStatus.initial,
    this.errorMessage,
  });

  bool get isFormValid =>
      description.length >= 10 &&
      strength.isNotEmpty &&
      ingredients.isNotEmpty &&
      ingredients.every((i) => i.tobacco.isNotEmpty && i.flavor.isNotEmpty && i.percentage > 0);

  CreateMixState copyWith({
    String? description,
    List<TobaccoIngredient>? ingredients,
    String? strength,
    FormStatus? status,
    String? errorMessage,
  }) {
    return CreateMixState(
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      strength: strength ?? this.strength,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [description, ingredients, strength, status, errorMessage];
}
