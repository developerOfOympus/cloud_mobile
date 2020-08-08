import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';

class VideoPlayerPage extends StatefulWidget {

  final ChewieController controller;
  final String name;
  final String localRoute;
  final String networkRoute;

  VideoPlayerPage({this.name, this.controller, this.localRoute, this.networkRoute});

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {

  @override
  void dispose() {
    widget.controller.videoPlayerController.dispose();
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('Video player'),),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Chewie(
              controller: widget.controller,          
            ),
            ListTile(
              leading: Icon(Icons.video_library),
              title: Text('Video name'),
              subtitle: Text(widget.name ?? "NA"),
            ),
            ListTile(
              leading: Icon(Icons.folder),
              title: Text('Local route'),
              subtitle: Text(widget.localRoute ?? "NA"),
            ),
            ListTile(
              leading: Icon(Icons.network_wifi),
              title: Text('Network route'),
              subtitle: Text(widget.networkRoute.replaceAll('>', '/') ?? "NA"),
            ),
          ],
        ),
      ),
    );
  }
}