import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedImage extends StatelessWidget {
  final String url;
  final Radius imageRadius = const Radius.circular(10);
  const CachedImage({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(


      borderRadius: BorderRadius.only(topLeft: imageRadius,
        topRight: imageRadius,
        bottomLeft: imageRadius,),

      child: CachedNetworkImage(

          imageUrl: url,
          placeholder: (context, url) => const Center(child:  CircularProgressIndicator(color: Colors.white,value: 2,strokeWidth: 2,)),
          errorWidget: (context, url, error) => const Icon(Icons.error)),
    );
  }
}
