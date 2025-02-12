import 'package:book_store/custome_button.dart';
import 'package:book_store/custome_textfield.dart';
import 'package:book_store/email_verification_screen.dart';
import 'package:book_store/login_screen.dart';
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
    return Scaffold(
      backgroundColor: Colors.black,
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
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(360)),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 20,
                  child: Image.asset(
                    'images/light-1.png',
                    width: 100,
                    height: 180,
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 20,
                  child: Image.asset(
                    'images/light-2.png',
                    width: 600,
                    height: 180,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
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
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()));
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
    );
  }
}
