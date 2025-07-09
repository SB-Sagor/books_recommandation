import 'package:book_store/widgets/app_colors.dart';
import 'package:book_store/widgets/custome_button.dart';
import 'package:book_store/widgets/custome_textfield.dart';
import 'package:book_store/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> signUpWithEmail(BuildContext context) async {
    final supabase = Supabase.instance.client;

    if (_formKey.currentState!.validate()) {
      try {
        final response = await supabase.auth.signUp(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          emailRedirectTo: 'io.supabase.bookstore://login-callback',
        );

        if (response.user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text("Verification email sent. Please check your inbox.")),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        }
      } on AuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      } catch (e) {  print("❌ Unexpected error: $e"); // 👈 Add this
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An unexpected error occurred.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/signUp.png'),
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
                        color: AppColors.darkCard ,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(80),
                          topRight: Radius.circular(80),
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Sign Up",
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
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
                                if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$')
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
                              keyboardType: TextInputType.text,
                              icon: Icons.lock,
                              validator: (value) {
                                if (value == null || value.length < 6) {
                                  return "Password must be at least 6 characters";
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            CustomTextFormField(
                              controller: confirmPasswordController,
                              hintText: "Confirm your password",
                              labelText: "Confirm Password",
                              isPassword: true,
                              keyboardType: TextInputType.text,
                              icon: Icons.lock_outline,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please confirm your password";
                                }
                                if (value != passwordController.text) {
                                  return "Passwords do not match";
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 24),
                            customButton("Register", () {
                              if (_formKey.currentState!.validate()) {
                                signUpWithEmail(context);
                              }
                            }),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => LoginScreen()),
                                );
                              },
                              child: Text("Already have an account? Sign in"),
                            ),
                          ],
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
