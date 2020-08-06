import 'package:cloud/src/providers/file_provider.dart';
import 'package:cloud/src/utils/icon_util.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {

  final fileProvider = new FileProvider();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String relativePath = "";
  Mp4File mp4Support = new Mp4File();

  @override
  void initState() {
    widget.fileProvider.dirElements().then((element){
      print(element);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text('Olimpo Cloud'),
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.cloud_upload),
            label: Text('upload'),
            onPressed: (){}
          ),
          FlatButton.icon(
            icon: Icon(Icons.home),
            label: Text('Home'),
            onPressed: ()async{
              relativePath = "";
              await widget.fileProvider.dirElements();
            },
          )
        ],
      ),

      body: _getElements()

    );
  }

  Widget _getElements() {
    return StreamBuilder(
      stream: widget.fileProvider.fileData,
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        
        if(!snapshot.hasData){
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final List<String> elements = snapshot.data;

        // Some action if there are no elements
        if(elements.length == 0){
          return ListTile(
            title: Text('This directory is empty'),
          );
        }

        return ListView.builder(
          itemCount: elements.length,
          itemBuilder: (context, index){

            final fileSplitted = elements[index].split('.');
            final ext = fileSplitted[fileSplitted.length - 1];
            bool folder = ext.length>3;

            return ListTile(
              title: Text(elements[index] ?? 'NA'),
              leading: folder? Icon(Icons.folder):mp4Support.resolve(ext)??Icon(Icons.info),
              trailing: folder?Icon(Icons.arrow_forward_ios):null,
              onTap: ()async{
                relativePath += relativePath.length==0? elements[index]:"-${elements[index]}";
                print(relativePath);
                await widget.fileProvider.dirElements(path: relativePath);
              },
            );

          }
        );

      },
    );
  }
}