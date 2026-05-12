import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackly/data/repositories/feedback_repository.dart';

// MARK: Cubit
class FeedbackCubit extends Cubit<FeedbackState> {
  final FeedbackRepository _repo;

  FeedbackCubit(this._repo) : super(const FeedbackState());

  void setMessage(String v) => emit(state.copyWith(message: v));
  void setImage(File image) => emit(state.copyWith(image: image));
  void clearImage() => emit(state.copyWith(clearImage: true));

  Future<bool> submit() async {
    if (!state.isValid) return false;
    emit(state.copyWith(isSubmitting: true));
    try {
      await _repo.sendFeedback(
        message: state.message.trim(),
        image: state.image,
      );
      emit(state.copyWith(isSubmitting: false));
      return true;
    } catch (_) {
      emit(state.copyWith(isSubmitting: false));
      return false;
    }
  }
}

// MARK: State
class FeedbackState {
  final String message;
  final File? image;
  final bool isSubmitting;

  const FeedbackState({
    this.message = '',
    this.image,
    this.isSubmitting = false,
  });

  bool get isValid => message.trim().isNotEmpty;

  FeedbackState copyWith({
    String? message,
    File? image,
    bool? isSubmitting,
    bool clearImage = false,
  }) => FeedbackState(
    message: message ?? this.message,
    image: clearImage ? null : (image ?? this.image),
    isSubmitting: isSubmitting ?? this.isSubmitting,
  );
}
