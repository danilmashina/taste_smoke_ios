import 'package:equatable/equatable.dart';
import '../../data/tobacco_ingredient.dart';

abstract class CreateMixEvent extends Equatable {
  const CreateMixEvent();

  @override
  List<Object> get props => [];
}

class DescriptionChanged extends CreateMixEvent {
  final String description;
  const DescriptionChanged(this.description);
  @override
  List<Object> get props => [description];
}

class IngredientsChanged extends CreateMixEvent {
  final List<TobaccoIngredient> ingredients;
  const IngredientsChanged(this.ingredients);
  @override
  List<Object> get props => [ingredients];
}

class StrengthChanged extends CreateMixEvent {
  final String strength;
  const StrengthChanged(this.strength);
  @override
  List<Object> get props => [strength];
}

class SavePrivateMix extends CreateMixEvent {}

class PublishPublicMix extends CreateMixEvent {
  final String category;
  const PublishPublicMix(this.category);
  @override
  List<Object> get props => [category];
}
