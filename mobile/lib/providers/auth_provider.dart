import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/data/models/user_model.dart';
import 'package:mobile/providers/providers.dart';

// Auth State Provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final Ref ref;
  
  AuthNotifier(this.ref) : super(const AsyncValue.loading()) {
    _checkAuth();
  }
  
  Future<void> _checkAuth() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final isLoggedIn = await authRepo.isLoggedIn();
      
      if (isLoggedIn) {
        final user = await authRepo.getCurrentUser();
        state = AsyncValue.data(user);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> login(String phone) async {
    state = const AsyncValue.loading();
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final result = await authRepo.login(phone);
      state = AsyncValue.data(result['user'] as UserModel);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
  
  Future<void> logout() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.logout();
      state = const AsyncValue.data(null);
    } catch (e) {
      // Even if API fails, we still log out locally
      state = const AsyncValue.data(null);
    }
  }
  
  UserModel? get currentUser => state.value;
}
