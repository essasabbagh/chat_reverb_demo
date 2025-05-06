// lib/repositories/user_repository.dart

import 'package:dash_chat_2/dash_chat_2.dart';

import '../services/local_storage_service.dart';

/// Interface for the user repository
abstract class UserRepositoryInterface {
  /// Get the current user ID
  Future<String?> getCurrentUserId();

  /// Get the current user as a ChatUser
  Future<ChatUser> getCurrentChatUser();

  /// Save user ID to local storage
  Future<void> saveUserId(int userId);

  /// Get the current user's authentication token
  Future<String?> getAuthToken();
}

/// Implementation of the user repository
class UserRepository implements UserRepositoryInterface {
  final LocalStorageService _storageService;

  /// Constructor
  UserRepository(this._storageService);

  @override
  Future<String?> getCurrentUserId() async {
    int? userId = _storageService.getUserId();
    return userId?.toString();
  }

  @override
  Future<ChatUser> getCurrentChatUser() async {
    int? userId = _storageService.getUserId();

    if (userId == null) {
      throw Exception('User ID not found');
    }

    return ChatUser(
      id: userId.toString(),
      firstName: 'Me',
      lastName: '',
      profileImage: 'https://avatar.iran.liara.run/public',
    );
  }

  @override
  Future<void> saveUserId(int userId) async {
    await _storageService.saveUserId(userId);
  }

  @override
  Future<String?> getAuthToken() async {
    return _storageService.getToken();
  }
}
