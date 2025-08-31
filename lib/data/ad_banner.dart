import 'package:equatable/equatable.dart';

class AdBanner extends Equatable {
  final String imageUrl;
  final String targetUrl;

  const AdBanner({required this.imageUrl, required this.targetUrl});

  @override
  List<Object?> get props => [imageUrl, targetUrl];

  factory AdBanner.fromJson(Map<String, dynamic> json) {
    return AdBanner(
      imageUrl: json['imageUrl'] ?? '',
      targetUrl: json['targetUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'targetUrl': targetUrl,
    };
  }
}
