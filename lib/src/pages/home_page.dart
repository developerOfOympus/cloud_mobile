import 'package:cloud/src/providers/file_provider.dart';
import 'package:cloud/src/utils/icon_util.dart';
import 'package:cloud/src/utils/webview.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {

  final fileProvider = new FileProvider();
  final separator = '>';
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final dirFormKey = GlobalKey<FormState>();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String relativePath = "";
  Mp4File mp4Support = new Mp4File();

  
  _HomePageState(){
    // Increasing responsabiity
    mp4Support..newRole(new WordFile())
               .newRole(new PdfFile());
  }

  @override
  void initState() {
    widget.fileProvider.dirElements().then((element){
      print(element);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        key: widget.scaffoldKey,
        appBar: _getAppBar(),
        body: _getElements(),
        // bottomNavigationBar: _getBottomNavigationBar(),
        bottomSheet: _getBottomSheet(),
      ),
    );
  }

  // This is going to be the body of the scaffold
  Widget _getElements() {
    return StreamBuilder(
      stream: widget.fileProvider.fileData,
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        
        if(!snapshot.hasData){
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        // Some action if there are no elements
        if(snapshot.data.length == 0){
          return ListTile(
            title: Text('This directory is empty'),
          );
        }

        // See the definition under
        return _getDirectories(snapshot.data);

      },
    );
  }

  /// 
  /// It's perfect to avoid the closed of the app
  Future<bool> onWillPop()async{
    List<String> splitted = relativePath.split(widget.separator);
    
    if(splitted.length<=1){
      relativePath = "";
      await widget.fileProvider.dirElements();
    }else{
      splitted.removeLast();
      relativePath = splitted.join(widget.separator);
      await widget.fileProvider.dirElements(path: relativePath);
    }
    
    // false here means that return button has no action
    return false;
  }

  Widget _getAppBar() {
    return AppBar(
      title: Text('Olympus Cloud'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.cloud_upload),
          onPressed: (){}
        ),
        IconButton(
          icon: Icon(Icons.home),
          onPressed: ()async{
            relativePath = "";
            await widget.fileProvider.dirElements();
          },
        )
      ],
    );
  }

  /// This return a structure like the fie explorer of your phone
  Widget _getDirectories(List<String> elements) {
    return Column(
      children: <Widget>[
        _getDirectoryAddress(),
        Divider(),
        Expanded(
          child: _getDirectoryListView(elements)
        ),
      ],
    );
  }

  /// This is something like the address bar in your browser
  Widget _getDirectoryAddress() {
    return ListTile(
      leading: Icon(Icons.folder_open),
      title: Text(
        this.relativePath.split(widget.separator).last==""? "HOME":
                  this.relativePath.split(widget.separator).last.toUpperCase(),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      subtitle: Text(
        "home\\${this.relativePath.replaceAll(widget.separator, '\\')}",
      ),
    );
  }

  /// 
  /// These are the directories as such
  Widget _getDirectoryListView(List<String> elements) {
    return ListView.builder(
      itemCount: elements.length,
      itemBuilder: (BuildContext context, int index){

        final fileSplitted = elements[index].split('.');
        final ext = fileSplitted[fileSplitted.length - 1];

        // Foders can't be splitted in more than two elements since they don't contain '.'
        bool folder = fileSplitted.length==1;

        return ListTile(
          title: Text(elements[index] ?? 'NA'),
          leading: folder?Icon(Icons.folder):mp4Support.resolve(ext)??Icon(Icons.info),
          trailing: folder?Icon(Icons.arrow_forward_ios):null,
          onLongPress: ()async{

            showDialog(
              context: context,
              barrierDismissible: false,
              child: AlertDialog(
                title: Text('Warning!'),
                content: Text('Do you want to delete this directory? [${elements[index]}]'),
                actions: <Widget>[
                  FlatButton.icon(
                    icon: Icon(Icons.cancel),
                    label: Text('Cancel'),
                    onPressed: ()=>Navigator.of(context).pop(),
                  ),
                  FlatButton.icon(
                    icon: Icon(Icons.check_circle),
                    color: Colors.red,
                    label: Text('Delete'),
                    onPressed: ()async{                            
                      final path = relativePath == ""? elements[index]:"$relativePath${widget.separator}${elements[index]}";
                      final res = await widget.fileProvider.removeDirectory(path);
                      
                      if(res){
                        await widget.fileProvider.dirElements(path: relativePath != ""? relativePath:"_");
                      }
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ),
              
            );
          },
          onTap: ()async{
            if(folder){
              relativePath += relativePath.length==0? elements[index]:"${widget.separator}${elements[index]}";
              await widget.fileProvider.dirElements(path: relativePath);
            }else{
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context)=>WebView(
                    url: widget.fileProvider.getFilePath("$relativePath${widget.separator}${elements[index]}"),
                    name: elements[index]
                  )
                )
              );
            }
          },
        );

      }
    );
  }

  Widget _getBottomSheet() {

    return BottomSheet(
      builder: (BuildContext context){
        return Container(
          color: ThemeData.dark().cardColor,
          height: 60.0,
          child: Row(
            children: <Widget>[
              FlatButton.icon(
                onPressed: (){

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    child: AlertDialog(
                      content: Form(
                        key: widget.dirFormKey,
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: "Directory name",
                            hintText: "Directory name",
                            prefixIcon: Icon(Icons.create_new_folder)
                          ),
                          onSaved: (String value)async{
                            final path = relativePath == ""? value:"$relativePath${widget.separator}$value";
                            widget.fileProvider.createDirectory(path);
                            widget.fileProvider.dirElements(path: relativePath);
                          },
                          validator: (String text){

                            final hasDot = text.contains('.');
                            final hasSep = text.contains(widget.separator);
                            final hasSlash = text.contains('/');
                            final hasInvSash = text.contains('\\');

                            if(hasDot || hasSep || hasSlash || hasInvSash){
                              return "Directory name is invalid";
                            }

                            return null;

                          },
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton.icon(
                          icon: Icon(Icons.cancel),
                          label: Text('Cancel'),
                          onPressed: ()=>Navigator.of(context).pop(),
                        ),
                        FlatButton.icon(
                          icon: Icon(Icons.check_circle),
                          label: Text('Create'),
                          onPressed: (){
                            if(widget.dirFormKey.currentState.validate()){

                              widget.dirFormKey.currentState.save();
                              Navigator.of(context).pop();

                              if(relativePath == ""){
                                widget.fileProvider.dirElements();
                              }
                              else{
                                widget.fileProvider.dirElements(path: relativePath);                                
                              }
                            }
                          },
                        )
                      ],
                    )
                  );
                }, 
                icon: Icon(Icons.create_new_folder), 
                label: Text('New Folder'),
              )
            ],
          ),
        );
      },
      onClosing: (){},
    );

  }
}