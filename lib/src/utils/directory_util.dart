import 'package:cloud/src/providers/file_provider.dart';
import 'package:cloud/src/utils/patters/chain_of_responsability.dart';

/// This class makes sense due to the problem of building
/// a correct path to update, delete, create, etc. So, this
/// class is gonna be a chain of responsability. 
abstract class _DirectoryHandler extends ChainOfResponsabiity<Future<bool>, List<String>> {
  
  static String _relativePath = "";
  final String _separator = ">";
  static final FileProvider _fileProvider = new FileProvider();

  /// This will build a path gave a target route
  String buildPath(String targetRoute, {bool back=false}) {

    if(back){
      final splitted = _relativePath.split('>');
      splitted.removeLast();
      _relativePath = (splitted.length>0)?splitted.join('>'):"";
      return _relativePath;
    }

    if(targetRoute == null){
      return _relativePath;
    }

    _relativePath = _relativePath == ""? targetRoute:"$_relativePath$_separator$targetRoute";
    return _relativePath;    
  }

  /// This does not need explanation
  Future<bool> goHome()async{
    _relativePath = "";
    return await _fileProvider.dirElements();
  }

  bool validateDirectoryName(String text){
    final hasDot = text.contains('.');
    final hasSep = text.contains(_separator);
    final hasSlash = text.contains('/');
    final hasInvSash = text.contains('\\');

    if(hasDot || hasSep || hasSlash || hasInvSash){
      return false;
    }

    return true;
  }
  /// Here, role recives two params, the first one is the role, and the
  /// second one is the target path.
  /// You can pase null on the first position if you want to update
  /// the root directory, or just provide the char '_'
  Future<bool> resolve(List<String> role);

  /// Getters and setters
  String get currentDirectory {
    return _relativePath.split(_separator).last==""? "HOME":
                _relativePath.split(_separator).last.toUpperCase();
  }

  String get currentPath {
    return _relativePath == ""? "Home":"Home\\${_relativePath.replaceAll('>', '\\')}";
  }

  Stream<List<String>> get dirStream => _fileProvider.fileData;
}

//-----------------------------------------------------------------------------------
class UpdateTreeHandler extends _DirectoryHandler{
  
  @override
  Future<bool> resolve(List<String> role) async{

    final path = buildPath(null);
    if(role[0].toUpperCase() == 'UPDATE'){
      return await _DirectoryHandler._fileProvider.dirElements(path: path);
    }
    
    return await nextHandler.resolve(role);
  }
}
//-----------------------------------------------------------------------------------
class MoveNextBack extends _DirectoryHandler{
  @override
  Future<bool> resolve(List<String> role) async {

    if(role[0].toUpperCase() == 'MOVENEXT'){
      return await _DirectoryHandler._fileProvider.dirElements(path: buildPath(role[1]));
    }
    if(role[0].toUpperCase()=='MOVEBACK'){
      final path = buildPath(null, back: true);
      return await _DirectoryHandler._fileProvider.dirElements(path: path);
    }
    
    return await nextHandler.resolve(role);

  }
}
//-----------------------------------------------------------------------------------
class DeleteHandler extends _DirectoryHandler{
  @override
  Future<bool> resolve(List<String> role) async {
    if(role[0].toUpperCase()=="DELETE"){
      final path = "${buildPath(null)}>${role[1]}";
      return _DirectoryHandler._fileProvider.removeDirectory(path);
    }

    return await nextHandler.resolve(role);
  }

}
//-----------------------------------------------------------------------------------
class CreateDirectory extends _DirectoryHandler{
  @override
  Future<bool> resolve(List<String> role) async {
    if(role[0].toUpperCase() == 'CREATE'){
      final path = "${buildPath(null)}$_separator${role[1]}";
      return await _DirectoryHandler._fileProvider.createDirectory(path);          
    }

    return await nextHandler.resolve(role);
  }
}