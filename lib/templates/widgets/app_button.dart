import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.outlined = false,
    this.child,
    this.loadingColor = const Color(0xFFD4AF37),
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;
  final Widget? child;
  final Color loadingColor;

  @override
  Widget build(BuildContext context) {
    final buttonChild = child ?? Text(label);
    final loadingChild = SizedBox(
      height: 22,
      width: 22,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: loadingColor,
      ),
    );

    return SizedBox(
      height: 52,
      width: double.infinity,
      child: outlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                disabledForegroundColor: Colors.black87.withValues(alpha: 0.45),
                side: const BorderSide(color: Colors.black26),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isLoading ? loadingChild : buttonChild,
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                disabledBackgroundColor:
                    const Color(0xFFD4AF37).withValues(alpha: 0.55),
                foregroundColor: Colors.black87,
                disabledForegroundColor:
                    Colors.black87.withValues(alpha: 0.55),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isLoading ? loadingChild : buttonChild,
            ),
    );
  }
}
