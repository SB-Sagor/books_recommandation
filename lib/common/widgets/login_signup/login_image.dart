import 'package:book_store/utils/constants/images.dart';
import 'package:flutter/material.dart';

class ULoginImage extends StatelessWidget {
  const ULoginImage({
    super.key,
    required this.image,
  });
  final String image;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(image),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 20,
          child: Image.asset(
            UImages.light1,
            width: 100,
            height: 180,
          ),
        ),
        Positioned(
          top: 0,
          left: 20,
          child: Image.asset(
            UImages.light2,
            width: 600,
            height: 180,
          ),
        ),
      ],
    );
  }
}
