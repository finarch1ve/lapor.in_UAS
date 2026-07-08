import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../models/user_model.dart';
import '../config/supabase_config.dart';

/// App Auth State
class AppAuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? errorMessage;

  AppAuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.errorMessage,
  });

  AppAuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    String? errorMessage,
  }) {
    return AppAuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Auth StateNotifier
class AuthNotifier extends StateNotifier<AppAuthState> {
  AuthNotifier() : super(AppAuthState()) {
    _initialize();
  }

  /// Initialize and check existing session
  Future<void> _initialize() async {
    try {
      if (!SupabaseConfig.isConfigured) {
        debugPrint('Supabase not configured');
        return;
      }

      final session = SupabaseConfig.client.auth.currentSession;
      if (session != null) {
        await _fetchUser(session.user.id);
      }
    } catch (e) {
      debugPrint('Auth init error: $e');
      // Don't crash - just stay unauthenticated
    }
  }

  /// Fetch user data from users table
  Future<void> _fetchUser(String userId) async {
    try {
      final response = await SupabaseConfig.client
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      if (response != null) {
        state = state.copyWith(
          isAuthenticated: true,
          user: UserModel.fromJson(response),
        );
      }
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await SupabaseConfig.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Try fetch user, but don't block if it fails
        try {
          await _fetchUser(response.user!.id);
        } catch (e) {
          debugPrint('Fetch user error (non-critical): $e');
          // Create minimal user from auth data
          state = state.copyWith(
            isAuthenticated: true,
            user: UserModel(
              id: response.user!.id,
              email: response.user!.email ?? email,
              name: response.user!.userMetadata?['name'] ?? 'User',
              role: response.user!.userMetadata?['role'] ?? 'user',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
        }
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Login gagal. Periksa email dan password.',
        );
        return false;
      }
    } on sb.AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Terjadi kesalahan: ${e.toString()}',
      );
      return false;
    }
  }

  /// Register new user
  Future<bool> register(String name, String email, String password,
      {String? studentId, String? className}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 1. Create auth user
      final response = await SupabaseConfig.client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (response.user != null) {
        // 2. Create user record in users table
        final userId = response.user!.id;
        final userData = {
          'id': userId,
          'email': email,
          'name': name,
          'role': 'user', // Default role
          if (studentId != null) 'student_id': studentId,
          if (className != null) 'class_name': className,
        };

        await SupabaseConfig.client.from('users').insert(userData);

        // 3. Fetch and set user
        await _fetchUser(userId);
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Registrasi gagal. Silakan coba lagi.',
        );
        return false;
      }
    } on sb.AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Terjadi kesalahan: ${e.toString()}',
      );
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await SupabaseConfig.client.auth.signOut();
      state = AppAuthState();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await SupabaseConfig.client.auth.resetPasswordForEmail(email);
      state = state.copyWith(isLoading: false);
      return true;
    } on sb.AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Terjadi kesalahan: ${e.toString()}',
      );
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    final user = state.user;
    if (user == null) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await SupabaseConfig.client
          .from('users')
          .update(data)
          .eq('id', user.id);

      await _fetchUser(user.id);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal update profil: ${e.toString()}',
      );
      return false;
    }
  }
}

/// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AppAuthState>((ref) {
  return AuthNotifier();
});

/// Current User Provider
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

/// Is Admin Provider
final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider)?.isAdmin ?? false;
});

/// Is Helpdesk Provider
final isHelpdeskProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider)?.isHelpdesk ?? false;
});

/// Is User Provider
final isUserProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider)?.isUser ?? false;
});
