import 'package:book_store/common/widgets/buttons/elevated_text_button.dart';
import 'package:book_store/common/widgets/login_signup/login_image.dart';
import 'package:book_store/features/screens/verify_email/verify_email.dart';
import 'package:book_store/utils/constants/color.dart';
import 'package:book_store/utils/constants/images.dart';
import 'package:book_store/utils/helpers/helper_functions.dart';
import 'package:book_store/common/widgets/buttons/custom_button.dart';
import 'package:book_store/common/widgets/textfields/custom_textfield.dart';
import 'package:book_store/features/screens/login/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        User? user = userCredential.user;
        if (user != null) {
          await user.sendEmailVerification(); // Send verification email

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text("Verification email sent. Please check your inbox.")),
          );

          // Redirect to email verification screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => VerifyEmailScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = "This email is already registered.";
            break;
          case 'weak-password':
            errorMessage =
                "Your password is too weak. Please use a stronger password.";
            break;
          case 'invalid-email':
            errorMessage = "Invalid email format.";
            break;
          default:
            errorMessage = e.message ?? "An error occurred. Please try again.";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool dark = UHelperFunctions.isDarkMode(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ULoginImage(image: UImages.signUpPage),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SingleChildScrollView(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      decoration: BoxDecoration(
                          color: dark ? UColors.primary : UColors.secondary,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(80),
                              topRight: Radius.circular(80))),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.white,
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
                                if (!RegExp(
                                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                    .hasMatch(value)) {
                                  return "Enter a valid email";
                                }
                                return null;
                              },
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
                            UElevatedTextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()));
                              },
                              text: "Already have an account? Sign in",
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
