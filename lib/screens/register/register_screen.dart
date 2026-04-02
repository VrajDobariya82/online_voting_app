import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final voterIdController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    voterIdController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    setState(() => isLoading = true);

    final authProvider = context.read<AppAuthProvider>();
    final error = await authProvider.register(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      voterId: voterIdController.text.trim(),
      password: passwordController.text.trim(),
    );

    if (!mounted) return;

    if (error != null) {
      _showError(error);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration Successful! Logging in...')),
      );
      Navigator.pop(context);
    }

    setState(() => isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 4,
              shadowColor: Colors.black12,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Back to Login
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Back to Login'),
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
        
                      Image.asset('assets/images/logo.png', height: 60),
                      const SizedBox(height: 8),
                      Text(
                        'SmartVote',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                      const Text(
                        'Join SmartVote today',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 32),
        
                      // Full Name
                      _buildLabel('Full Name'),
                      TextFormField(
                        controller: nameController,
                        validator: (value) => value!.isEmpty ? 'Enter your full name' : null,
                        decoration: const InputDecoration(
                          hintText: 'Enter your full name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 16),
        
                      // Email Address
                      _buildLabel('Email Address'),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Enter your email';
                          if (!value.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                        decoration: const InputDecoration(
                          hintText: 'Enter your email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
        
                      // Phone Number
                      _buildLabel('Phone Number'),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                           if (value == null || value.isEmpty) return 'Enter Phone Number';
                           if (value.length < 10) return 'Enter valid phone number (min 10 digits)';
                           return null;
                        },
                        decoration: const InputDecoration(
                          hintText: 'Enter your phone number',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
        
                       // Voter ID 
                      _buildLabel('Voter ID'),
                       TextFormField(
                        controller: voterIdController, 
                        validator: (value) => value!.isEmpty ? 'Enter your Voter ID' : null,
                        decoration: const InputDecoration(
                          hintText: 'Enter your Voter ID',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
        
                      // Password
                      _buildLabel('Password'),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        validator: (value) => value!.length < 6 ? 'Password must be at least 6 chars' : null,
                        decoration: const InputDecoration(
                          hintText: 'Create a password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                      const SizedBox(height: 16),
        
                      // Confirm Password
                      _buildLabel('Confirm Password'),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        validator: (value) => value != passwordController.text ? 'Passwords do not match' : null,
                        decoration: const InputDecoration(
                          hintText: 'Confirm your password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                      const SizedBox(height: 24),
        
                      ElevatedButton(
                        onPressed: isLoading ? null : registerUser,
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Register'),
                      ),
        
                      const SizedBox(height: 16),
        
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
