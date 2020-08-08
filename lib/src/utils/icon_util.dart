import 'package:cloud/src/utils/patters/chain_of_responsability.dart';
import 'package:flutter/material.dart';

abstract class _IconHandler extends ChainOfResponsabiity<Image, String> {
  final double _iconSize = 30.0;
}

class PdfFile extends _IconHandler{

  @override
  Image resolve(String task) {
    if(task.toUpperCase() == 'PDF'){
      return new Image.asset(
        'assets/icons/pdf-icon.png',
        width: _iconSize,
      );
    }

    if(nextHandler == null) return null;
    return nextHandler.resolve(task);
  }

}

class Mp4File extends _IconHandler{

  @override
  Image resolve(String task) {
    if(task.toUpperCase() == 'MP4'){
      return new Image.asset(
        'assets/icons/mp4-icon.png',
        width: _iconSize,
      );
    }

    if(nextHandler == null) return null;
    return nextHandler.resolve(task);
  }

}

class WordFile extends _IconHandler{

  @override
  Image resolve(String task) {
    if(['DOC', 'DOCX'].any((element) => element == task.toUpperCase())){
      return new Image.asset(
        'assets/icons/word-icon.png',
        width: _iconSize,
      );
    }

    if(nextHandler == null) return null;
    return nextHandler.resolve(task);
  }
}
