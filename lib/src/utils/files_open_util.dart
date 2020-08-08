import 'package:chewie/chewie.dart';
import 'package:cloud/src/providers/file_provider.dart';
import 'package:cloud/src/utils/directory_util.dart';
import 'package:cloud/src/utils/patters/chain_of_responsability.dart';
import 'package:cloud/src/utils/video_player.dart';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

abstract class _FileOpenHandler extends ChainOfResponsabiity<Future<Widget>, String>{
  
  static const SUPPORTED_FIES = ["mp4", "mp3", "wav"];
  final _directoryHandler = new UpdateTreeHandler();
  final _fileProvider = new FileProvider();
  final _separator = '>';

  String findExntension(String name){
    final splitted = name.split('.');
    return splitted.last.toLowerCase();
  }

  /// You need to provide the name of the file you're gonna open
  Future<Widget> resolve(String role);
}

class VideoOpenhandler extends _FileOpenHandler{


  @override
  Future<Widget> resolve(String role) async{
    if(_FileOpenHandler.SUPPORTED_FIES.any((element) => findExntension(role)==element)){

      final networkRoute = _fileProvider.getFilePath("${_directoryHandler.buildPath(null)}$_separator$role");
      final videoController = VideoPlayerController.network(
        networkRoute
      );

      await videoController.initialize();

      return VideoPlayerPage(
        name: role,
        controller: ChewieController(
          videoPlayerController: videoController,
          aspectRatio: videoController.value.aspectRatio,
          autoPlay: true,
        ),
        localRoute: _directoryHandler.buildPath(null),
        networkRoute: networkRoute        
      );
    }

    return nextHandler.resolve(role);
  }

}