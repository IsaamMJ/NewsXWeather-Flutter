import 'package:flutter/material.dart';
import '../../../../core/theme/image_paths.dart';
import 'package:animate_do/animate_do.dart';

class BackgroundSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return SizedBox(
      height: 400,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -40,
            height: 400,
            width: width,
            child: FadeInUp(
              duration: const Duration(seconds: 1),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(ImagePaths.signUpBackground1),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            height: 400,
            width: width + 20,
            child: FadeInUp(
              duration: const Duration(milliseconds: 1000),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(ImagePaths.signUpBackground2),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
