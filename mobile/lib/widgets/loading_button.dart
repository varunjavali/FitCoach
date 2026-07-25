import 'package:flutter/material.dart';

class LoadingButton extends StatelessWidget {
  final bool loading;
  final String text;
  final VoidCallback? onPressed;

  const LoadingButton({
    super.key,
    required this.loading,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? const CircularProgressIndicator(
                color: Colors.white,
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
      ),
    );
  }
}