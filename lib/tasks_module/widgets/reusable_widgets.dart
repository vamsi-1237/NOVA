import 'package:flutter/material.dart';

Widget labeledTextField({
  required TextEditingController controller,
  required String label,
  int maxLines = 1,
  String? Function(String?)? validator,
}) {
  return TextFormField(controller: controller, decoration: InputDecoration(labelText: label), maxLines: maxLines, validator: validator);
}

Widget primaryButton({required String label, required VoidCallback onPressed}) {
  return ElevatedButton(onPressed: onPressed, child: Text(label));
}

Widget secondaryButton({required String label, required VoidCallback onPressed}) {
  return OutlinedButton(onPressed: onPressed, child: Text(label));
}
