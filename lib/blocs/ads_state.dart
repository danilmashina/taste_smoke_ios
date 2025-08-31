import 'package:equatable/equatable.dart';
import '../../data/ad_banner.dart';

abstract class AdsState extends Equatable {
  const AdsState();

  @override
  List<Object> get props => [];
}

class AdsInitial extends AdsState {}

class AdsLoading extends AdsState {}

class AdsLoaded extends AdsState {
  final List<AdBanner> ads;

  const AdsLoaded(this.ads);

  @override
  List<Object> get props => [ads];
}

class AdsError extends AdsState {
  final String message;

  const AdsError(this.message);

  @override
  List<Object> get props => [message];
}
