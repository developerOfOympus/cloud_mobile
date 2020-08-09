import 'package:cloud/src/providers/file_provider.dart';
import 'package:cloud/src/utils/alert_util.dart';
import 'package:cloud/src/utils/directory_util.dart';
import 'package:cloud/src/utils/files_open_util.dart';
import 'package:cloud/src/utils/icon_util.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {

  final _fileOpenHandler = new VideoOpenhandler();
  final _directoryHandler = new UpdateTreeHandler();
  final _mp4Support = new Mp4File();

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final dirFormKey = new GlobalKey<FormState>();
  final fileProvider = new FileProvider();
  final alertUtil = new AlertUtil();

  HomePage(){
    // Increasing responsabiity in icons
    _mp4Support..newRole(new WordFile())
                .newRole(new PdfFile());

    // Increasing responsability in directory operations
    _directoryHandler..newRole(new MoveNextBack())
                      .newRole(new DeleteHandler());

    _fileOpenHandler..newRole(new DefaultSystemAppOpen());
  }

  @override
  Widget build(BuildContext context) {    
    _directoryHandler.goHome();
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        key: scaffoldKey,
        appBar: _getAppBar(),
        body: _getElements(),
        persistentFooterButtons: _getBottomSheet(context),
      ),
    );
  }

  /// 
  /// It's perfect to avoid the closed of the app
  Future<bool> onWillPop()async{    
    await _directoryHandler.resolve(["moveBack", null]);
    await _directoryHandler.resolve(["update", null]);
    // false here means that return button has no action
    return false;
  }

  /// This is the general app bar, what you see in the top of the page
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
          onPressed: ()async=>await _directoryHandler.goHome(),
        )
      ],
    );
  }

  /// This is going to be the body of the scaffold
  Widget _getElements() {
    return StreamBuilder(
      stream: _directoryHandler.dirStream,
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
        
        /// This buid the structure of the explorer, with an address
        /// bar an a body with files and folders
        return Column(
          children: <Widget>[
            _getDirectoryAddressBar(),
            Divider(),
            Expanded(child: _getDirectoryListView(snapshot.data)),
          ],
        );
      },
    );
  }

  /// This is the address bar of the file explorer
  Widget _getDirectoryAddressBar() {
    return ListTile(
      leading: Icon(Icons.folder_open),
      title: Text(
        _directoryHandler.currentDirectory,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      subtitle: Text(_directoryHandler.currentPath),
    );
  }

  /// This is the dorectory tree
  Widget _getDirectoryListView(List<String> elements) {
    return ListView.builder(
      itemCount: elements.length,
      itemBuilder: (BuildContext context, int index){
        return _getFolderOrFile(context, elements[index]);
      }
    );
  }

  /// This is for the directory tree, it shows a folder icon
  /// or a specific icon for each file. It's a molecule element
  /// of the directory tree
  Widget _getFolderOrFile(BuildContext context, String element){
    final fileSplitted = element.split('.');
    final ext = fileSplitted[fileSplitted.length - 1];

    // Foders can't be splitted in more than two elements since they don't contain '.'
    bool folder = ext.length>4 || fileSplitted.length == 1;

    return ListTile(
      title: Text(element ?? 'NA'),
      leading: folder?Icon(Icons.folder):_mp4Support.resolve(ext)??Icon(Icons.info),
      trailing: folder?Icon(Icons.arrow_forward_ios):null,
      onLongPress: ()async{ // To delete a directory
        alertUtil.showAlertOkCancel(              
          title: "Warning!",
          context: context,
          content: Text('Do you want to delete this directory? [$element]'),
          onPressed: ()async{    
            BuildContext alertContext;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context){
                alertContext = context;
                return Container(
                  color: Colors.transparent,
                  child: Center(child: CircularProgressIndicator()),
                );    
              },    
            );            

            await _directoryHandler.resolve(["delete", element]);
            await _directoryHandler.resolve(["update", null]);

            Navigator.of(alertContext).pop();
            Navigator.of(context).pop();
            /// Killing the loading alert
          },
        );
      },
      onTap: ()async{ // To navigate/open a file
        BuildContext alertContext;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context){
            alertContext = context;
            return Container(
              color: Colors.transparent,
              child: Center(child: CircularProgressIndicator()),
            );    
          },    
        );             

        if(folder){
          await _directoryHandler.resolve(['moveNext', element]);
          await _directoryHandler.resolve(["update", null]);    
          /// Killing the loading alert
          Navigator.of(alertContext).pop();    
        }else{
          
          final widgetPage = await _fileOpenHandler.resolve(element);
            /// Killing the loading alert
            Navigator.of(alertContext).pop();
          /// If there is a container widget, that means that user have no
          /// application to oppen a specific file
          if(widgetPage is Container){
            /// Killing the loading alert
            Navigator.of(alertContext).pop();
            scaffoldKey.currentState.showSnackBar(new SnackBar(
              content: Text('You have no app to open this file')
            ));
          }
          else if(widgetPage != null){
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context)=>widgetPage
            ));
          }
        }
        
      },
    );
  }

  List<Widget> _getBottomSheet(BuildContext context) {
    return [
      FlatButton.icon(
        onPressed: (){
          alertUtil.showCreateFolderAlert(context: context);
        }, 
        icon: Icon(Icons.create_new_folder), 
        label: Text('New Folder'),
      )
    ];
  }

}