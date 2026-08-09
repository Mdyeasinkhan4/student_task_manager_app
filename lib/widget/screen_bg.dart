import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:student_task_manager_app/utils/asset_path.dart';

class ScreenBG extends StatelessWidget {
  final Widget child;
  const ScreenBG({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SvgPicture.asset(
          AssetPath.backgroundSVG,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
        SafeArea(child: child),
      ],
    );
  }
}
