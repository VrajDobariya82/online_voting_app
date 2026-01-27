import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    
    super.dispose();
  }

  // ---------------- EMAIL LOGIN ----------------
  Future<void> loginWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (!mounted) return;
      // Navigator handled by StreamBuilder but we can pushReplacement to be safe or if StreamBuilder is not wrapping the whole app
      // Since main.dart uses StreamBuilder, just popping or doing nothing might trigger rebuild, 
      // but explicitly going to main is fine or just letting the stream update the UI.
      // However, usually LoginScreen is shown when stream is waiting or null. 
      // If we are in LoginScreen, usually we are not in the 'auth' state.
      // Let's just catch errors here. The navigation relies on the stream in main.dart or we can pushReplacement.
      // But typically with StreamBuilder in main, the auth state change will rebuild main.
      // We will leave navigation here just in case.
      // logic in main.dart: if logged in -> MainScreen.
      
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Login failed');
    }
    setState(() => isLoading = false);
  }

  

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
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
                      Image.asset('assets/images/logo.png', height: 80),
                      const SizedBox(height: 16),
                      Text(
                        'SmartVote',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      const Text(
                        'Secure Digital Voting',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                      const SizedBox(height: 32),
  
                      // Voter ID / Email Label
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Voter ID / Email',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: emailController,
                        validator: (val) => val == null || val.trim().isEmpty ? 'Enter Email or Voter ID' : null,
                        decoration: const InputDecoration(
                          hintText: 'Enter your Voter ID or Email',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 16),
  
                      // Password Label
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Password',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Enter Password';
                          if (val.length < 6) return 'Password too short';
                          return null;
                        },
                        decoration: const InputDecoration(
                          hintText: 'Enter your password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                      const SizedBox(height: 24),
  
                      ElevatedButton(
                        onPressed: loginWithEmail,
                        child: const Text('Login'),
                      ),
                      
                      
  
                      const SizedBox(height: 24),
                      
                      // Register Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: Text(
                              'Register',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      if (isLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: CircularProgressIndicator(),
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
}


