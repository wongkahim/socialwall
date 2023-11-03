import 'package:flutter/material.dart';

class EditButton extends StatelessWidget {
  final IconData iconData;
  final void Function()? onTap;

  const EditButton({
    super.key,
    required this.onTap,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        iconData,
        color: Colors.grey,
      ),
    );
  }
}
