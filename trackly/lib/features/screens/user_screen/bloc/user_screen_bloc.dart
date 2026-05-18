import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackly/core/services/notification/notification_service.dart';
import 'package:trackly/data/repositories/user_repository.dart';

// MARK: State
class UserState {
  final String name;
  final bool notificationsEnabled;
  final bool isSaving;
  final bool isLoading;

  const UserState({
    this.name = '',
    this.notificationsEnabled = true,
    this.isSaving = false,
    this.isLoading = false,
  });

  UserState copyWith({
    String? name,
    bool? notificationsEnabled,
    bool? isSaving,
    bool? isLoading,
  }) => UserState(
    name: name ?? this.name,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    isSaving: isSaving ?? this.isSaving,
    isLoading: isLoading ?? this.isLoading,
  );
}

// MARK: Cubit
class UserCubit extends Cubit<UserState> {
  final UserRepository _repo;
  final _notificationService = NotificationService();

  UserCubit(this._repo) : super(const UserState()) {
    _load();
  }

  Future<void> _load() async {
    emit(state.copyWith(isLoading: true));
    final user = await _repo.fetchCurrentUser();
    emit(
      state.copyWith(
        isLoading: false,
        name: user?.name ?? '',
        notificationsEnabled: user?.notificationsEnabled ?? true,
      ),
    );
  }

  void setName(String v) => emit(state.copyWith(name: v));

  Future<bool> toggleNotifications(bool enabled) async {
    if (enabled) {
      final granted = await _notificationService.requestPermissions();

      if (granted) {
        try {
          await _repo.updateNotifications(true);
          emit(state.copyWith(notificationsEnabled: true));
          return true; // успех
        } catch (e) {
          emit(state.copyWith(notificationsEnabled: false));
          return false;
        }
      } else {
        emit(state.copyWith(notificationsEnabled: false));
        return false;
      }
    } else {
      try {
        await _repo.updateNotifications(false);
        emit(state.copyWith(notificationsEnabled: false));
        return true;
      } catch (e) {
        return false;
      }
    }
  }

  Future<bool> saveName() async {
    if (state.name.trim().isEmpty) return false;
    emit(state.copyWith(isSaving: true));
    try {
      await _repo.updateName(state.name.trim());
      emit(state.copyWith(isSaving: false));
      return true;
    } catch (_) {
      emit(state.copyWith(isSaving: false));
      return false;
    }
  }

  Future<void> signOut() => _repo.signOut();
}
