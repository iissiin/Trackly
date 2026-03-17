import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trackly/core/utils/logger.dart';

abstract class OnboardingEvent {}

class OnboardingAuthWithGoogleEvent extends OnboardingEvent {}

abstract class OnboardingState {}

class OnboardingInitialState extends OnboardingState {}

class OnboardingLoadingState extends OnboardingState {}

class OnboardingSuccessState extends OnboardingState {}

class OnboardingErrorState extends OnboardingState {
  final String message;
  OnboardingErrorState(this.message);
}

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(OnboardingInitialState()) {
    on<OnboardingAuthWithGoogleEvent>(_onAuthWithGoogle);
  }

  FutureOr<void> _onAuthWithGoogle(
    OnboardingAuthWithGoogleEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(OnboardingLoadingState());

    // Имитируем небольшую задержку для вида, будто идет загрузка
    await Future.delayed(const Duration(milliseconds: 500));

    // Просто сразу говорим приложению, что вход "успешен"
    emit(OnboardingSuccessState());

    AppLogger.info('Onboarding: Вход пропущен (заглушка)');
  }

  void _handleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    if (event is GoogleSignInAuthenticationEventSignIn) {
      final storage = FlutterSecureStorage();
      final idToken = event.user.authentication.idToken;
      await storage.write(key: 'idToken', value: idToken);

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final authenticatedUser = userCredential.user;
      if (authenticatedUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(authenticatedUser.uid)
            .set({
              'name': authenticatedUser.displayName ?? '',
              'email': authenticatedUser.email,
              'lastLogin': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

        emit(OnboardingSuccessState());
      }
    }
  }

  void _handleAuthenticationError(Object error) {
    print('onboarding auth error: $error');
  }
}
