import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../../services/firebase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _firebaseService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );

        // Navigate to main app flow
        Navigator.pushReplacementNamed(context, '/my-plants-dashboard');
      } on FirebaseAuthException catch (e) {
        String message = 'Login failed. Please try again.';
        if (e.code == 'user-not-found') {
          message = 'No user found with this email.';
        } else if (e.code == 'wrong-password') {
          message = 'Incorrect password.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed. Please try again.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firebaseService.signInWithGoogle();
      Navigator.pushReplacementNamed(context, '/my-plants-dashboard');
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _firebaseService.createUserWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );

        // Navigate to onboarding flow
        Navigator.pushReplacementNamed(context, '/onboarding-flow');
      } on FirebaseAuthException catch (e) {
        String message = 'Sign up failed. Please try again.';
        if (e.code == 'email-already-in-use') {
          message = 'Email is already registered.';
        } else if (e.code == 'weak-password') {
          message = 'Password is too weak.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign up failed. Please try again.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/branding
                Container(
                  width: 25.w,
                  height: 25.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.local_florist,
                    color: Colors.white,
                    size: 12.w,
                  ),
                ),
                
                SizedBox(height: 4.h),
                
                Text(
                  'Welcome to PlantCare',
                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                SizedBox(height: 1.h),
                
                Text(
                  'Sign in to manage your plants',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 4.h),
                
                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: CustomIconWidget(
                      iconName: 'email',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 2.h),
                
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: CustomIconWidget(
                      iconName: 'lock',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 2.h),
                
                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.lightTheme.colorScheme.onPrimary,
                            ),
                          )
                        : Text(
                            'Sign In',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                
                SizedBox(height: 1.h),
                
                // Sign up button
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _signUp,
                    child: Text(
                      'Create Account',
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 2.h),
                
                // Divider with "or"
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppTheme.lightTheme.colorScheme.outline,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Text(
                        'or',
                        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppTheme.lightTheme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 2.h),
                
                // Google sign-in button
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _loginWithGoogle,
                    icon: Image.asset(
                      'assets/images/google_logo.png', // You'll need to add this asset
                      width: 5.w,
                      height: 5.w,
                    ),
                    label: Text(
                      'Continue with Google',
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 3.h),
                
                // Forgot password
                TextButton(
                  onPressed: () {
                    // Implement forgot password functionality
                  },
                  child: Text(
                    'Forgot Password?',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
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