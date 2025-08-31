import 'package:equatable/equatable.dart';
import '../../data/private_mix.dart';

abstract class MyMixesState extends Equatable {
  const MyMixesState();

  @override
  List<Object> get props => [];
}

class MyMixesInitial extends MyMixesState {}

class MyMixesLoading extends MyMixesState {}

class MyMixesLoaded extends MyMixesState {
  final List<PrivateMix> mixes;

  const MyMixesLoaded(this.mixes);

  @override
  List<Object> get props => [mixes];
}

class MyMixesError extends MyMixesState {
  final String message;

  const MyMixesError(this.message);

  @override
  List<Object> get props => [message];
}
