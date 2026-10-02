import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../env/env.dart';

class GoogleAuthResult {
  const GoogleAuthResult({
    required this.idToken,
    this.accessToken,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  final String idToken;
  final String? accessToken;
  final String? email;
  final String? displayName;
  final String? photoUrl;
}

class GoogleAuthException implements Exception {
  const GoogleAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GoogleAuthService {
  GoogleAuthService({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              serverClientId: Env.googleWebClientId,
              scopes: const ['email', 'profile'],
            );

  final GoogleSignIn _googleSignIn;

  /// Initiates interactive Google Sign-In and extracts ID/Access tokens.
  /// Returns null if the user cancelled the dialog.
  Future<GoogleAuthResult?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        // User aborted the sign-in prompt
        return null;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      final accessToken = auth.accessToken;

      if ((idToken == null || idToken.isEmpty) &&
          (accessToken == null || accessToken.isEmpty)) {
        throw const GoogleAuthException(
          'Google authentication completed, but no authorization token was received. '
          'Check that GOOGLE_WEB_CLIENT_ID is a Web application client ID.',
        );
      }

      return GoogleAuthResult(
        idToken: idToken ?? accessToken!,
        accessToken: accessToken,
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
      );
    } on PlatformException catch (e) {
      if (e.code == 'sign_in_canceled') return null;
      throw GoogleAuthException(_describe(e));
    } on GoogleAuthException {
      rethrow;
    } catch (e) {
      throw GoogleAuthException('Google sign-in failed: $e');
    }
  }

  static String _describe(PlatformException e) {
    final details = '${e.message ?? ''} ${e.details ?? ''}';
    if (e.code == 'network_error') {
      return 'No internet connection. Please check your network and try again.';
    }
    // ApiException 10 = DEVELOPER_ERROR: package name / SHA-1 not registered
    // in Google Cloud, or serverClientId is not a Web application client.
    if (details.contains('ApiException: 10') || details.contains(': 10:')) {
      return 'Google sign-in is not configured for this build (error 10). '
          'Check the SHA-1 fingerprint and Web client ID.';
    }
    if (details.contains('ApiException: 12500')) {
      return 'Google sign-in failed (error 12500). Check the OAuth consent '
          'screen and support email in Google Cloud.';
    }
    return 'Google sign-in failed (${e.code}${e.message != null ? ': ${e.message}' : ''}).';
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }
}
