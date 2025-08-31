import 'package:equatable/equatable.dart';

abstract class MyMixesEvent extends Equatable {
  const MyMixesEvent();

  @override
  List<Object> get props => [];
}

class LoadMyMixes extends MyMixesEvent {}

class UpdateMyMix extends MyMixesEvent {
  final String mixId;
  final String newText;
  final List<TobaccoIngredient> newIngredients;
  final String newStrength;

  const UpdateMyMix({
    required this.mixId,
    required this.newText,
    required this.newIngredients,
    required this.newStrength,
  });

  @override
  List<Object> get props => [mixId, newText, newIngredients, newStrength];
}

class DeleteMyMix extends MyMixesEvent {
  final String mixId;

  const DeleteMyMix(this.mixId);

  @override
  List<Object> get props => [mixId];
}
