part of 'auth_bloc.dart';

/// Classe de base pour les états d'authentification
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// État initial de l'authentification (en cours de vérification)
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// État indiquant que l'authentification est en cours
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// État indiquant que l'utilisateur est authentifié
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// État indiquant que l'utilisateur n'est pas authentifié
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// État indiquant qu'une erreur s'est produite lors de l'authentification
class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
