import 'package:flutter/material.dart';

abstract class _ChainOfResponsabiity {

  final double _iconSize = 30.0;

  _ChainOfResponsabiity nextHandler;
  _ChainOfResponsabiity({this.nextHandler});

  Image resolve(String task);
  // void open(String fileExtension);
  _ChainOfResponsabiity newRole(_ChainOfResponsabiity role)=>nextHandler=role;

}

class PdfFile extends _ChainOfResponsabiity{


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

class Mp4File extends _ChainOfResponsabiity{


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

class WordFile extends _ChainOfResponsabiity{


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
