import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authControllerProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      final authState = ref.read(authControllerProvider);
      if (authState.hasError) {
         String errorMessage = "Login failed. Please try again.";
         final error = authState.error;
         if (error is FirebaseAuthException) {
           if (error.code == 'user-not-found' || error.code == 'wrong-password' || error.code == 'invalid-credential') {
             errorMessage = "Incorrect email or password.";
           } else if (error.code == 'invalid-email') {
             errorMessage = "The email address is badly formatted.";
           } else {
             errorMessage = error.message ?? errorMessage;
           }
         }
         
         if(mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text(errorMessage),
               backgroundColor: Colors.red,
             ),
           );
         }
      } else {
        if(mounted) context.go('/dashboard');
      }
    }
  }

  void _googleLogin() async {
    final result = await ref.read(authControllerProvider.notifier).googleSignIn();
    
    if (ref.read(authControllerProvider).hasError) {
       if(mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Login Failed: ${ref.read(authControllerProvider).error}"))
         );
       }
    } else if (result != null) {
      // Success - Check if user has children already
      if (mounted) {
        try {
          final childrenSnapshot = await FirebaseFirestore.instance
              .collection('children')
              .where('parentId', isEqualTo: result.user!.uid)
              .limit(1)
              .get();
          
          if (childrenSnapshot.docs.isEmpty) {
            // New user with no child - go to Add Child first!
            if (mounted) context.go('/profile/add-child');
          } else {
            // Existing user with children
            if (mounted) context.go('/dashboard');
          }
        } catch (e) {
             // Fallback to dashboard on error
             if (mounted) context.go('/dashboard');
        }
      }
    }
    // If result is null, it means user canceled, so stay on login screen.
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             const Text('Enter your email to receive a password reset link.'),
             const SizedBox(height: 16),
             TextField(
               controller: emailController,
               decoration: const InputDecoration(
                 labelText: 'Email',
                 prefixIcon: Icon(Icons.email_outlined),
                 border: OutlineInputBorder(),
               ),
               keyboardType: TextInputType.emailAddress,
             ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter your email")));
                 return;
              }
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password reset email sent! Check your inbox.')),
                  );
                }
              } on FirebaseAuthException catch (e) {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Error sending email")));
              }
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset('assets/images/logo.png', height: 120),
                const SizedBox(height: 20),
                Text(
                  "Welcome Back! ✨",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
                  validator: (value) => value!.isEmpty ? 'Please enter password' : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  child: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Login'),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: isLoading ? null : _googleLogin,
                  icon: const Icon(Icons.g_mobiledata, size: 30),
                  label: const Text('Sign in with Google'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () => context.go('/signup'),
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Crafted with ❤️ by",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Image.asset(
                      'assets/images/login logo.png',
                      height: 14,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
