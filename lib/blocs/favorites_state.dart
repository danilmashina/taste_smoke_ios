import 'package:equatable/equatable.dart';
import '../../data/public_mix.dart'; // Assuming favorites are public mixes

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<PublicMix> favoriteMixes;

  const FavoritesLoaded(this.favoriteMixes);

  @override
  List<Object> get props => [favoriteMixes];
}

class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError(this.message);

  @override
  List<Object> get props => [message];
}
