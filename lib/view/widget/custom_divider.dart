import 'package:dr_ai/utils/helper/extention.dart';
import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({
    super.key,
    required this.title,
  });
  final String title;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
            child: Divider(
          color: Color.fromARGB(255, 2, 89, 219),
          thickness: 2,
          endIndent: 10,
        )),
        Text(
          title,
          style: context.textTheme.bodySmall,
        ),
        const Expanded(
            child: Divider(
          color: Color.fromARGB(255, 2, 89, 219),
          thickness: 2,
          indent: 10,
        )),
      ],
    );
  }
}
