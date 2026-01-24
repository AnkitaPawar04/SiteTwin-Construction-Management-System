import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/utils/app_logger.dart';
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
final loginActionProvider = FutureProvider.family<UserModel?, String>((ref, phone) async {
  AppLogger.info('Login action started for: $phone');
  final authRepo = ref.read(authRepositoryProvider);
  final result = await authRepo.login(phone);
  
  // Invalidate auth state to ensure fresh state
  ref.invalidateSelf();
  ref.invalidate(authStateProvider);
  
  AppLogger.info('Login action completed, auth state invalidated');
  return result['user'] as UserModel?;
});

// Logout action provider
final logoutActionProvider = FutureProvider<void>((ref) async {
  AppLogger.info('Logout action started');
  final authRepo = ref.read(authRepositoryProvider);
  await authRepo.logout();
  
  // Invalidate auth state to clear user session
  ref.invalidateSelf();
  ref.invalidate(authStateProvider);
  
  AppLogger.info('Logout action completed, auth state invalidated');
});
