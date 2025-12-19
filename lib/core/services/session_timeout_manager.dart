import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/core/constants/app_constants.dart';
import 'package:surabhi/core/services/storage_service.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:surabhi/injector.dart';

class SessionTimeoutManager extends StatefulWidget {
  final Widget child;
  final Duration sessionDuration;
  final Duration warningDuration;

  const SessionTimeoutManager({
    super.key,
    required this.child,
    this.sessionDuration = AppConstants.sessionDuration,
    this.warningDuration = AppConstants.warningDuration,
  });

  @override
  State<SessionTimeoutManager> createState() => _SessionTimeoutManagerState();
}

class _SessionTimeoutManagerState extends State<SessionTimeoutManager> {
  Timer? _idleTimer;
  Timer? _tokenExpiryCheckTimer;

  @override
  void initState() {
    super.initState();
    _startTimers();
  }

  void _startTimers() {
    _resetIdleTimer();
    // Check token expiry every minute
    _tokenExpiryCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkTokenExpiry();
    });
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _tokenExpiryCheckTimer?.cancel();
    super.dispose();
  }

  // 1. Reset timer on user interaction
  void _onUserInteraction() {
    _resetIdleTimer();
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();
    // If user is idle for (Session - Warning) duration, show warning
    final idleWarningTime = widget.sessionDuration - widget.warningDuration;
    _idleTimer = Timer(idleWarningTime, _showExtendSessionDialog);
  }

  // 2. Check actual Token Expiry (in case app was in background)
  Future<void> _checkTokenExpiry() async {
    final prefs = sl<StorageService>();
    final expiry = prefs.getTokenExpiry();

    if (expiry != null) {
      final timeUntilExpiry = expiry.difference(DateTime.now());

      // If token expires in less than warning duration, show dialog
      if (timeUntilExpiry < widget.warningDuration && timeUntilExpiry > Duration.zero) {
        if (mounted && Navigator.of(context).canPop() == false) {
          // check canPop to ensure we don't stack dialogs
          _showExtendSessionDialog();
        }
      }
      // If already expired, force logout
      if (timeUntilExpiry.isNegative) {
        context.read<AuthBloc>().add(LogoutRequested());
      }
    }
  }

  // 3. The Dialog
  void _showExtendSessionDialog() {
    // Only show if user is authenticated
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Session Expiring'),
        content: const Text('Your session is about to expire due to inactivity. Would you like to extend it?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(LogoutRequested());
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // Trigger Refresh Logic
              context.read<AuthBloc>().add(SessionExtendRequested());
              _resetIdleTimer();
            },
            child: const Text('Extend Session'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Detect taps/pan to reset idle timer
    return Listener(
      onPointerDown: (_) => _onUserInteraction(),
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}
