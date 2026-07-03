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
      return 'Please Enter Password.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    final pattern = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$');
    if (!pattern.hasMatch(value)) {
      return 'The password must contain uppercase, lowercase, and numbers.';
    }
    final username = _usernameController.text.trim();
    if (username.isNotEmpty && value.contains(username)) {
      return 'Password must not contain username.';
    }
    return null;
  }

  // ✅ متد کمکی برای ذخیره با لاگ
  Future<void> _saveUserData(String username, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', username);
      await prefs.setString('password', password);
      await prefs.setBool('isLoggedIn', true);
      
      // ✅ بررسی اینکه ذخیره شده یا نه
      final savedUser = prefs.getString('userName');
      final savedPass = prefs.getString('password');
      final savedLogin = prefs.getBool('isLoggedIn');
      
      print('✅ ذخیره شد:');
      print('Username: $savedUser');
      print('Password: $savedPass');
      print('isLoggedIn: $savedLogin');
      
    } catch (e) {
      print('❌ خطا در ذخیره: $e');
    }
  }

  // ✅ متد کمکی برای خواندن با لاگ
  Future<Map<String, dynamic>> _getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('userName') ?? '';
      final password = prefs.getString('password') ?? '';
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      
      print('📖 اطلاعات خوانده شده:');
      print('Username: $username');
      print('Password: $password');
      print('isLoggedIn: $isLoggedIn');
      
      return {
        'username': username,
        'password': password,
        'isLoggedIn': isLoggedIn,
      };
    } catch (e) {
      print('❌ خطا در خواندن: $e');
      return {
        'username': '',
        'password': '',
        'isLoggedIn': false,
      };
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final password = _passwordController.text;

      if (isLoginMode) {
        // ✅ حالت لاگین
        final userData = await _getUserData();
        final savedUsername = userData['username'] ?? '';
        final savedPassword = userData['password'] ?? '';

        print('🔍 مقایسه:');
        print('ورودی: $username / $password');
        print('ذخیره: $savedUsername / $savedPassword');

        if (savedUsername.isNotEmpty && 
            username == savedUsername && 
            password == savedPassword) {
          
          // ذخیره وضعیت لاگین
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Welcome back, $username!')),
            );
            
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainWrapper(userName: username),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid username or password'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // ✅ حالت ثبت نام
        if (password != _confirmPasswordController.text) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('The password and its repetition do not match.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
        
        // ذخیره اطلاعات
        await _saveUserData(username, password);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainWrapper(userName: username),
            ),
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                height: 300,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 30,
                      width: 80,
                      height: 200,
                      child: FadeInUp(
                        duration: const Duration(seconds: 1),
                        child: Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/light-1.png'),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 140,
                      width: 80,
                      height: 150,
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 1200),
                        child: Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/light-2.png'),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 40,
                      top: 40,
                      width: 80,
                      height: 150,
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 1300),
                        child: Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/clock.png'),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 1600),
                        child: Container(
                          margin: const EdgeInsets.only(top: 50),
                          child: Center(
                            child: Text(
                              isLoginMode ? 'Login' : 'Sign Up',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    FadeInUp(
                      duration: const Duration(milliseconds: 1800),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color.fromRGBO(143, 148, 251, 1)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(143, 148, 251, 1),
                              blurRadius: 20.0,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Username',
                                hintStyle: TextStyle(color: Colors.grey[700]),
                                prefixIcon: const Icon(Icons.person, color: Color.fromRGBO(143, 148, 251, 1)),
                                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your username.';
                                }
                                return null;
                              },
                            ),
                            const Divider(color: Color.fromRGBO(143, 148, 251, 1)),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !isPasswordVisible,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Password",
                                hintStyle: TextStyle(color: Colors.grey[700]),
                                prefixIcon: const Icon(Icons.lock, color: Color.fromRGBO(143, 148, 251, 1)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: const Color.fromRGBO(143, 148, 251, 1),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isPasswordVisible = !isPasswordVisible;
                                    });
                                  },
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                              ),
                              validator: _validatePassword,
                            ),
                            if (!isLoginMode) ...[
                              const Divider(color: Color.fromRGBO(143, 148, 251, 1)),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: !isPasswordVisible,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Confirm Password",
                                  hintStyle: TextStyle(color: Colors.grey[700]),
                                  prefixIcon: const Icon(Icons.lock_clock, color: Color.fromRGBO(143, 148, 251, 1)),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the password again.';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1900),
                      child: GestureDetector(
                        onTap: _submitForm,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromRGBO(143, 148, 251, 1),
                                Color.fromRGBO(143, 148, 251, .6),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              isLoginMode ? "Login" : "Register",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    FadeInUp(
                      duration: const Duration(milliseconds: 2000),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            isLoginMode = !isLoginMode;
                            _passwordController.clear();
                            _confirmPasswordController.clear();
                            _formKey.currentState?.reset();
                          });
                        },
                        child: Text(
                          isLoginMode ? "Don't have an account? Sign Up" : "Already have an account? Login",
                          style: const TextStyle(
                            color: Color.fromRGBO(143, 148, 251, 1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}