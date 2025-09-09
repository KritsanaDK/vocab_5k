import 'package:flutter/material.dart';
import 'package:vocab_5k/Helper/app_colors.dart';

class CustomStepper extends StatelessWidget {
  const CustomStepper({
    super.key,
    required this.lowerLimit,
    required this.upperLimit,
    required this.stepValue,
    required this.iconSize,
    required this.value,
    required this.onChanged,
  });

  final int lowerLimit;
  final int upperLimit;
  final int stepValue;
  final double iconSize;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () {
            int newValue = value <= lowerLimit ? lowerLimit : value - stepValue;
            onChanged(newValue);
          },
        ),

        SizedBox(
          width: iconSize,
          child: Text(
            '$value',
            style: TextStyle(
              fontSize: iconSize * 0.8,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            int newValue = value >= upperLimit ? upperLimit : value + stepValue;
            onChanged(newValue);
          },
        ),
      ],
    );
  }
}
