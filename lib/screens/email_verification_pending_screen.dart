import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class EmailVerificationPendingScreen extends StatefulWidget {
  const EmailVerificationPendingScreen({super.key});

  @override
  State<EmailVerificationPendingScreen> createState() =>
      _EmailVerificationPendingScreenState();
}

class _EmailVerificationPendingScreenState
    extends State<EmailVerificationPendingScreen> {
  bool _isResending = false;
  int _cooldownSeconds = 0;

  @override
  void initState() {
    super.initState();
    // Start polling to check email verification status
    _startVerificationCheck();
  }

  void _startVerificationCheck() {
    // Check verification status every 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _checkVerificationStatus();
      }
    });
  }

  Future<void> _checkVerificationStatus() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.reloadUser();

    if (mounted && authProvider.emailVerified) {
      // Mark email as verified in Firestore database
      await authProvider.markEmailAsVerified();
      
      // Email verified, navigate to home
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else if (mounted) {
      // Continue checking
      _startVerificationCheck();
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (_cooldownSeconds > 0) return;

    setState(() {
      _isResending = true;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resendVerificationEmail();

    setState(() {
      _isResending = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent! Please check your inbox.'),
            backgroundColor: Colors.green,
          ),
        );
        // Start cooldown timer (60 seconds)
        setState(() {
          _cooldownSeconds = 60;
        });
        _startCooldownTimer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Failed to resend email'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startCooldownTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _cooldownSeconds > 0) {
        setState(() {
          _cooldownSeconds--;
        });
        _startCooldownTimer();
      }
    });
  }

  Future<void> _signOut() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.signOut();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Email'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Email icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.email_outlined,
                    size: 80,
                    color: const Color(0xFF1A237E).withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                const Text(
                  'Check Your Email',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Description
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final email = authProvider.user?.email ?? '';
                    return Text(
                      'We\'ve sent a verification email to:\n$email\n\nPlease click the link in the email to verify your account.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Status indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.hourglass_empty,
                        color: Colors.orange.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Waiting for verification...',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Auto-refresh note
                Text(
                  'This page will automatically update when you verify your email.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Resend button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ElevatedButton.icon(
                      onPressed:
                          (_cooldownSeconds > 0 || _isResending)
                              ? null
                              : _resendVerificationEmail,
                      icon: _isResending
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.refresh),
                      label: Text(
                        _cooldownSeconds > 0
                            ? 'Resend in $_cooldownSeconds seconds'
                            : 'Resend Verification Email',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Sign out button
                TextButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

