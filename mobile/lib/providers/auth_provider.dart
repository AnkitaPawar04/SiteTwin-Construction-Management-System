import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/data/models/user_model.dart';
import 'package:mobile/providers/providers.dart';

// Simple Auth State Provider - loads current user
final authStateProvider = FutureProvider<UserModel?>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  final isLoggedIn = await authRepo.isLoggedIn();
  
  if (isLoggedIn) {
    return await authRepo.getCurrentUser();
  }
  return null;
});

// Login action provider
final loginActionProvider = FutureProvider.family<void, String>((ref, phone) async {
  final authRepo = ref.read(authRepositoryProvider);
  await authRepo.login(phone);
  // Invalidate auth state to refresh
  ref.invalidate(authStateProvider);
});

// Logout action provider
final logoutActionProvider = FutureProvider<void>((ref) async {
  final authRepo = ref.read(authRepositoryProvider);
  await authRepo.logout();
  // Invalidate auth state to clear
  ref.invalidate(authStateProvider);
});
