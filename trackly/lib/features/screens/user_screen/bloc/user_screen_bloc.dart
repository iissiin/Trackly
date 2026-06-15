import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackly/data/repositories/user_repository.dart';

// MARK: State

class UserState {
  final String name;
  final bool notificationsEnabled;
  final bool isSaving;
  final bool isLoading;
  final bool isDeleting;

  const UserState({
    this.name = '',
    this.notificationsEnabled = false,
    this.isSaving = false,
    this.isLoading = false,
    this.isDeleting = false,
  });

  UserState copyWith({
    String? name,
    bool? notificationsEnabled,
    bool? isSaving,
    bool? isLoading,
    bool? isDeleting,
  }) => UserState(
    name: name ?? this.name,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    isSaving: isSaving ?? this.isSaving,
    isLoading: isLoading ?? this.isLoading,
    isDeleting: isDeleting ?? this.isDeleting,
  );
}

// MARK: Cubit

class UserCubit extends Cubit<UserState> {
  final UserRepository _repo;

  UserCubit(this._repo) : super(const UserState()) {
    _load();
  }

  Future<void> _load() async {
    emit(state.copyWith(isLoading: true));
    final user = await _repo.fetchCurrentUser();
    emit(state.copyWith(isLoading: false, name: user?.name ?? ''));
  }

  void setName(String v) => emit(state.copyWith(name: v));

  void toggleNotifications(bool v) {
    // TODO: implement notifications logic later
    emit(state.copyWith(notificationsEnabled: v));
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

  Future<bool> deleteAccount() async {
    emit(state.copyWith(isDeleting: true));
    try {
      await _repo.deleteAccount();
      emit(state.copyWith(isDeleting: false));
      return true;
    } catch (_) {
      emit(state.copyWith(isDeleting: false));
      return false;
    }
  }
}
