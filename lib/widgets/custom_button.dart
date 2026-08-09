import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final bool outlined;
  final Color? backgroundColor;

  const CustomButton({
    super.key,
    required String text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.outlined = false,
    this.backgroundColor,
  }) : label = text;


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 52,
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    if (outlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        child: Text(label),
      );
    }

    return FilledButton(
      onPressed: onPressed,
      style: backgroundColor != null
          ? FilledButton.styleFrom(backgroundColor: backgroundColor)
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 8)],
          Text(label),
        ],
      ),
    );
  }
}
