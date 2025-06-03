import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final TextStyle? textStyle;
  final String hintText;
  final String? labelText;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final IconData icon;
  final Iterable<String>? autofillHints;

  const CustomTextFormField({
    Key? key,
    required this.controller,
    this.textStyle,
    required this.hintText,
    this.labelText,
    this.isPassword = false,
    required this.keyboardType,
    required this.validator,
    required this.icon,
    this.autofillHints,
  }) : super(key: key);

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _isObscured = true; // Password visibility state

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28),
      child: TextFormField(
        controller: widget.controller,
        style: widget.textStyle ?? TextStyle(color: Colors.white),
        obscureText: widget.isPassword ? _isObscured : false,
        // Toggle password visibility
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        autofillHints: widget.autofillHints,
        decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.labelText,
          prefixIcon: Icon(widget.icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),

          // Password Visibility Toggle Button
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured; //  Toggle state
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}
