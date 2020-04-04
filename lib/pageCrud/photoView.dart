import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewUrl extends StatefulWidget {

  String urlImage;
  PhotoViewUrl({ this.urlImage });

  @override
  _PhotoViewUrlState createState() => _PhotoViewUrlState();
}

class _PhotoViewUrlState extends State<PhotoViewUrl> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhotoView(
          imageProvider: NetworkImage('${widget.urlImage}'))
    );
  }
}
