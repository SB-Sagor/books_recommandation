import 'package:book_store/screens/bottom_NavigationBar.dart';
import 'package:book_store/widgets/app_colors.dart';
import 'package:book_store/widgets/custome_button.dart';
import 'package:book_store/widgets/custome_textfield.dart';
import 'package:book_store/screens/forgot_password_screen.dart';
import 'package:book_store/screens/register_screen.dart';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> loginWithEmail() async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (response.session != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavigationbar()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed. Please try again.')),
        );
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print("🧱 LoginScreen is building...");
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/loginPage.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 20,
                  child: Image.asset('images/light-1.png',
                      width: 100, height: 180),
                ),
                Positioned(
                  top: 0,
                  left: 20,
                  child: Image.asset('images/light-2.png',
                      width: 600, height: 180),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SingleChildScrollView(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      decoration: BoxDecoration(
                        color: AppColors.darkCard,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(80),
                          topRight: Radius.circular(80),
                        ),
                      ),
<<<<<<< HEAD
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Sign In",
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              CustomTextFormField(
                                controller: emailController,
                                labelText: "Email",
                                hintText: "Enter your email",
                                keyboardType: TextInputType.emailAddress,
                                icon: Icons.email,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter your email";
                                  }
                                  if (!RegExp(
                                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                      .hasMatch(value)) {
                                    return "Enter a valid email";
                                  }
                                  return null;
                                },
                                autofillHints: [AutofillHints.email],
                              ),
                              SizedBox(height: 16),
                              CustomTextFormField(
                                controller: passwordController,
                                hintText: "Enter your password",
                                labelText: "Password",
                                isPassword: true,
                                keyboardType: TextInputType.visiblePassword,
                                icon: Icons.lock,
                                validator: (value) {
                                  if (value == null || value.length < 6) {
                                    return "Password must be at least 6 characters";
                                  }
                                  return null;
                                },
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => ForgotPasswordScreen()),
                                  );
                                },
                                child: Text("Forgot Password?",
                                    style: TextStyle(color: Colors.deepPurple)),
                              ),
                              customButton("Login", () {
                                if (_formKey.currentState!.validate()) {
                                  loginWithEmail();
                                }
                              }),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => RegisterScreen()),
                                  );
                                },
                                child: Text("Don't have an account? Sign up"),
                              ),
                            ],
                          ),
=======
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Sign In",
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            CustomTextFormField(
                              controller: emailController,
                              labelText: "Email",
                              hintText: "Enter your email",
                              keyboardType: TextInputType.emailAddress,
                              icon: Icons.email,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your email";
                                }
                                if (!RegExp(
                                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                    .hasMatch(value)) {
                                  return "Enter a valid email";
                                }
                                return null;
                              },
                              autofillHints: [AutofillHints.email],
                            ),
                            SizedBox(height: 16),
                            CustomTextFormField(
                              controller: passwordController,
                              hintText: "Enter your password",
                              labelText: "Password",
                              isPassword: true,
                              keyboardType: TextInputType.visiblePassword,
                              icon: Icons.lock,
                              validator: (value) {
                                if (value == null || value.length < 6) {
                                  return "Password must be at least 6 characters";
                                }
                                return null;
                              },
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => ForgotPasswordScreen()),
                                );
                              },
                              child: Text("Forgot Password?",
                                  style: TextStyle(color: Colors.deepPurple)),
                            ),
                            customButton("Login", () {
                              if (_formKey.currentState!.validate()) {
                                loginWithEmail();
                              }
                            }),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => RegisterScreen()),
                                );
                              },
                              child: Text("Don't have an account? Sign up"),
                            ),
                          ],
>>>>>>> 223e400a9fed6310856748d60103d4e3d98e3524
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
