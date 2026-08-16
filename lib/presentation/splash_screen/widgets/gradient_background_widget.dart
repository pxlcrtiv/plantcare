import 'package:flutter/material.dart';


class GradientBackgroundWidget extends StatelessWidget {
  final Widget child;

  const GradientBackgroundWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.secondary, // Light sage green
            Theme.of(context).colorScheme.primary, // Deep forest green
          ],
          stops: const [0.0, 1.0],
        ),
      ),
      child: child,
    );
  }
}
