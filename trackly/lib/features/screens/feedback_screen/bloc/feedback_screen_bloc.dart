import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackly/data/repositories/feedback_repository.dart';

// MARK: Cubit
class FeedbackCubit extends Cubit<FeedbackState> {
  final FeedbackRepository _repo;

  FeedbackCubit(this._repo) : super(const FeedbackState());

  void setMessage(String v) => emit(state.copyWith(message: v));

  Future<bool> submit() async {
    if (!state.isValid) return false;
    emit(state.copyWith(isSubmitting: true));
    try {
      await _repo.sendFeedback(message: state.message.trim());
      emit(state.copyWith(isSubmitting: false));
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false));
      return false;
    }
  }
}

// MARK: State
class FeedbackState {
  final String message;
  final bool isSubmitting;

  const FeedbackState({this.message = '', this.isSubmitting = false});

  bool get isValid => message.trim().isNotEmpty;

  FeedbackState copyWith({String? message, bool? isSubmitting}) =>
      FeedbackState(
        message: message ?? this.message,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );
}
