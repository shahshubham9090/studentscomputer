import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final int maxLines;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? hintText;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.maxLines = 1,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.hintText,
    this.enabled = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      enabled: widget.enabled,
      keyboardType: widget.keyboardType,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
        ),
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
      ),
      validator: widget.validator,
    );
  }

  @override
  void didUpdateWidget(covariant CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.obscureText != oldWidget.obscureText) {
      _obscureText = widget.obscureText;
    }
  }
}
