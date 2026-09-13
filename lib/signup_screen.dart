import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'ld_logo.dart';
import 'templates/transactions/auth_transactions.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final _authTransactions = AuthTransactions();

  bool isSignupLoading = false;
  bool isGoogleLoading = false;

  bool get isLoading => isSignupLoading || isGoogleLoading;

  Future<void> createAccount() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    final emailFormat = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar('Please fill all fields');
      return;
    }

    if (!emailFormat.hasMatch(email)) {
      _showSnackBar('Invalid email format');
      return;
    }

    if (password.length < 8) {
      _showSnackBar('Password must be at least 8 characters');
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar('Passwords do not match');
      return;
    }

    setState(() => isSignupLoading = true);

    try {
      await _authTransactions.createAccount(
        email: email,
        password: password,
      );

      if (!mounted) return;

      _showSnackBar('Account created successfully');

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
    } on FirebaseAuthException catch (e, stackTrace) {
      debugPrint(
        'Email signup Firebase error: code=${e.code}, '
        'message=${e.message}\n$stackTrace',
      );

      if (!mounted) return;

      _showSnackBar('${e.code}: ${e.message ?? 'Account creation failed'}');
    } catch (e, stackTrace) {
      debugPrint('Email signup error: $e\n$stackTrace');
      if (mounted) _showSnackBar('Account creation failed: $e');
    } finally {
      if (mounted) setState(() => isSignupLoading = false);
    }
  }

  Future<void> signInWithGoogle() async {
    setState(() => isGoogleLoading = true);

    try {
      final userCredential = await _authTransactions.signInWithGoogle();
      if (userCredential == null) {
        if (mounted) setState(() => isGoogleLoading = false);
        return;
      }

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e, stackTrace) {
      debugPrint(
        'Google Sign-In Firebase error: code=${e.code}, '
        'message=${e.message}\n$stackTrace',
      );

      if (mounted) {
        _showSnackBar('Google Sign-In failed: ${e.message ?? e.code}');
      }
    } on PlatformException catch (e, stackTrace) {
      debugPrint(
        'Google Sign-In platform error: code=${e.code}, '
        'message=${e.message}\n$stackTrace',
      );

      if (mounted) {
        _showSnackBar('Google Sign-In failed: ${e.message ?? e.code}');
      }
    } catch (e, stackTrace) {
      debugPrint('Google Sign-In error: $e\n$stackTrace');
      if (mounted) _showSnackBar('Google Sign-In failed: $e');
    } finally {
      if (mounted) setState(() => isGoogleLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black45),
      prefixIcon: Icon(icon, color: const Color(0xFFD4AF37)),
      filled: true,
      fillColor: const Color(0xFFFAF8F3),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE9E3D8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFD4AF37),
          width: 1.5,
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.black87),
          decoration: _inputDecoration(hint: hint, icon: icon),
        ),
      ],
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 440),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.person_add_alt_1_outlined,
                    color: Color(0xFFD4AF37),
                    size: 44,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Create your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start managing your cases and diary.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _field(
                    label: 'Email',
                    hint: 'Enter email',
                    icon: Icons.email_outlined,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  _field(
                    label: 'Password',
                    hint: 'Create password',
                    icon: Icons.lock_outline,
                    controller: passwordController,
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  _field(
                    label: 'Confirm Password',
                    hint: 'Confirm password',
                    icon: Icons.lock_outline,
                    controller: confirmPasswordController,
                    obscureText: true,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : createAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        disabledBackgroundColor:
                            const Color(0xFFD4AF37).withValues(alpha: 0.55),
                        foregroundColor: Colors.black87,
                        disabledForegroundColor:
                            Colors.black87.withValues(alpha: 0.55),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isSignupLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.black87,
                              ),
                            )
                          : const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Colors.black12)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.black12)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: isLoading ? null : signInWithGoogle,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        disabledForegroundColor:
                            Colors.black87.withValues(alpha: 0.45),
                        side: const BorderSide(color: Colors.black26),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isGoogleLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Color(0xFFD4AF37),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GoogleLogo(size: 28),
                                SizedBox(width: 8),
                                Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.pushNamed(context, '/login');
                          },
                    child: Text(
                      'Already have an account? Log In',
                      style: TextStyle(
                        color: isLoading
                            ? Colors.black54.withValues(alpha: 0.45)
                            : Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}