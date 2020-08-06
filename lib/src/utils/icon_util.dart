import 'package:flutter/material.dart';

abstract class _ChainOfResponsabiity {

  _ChainOfResponsabiity nextHandler;

  _ChainOfResponsabiity({this.nextHandler});

  Image resolve(String task);
  _ChainOfResponsabiity newRole(_ChainOfResponsabiity role)=>nextHandler=role;

}

class PdfFile extends _ChainOfResponsabiity{


  @override
  Image resolve(String task) {
    if(task.toUpperCase() == 'PDF'){
      return new Image.asset('assets/icons/pdf-icon.png');
    }

    if(nextHandler == null) return null;
    return nextHandler.resolve(task);
  }

}

class Mp4File extends _ChainOfResponsabiity{


  @override
  Image resolve(String task) {
    if(task.toUpperCase() == 'MP4'){
      return new Image.asset('assets/icons/mp4-icon.png');
    }

    if(nextHandler == null) return null;
    return nextHandler.resolve(task);
  }

}

