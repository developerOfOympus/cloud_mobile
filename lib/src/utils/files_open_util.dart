import 'package:flutter/material.dart';

import 'package:chewie/chewie.dart';
import 'package:cloud/src/providers/file_provider.dart';
import 'package:cloud/src/utils/directory_util.dart';
import 'package:cloud/src/utils/patters/chain_of_responsability.dart';
import 'package:cloud/src/utils/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
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

class ImageOpenHandler extends _FileOpenHandler{

  final allowed = ['jpg', 'jpeg', 'png', 'gif'];

  @override
  Future<Widget> resolve(String role) async {
    if(allowed.any((element) => element == role.toLowerCase())){
      
    }

    return await nextHandler.resolve(role);
  }

}

/// You need to include this cass at the end of the chain
class DefaultSystemAppOpen extends _FileOpenHandler{
  @override
  Future<Widget> resolve(String role) async {
    
    final fileURL = _fileProvider.getFilePath(
      "${_directoryHandler.buildPath(null)}>$role"
    );

    if(await canLaunch(fileURL)){
      try{
        await launch(fileURL);
      }catch(e){
        print(e ?? "Error");
      }
      return null;
    }

    return Container();
  }
}
