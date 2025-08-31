import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String uid;
  final String nickname;
  final String? photoUrl;
  final int totalLikes;
  final int followersCount;
  final int followingCount;

  const UserProfile({
    required this.uid,
    required this.nickname,
    this.photoUrl,
    this.totalLikes = 0,
    this.followersCount = 0,
    this.followingCount = 0,
  });

  @override
  List<Object?> get props => [
        uid,
        nickname,
        photoUrl,
        totalLikes,
        followersCount,
        followingCount,
      ];

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      nickname: data['nickname'] ?? '',
      photoUrl: data['photoUrl'] as String?,
      totalLikes: data['totalLikes'] ?? 0,
      followersCount: data['followersCount'] ?? 0, // Assuming these fields exist
      followingCount: data['followingCount'] ?? 0, // Assuming these fields exist
    );
  }
}
