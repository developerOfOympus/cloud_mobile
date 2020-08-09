
import 'package:cloud/src/utils/directory_util.dart';
import 'package:flutter/material.dart';

/// 
/// This is a singleton
class AlertUtil {

  final _createFormkey = new GlobalKey<FormState>();

  ///
  /// Don't forget to add a new handler if you want to do 
  /// something different to update or create a folder
  CreateDirectory _directoryHandler = new CreateDirectory();
  Form form;

  AlertUtil(){
    
    _directoryHandler.newRole(new UpdateTreeHandler());
    // The form for the folder name as such
    form=Form(
      key: _createFormkey,
      child: TextFormField(
        decoration: InputDecoration(
          labelText: "Directory name",
          hintText: "Directory name",
          prefixIcon: Icon(Icons.create_new_folder)
        ),
        onSaved: (String value)async=>await _directoryHandler.resolve(['CREATE', value]),
        validator: (String text){
          if(!_directoryHandler.validateDirectoryName(text)){
            return "The name is invalid";
          }
          // If there is no problem, then return null
          return null;
        },
      ),
    );
  }

  // Logic and methods
  void showAlertOkCancel({
    @required BuildContext context, @required String title,
    @required Widget content, @required Function onPressed
  }){
    showDialog(
      context: context,
      barrierDismissible: false,
      child: AlertDialog(
        title: Text(title),
        content: content,
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.cancel),
            label: Text('Cancel'),
            onPressed: ()=>Navigator.of(context).pop(),
          ),
          FlatButton.icon(
            icon: Icon(Icons.check_circle),
            color: Colors.red,
            label: Text('Ok'),
            onPressed: onPressed
          )
        ]
      )
    );
  }

  void showCreateFolderAlert({@required BuildContext context}){

    showDialog(
      context: context,
      barrierDismissible: false,
      child: AlertDialog(
        title: Text("Create a folder"),
        content: form,
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.cancel),
            label: Text('Cancel'),
            onPressed: ()=>Navigator.of(context).pop(),
          ),
          FlatButton.icon(
            icon: Icon(Icons.check_circle),
            label: Text('Create'),
            onPressed: ()async{
              if(_createFormkey.currentState.validate()){
                _createFormkey.currentState.save();
                await _directoryHandler.resolve(['update', null]);
                Navigator.of(context).pop();
              }
            }
          )
        ]
      )
    );
  }


}