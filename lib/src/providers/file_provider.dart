import 'dart:async';
import 'dart:convert';

import "package:http/http.dart" as http;

class FileProvider {

  final server = "192.168.0.110";
  final port = "3000";

  final fileStream = new StreamController<List<String>>.broadcast();

  Function(List<String>) get newFileData => fileStream.sink.add;
  Stream<List<String>> get fileData => fileStream.stream;

  dispose(){
    fileStream?.close();
  }

  Future<bool> dirElements({String path='_'}) async {

    final uri = "http://$server:$port/directory/$path";

    final response = await http.get(uri);
    final json = jsonDecode(response.body);

    if(json['status']=='error') return false;

    newFileData(List<String>.from(json['files']));
    return true;

  }

  String getFilePath(String path){
    final uri = "http://$server:$port/file/$path";
    return uri;         
  }

  Future<bool> createDirectory(String path)async{
    final uri = "http://$server:$port/directory/$path";

    final response = await http.post(uri);
    final json = jsonDecode(response.body);

    if(json['status']=='error') return false;

    return true;
  }

  Future<bool> removeDirectory(String path)async{
    final uri = "http://$server:$port/directory/$path";

    final response = await http.delete(uri);
    final json = jsonDecode(response.body);

    if(json['status']=='error') return false;

    return true;
  }



}