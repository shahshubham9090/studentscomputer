import 'package:flutter/material.dart';
import 'shimmer_loading.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      if (icon != null) {
        return OutlinedButton.icon(
          onPressed: isLoading ? null : onPressed,
          icon: isLoading 
              ? const ShimmerWidget.rectangular(width: 16, height: 16, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))))
              : Icon(icon),
          label: isLoading ? const ShimmerWidget.rectangular(height: 16, width: 80) : Text(text),
        );
      }
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const ShimmerWidget.rectangular(height: 16, width: 100)
            : Text(text),
      );
    }
    
    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading 
            ? const ShimmerWidget.rectangular(width: 16, height: 16, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))))
            : Icon(icon),
        label: isLoading ? const ShimmerWidget.rectangular(height: 16, width: 80) : Text(text),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const ShimmerWidget.rectangular(height: 16, width: 100)
          : Text(text),
    );
  }
}
