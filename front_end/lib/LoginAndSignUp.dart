import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'MainWrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginAndSignUp extends StatefulWidget {
  const LoginAndSignUp({super.key});

  @override
  State<LoginAndSignUp> createState() => _LoginAndSignUpState();
}

class _LoginAndSignUpState extends State<LoginAndSignUp> {
  bool isLoginMode = true;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    final pattern = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$');
    if (!pattern.hasMatch(value)) {
      return 'Must contain uppercase, lowercase, and numbers.';
    }
    final username = _usernameController.text.trim();
    if (username.isNotEmpty && value.contains(username)) {
      return 'Password must not contain the username.';
    }
    return null;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final password = _passwordController.text;
      final prefs = await SharedPreferences.getInstance();

      if (isLoginMode) {
        final isBanned = prefs.getBool('banned_$username') ?? false;
        if (isBanned) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your account has been banned by the admin!'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final savedPassword = prefs.getString('pass_$username');
        
        if (savedPassword == null) {
          await prefs.setString('pass_$username', password);
          await prefs.setString('userName', username);
          await prefs.setBool('isLoggedIn', true);
        } else if (savedPassword != password) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Incorrect password! This is not your password.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        await prefs.setString('userName', username);
        await prefs.setBool('isLoggedIn', true);
      } else {
        if (password != _confirmPasswordController.text) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Passwords do not match!'), backgroundColor: Colors.red),
          );
          return;
        }
        await prefs.setString('pass_$username', password);
        await prefs.setString('userName', username);
        await prefs.setBool('isLoggedIn', true);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainWrapper(userName: username),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 100),
              Text(
                isLoginMode ? "Welcome Back" : "Create Account",
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: "Username"),
                      validator: (v) => v!.isEmpty ? "Enter username" : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: "Password",
                        suffixIcon: IconButton(
                          icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                        ),
                      ),
                      validator: _validatePassword,
                    ),
                    if (!isLoginMode) ...[
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: "Confirm Password"),
                      ),
                    ],
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: const Color.fromRGBO(143, 148, 251, 1),
                      ),
                      child: Text(isLoginMode ? "Login" : "Sign Up", style: const TextStyle(color: Colors.white)),
                    ),
                    TextButton(
                      onPressed: () => setState(() => isLoginMode = !isLoginMode),
                      child: Text(isLoginMode ? "Don't have an account? Sign Up" : "Already have an account? Login"),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}