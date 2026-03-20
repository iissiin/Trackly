import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trackly/core/utils/logger.dart';

// ─── Events ───────────────────────────────────────────

abstract class OnboardingEvent {}

class OnboardingAuthWithGoogleEvent extends OnboardingEvent {}

// ─── States ───────────────────────────────────────────

abstract class OnboardingState {}

class OnboardingInitialState extends OnboardingState {}

class OnboardingLoadingState extends OnboardingState {}

class OnboardingSuccessState extends OnboardingState {}

class OnboardingErrorState extends OnboardingState {
  final String message;
  OnboardingErrorState(this.message);
}

// ─── Bloc ─────────────────────────────────────────────

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(OnboardingInitialState()) {
    on<OnboardingAuthWithGoogleEvent>(_onAuthWithGoogle);
  }

  FutureOr<void> _onAuthWithGoogle(
    OnboardingAuthWithGoogleEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(OnboardingLoadingState());

    // Completer позволяет дождаться результата из stream listener
    // и вызвать emit уже внутри этого handler-а (не после его завершения)
    final completer = Completer<OnboardingState>();

    try {
      final GoogleSignIn signIn = GoogleSignIn.instance;

      await signIn.initialize(serverClientId: dotenv.env['WEB_CLIENT_ID']);

      AppLogger.info('Onboarding: GoogleSignIn инициализирован');

      late StreamSubscription sub;
      sub = signIn.authenticationEvents.listen(
        (authEvent) async {
          if (authEvent is GoogleSignInAuthenticationEventSignIn) {
            try {
              final idToken = authEvent.user.authentication.idToken;

              if (idToken == null) {
                AppLogger.error('Onboarding: idToken = null');
                completer.complete(
                  OnboardingErrorState('Не удалось получить токен Google'),
                );
                await sub.cancel();
                return;
              }

              // сохраняем токен
              const storage = FlutterSecureStorage();
              await storage.write(key: 'idToken', value: idToken);

              // входим в Firebase
              final credential = GoogleAuthProvider.credential(
                idToken: idToken,
              );

              final userCredential = await FirebaseAuth.instance
                  .signInWithCredential(credential);
              final user = userCredential.user;

              if (user == null) {
                AppLogger.error('Onboarding: Firebase не вернул пользователя');
                completer.complete(
                  OnboardingErrorState('Firebase не вернул пользователя'),
                );
                await sub.cancel();
                return;
              }

              // сохраняем пользователя в Firestore
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .set({
                    'name': user.displayName ?? '',
                    'email': user.email ?? '',
                    'lastLogin': FieldValue.serverTimestamp(),
                  }, SetOptions(merge: true));

              AppLogger.info('Onboarding: вход выполнен — ${user.email}');
              completer.complete(OnboardingSuccessState());
            } catch (e) {
              AppLogger.error('Onboarding auth error: $e');
              completer.complete(
                OnboardingErrorState('Что-то пошло не так. Попробуй ещё раз.'),
              );
            } finally {
              await sub.cancel();
            }
          }
        },
        onError: (error) async {
          AppLogger.error('Onboarding stream error: $error');
          completer.complete(OnboardingErrorState('Ошибка входа через Google'));
          await sub.cancel();
        },
      );

      signIn.authenticate();
      AppLogger.info('Onboarding: ожидаем выбор аккаунта Google...');

      // ждём результата из listener — emit безопасен пока мы здесь
      final result = await completer.future;
      emit(result);
    } catch (e) {
      AppLogger.error('Onboarding initialize error: $e');
      emit(OnboardingErrorState('Что-то пошло не так. Попробуй ещё раз.'));
    }
  }
}
