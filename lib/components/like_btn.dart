
import 'package:flutter/material.dart';

class likeButton extends StatelessWidget{
  final bool isLiked;
  void Function()? onTap;

  likeButton({
    super.key,
    required this.isLiked,
    required this.onTap
});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        isLiked ? Icons.favorite: Icons.favorite_border,
        color: isLiked ? Colors.red : Colors.brown,
      ),
    );
  }


}