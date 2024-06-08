

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomDialogWidget extends StatelessWidget {

  final String titre;
  final String artiste;

  const CustomDialogWidget({
    required this.titre,
    required this.artiste,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xffc4f6e1),
          borderRadius: BorderRadius.circular(12,)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 24,
            ),
            Text(titre),
            Text(artiste),
            const SizedBox(
              height: 24,
            ),
          ],
        ),
      ),
    );
  }

}

