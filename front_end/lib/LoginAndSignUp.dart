import 'package:flutter/material.dart';
import 'MainWrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'SocketService.dart';

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

    if (isLoginMode) return null;

    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    final pattern = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$');
    if (!pattern.hasMatch(value)) {
      return 'Must contain uppercase, lowercase, and numbers.';
    }
    final username = _usernameController.text.trim();
    if (username.isNotEmpty && value.toLowerCase().contains(username.toLowerCase())) {
      return 'Password cannot contain your username.';
    }
    return null;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final password = _passwordController.text;

      if (!SocketService().isConnected) {
        bool connected = await SocketService().connectToServer(host: '10.0.2.2', port: 8085);
        if (!connected) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cannot connect to Java Server. Check if server is running.')),
          );
          return;
        }
      }

      Map<String, dynamic> request = {
        'action': isLoginMode ? 'login' : 'signup',
        'username': username,
        'password': password,
      };

      final response = await SocketService().sendRequest(request);

      if (response['statusCode'] == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userName', username);

        String avatarUrl = '';
        if (response['payload'] != null && response['payload']['avatarUrl'] != null) {
          avatarUrl = response['payload']['avatarUrl'];
          await prefs.setString('avatarUrl', avatarUrl);
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainWrapper(
                userName: username,
                initialAvatarUrl: avatarUrl,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Authentication failed.')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(30, 35, 45, 1),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLoginMode ? "Welcome Back" : "Create Account",
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Please enter username.' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    suffixIcon: IconButton(
                      icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white70),
                      onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: _validatePassword,
                ),
                if (!isLoginMode) ...[
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !isPasswordVisible,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (v) {
                      if (!isLoginMode) {
                        if (v == null || v.isEmpty) return 'Please confirm your password.';
                        if (v != _passwordController.text) return 'Passwords do not match.';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color.fromRGBO(143, 148, 251, 1),
                  ),
                  child: Text(isLoginMode ? "Login" : "Sign Up", style: const TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    isLoginMode = !isLoginMode;
                    _formKey.currentState?.reset();
                  }),
                  child: Text(
                    isLoginMode ? "Don't have an account? Sign Up" : "Already have an account? Login",
                    style: const TextStyle(color: Colors.white70),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}