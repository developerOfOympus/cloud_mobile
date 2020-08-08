/// T is the type of the return, and k is the type
/// of the hander task.
/// For example, you want to sove a task, and to do that
/// you need to provide a string in the 'resolve' method, 
/// and you want that method returns an Image, then you can
/// make ChainOfResponsability<Image, String>
abstract class ChainOfResponsabiity<T, K> {

  ChainOfResponsabiity<T, K> nextHandler;
  ChainOfResponsabiity({this.nextHandler});

  T resolve(K role);
  ChainOfResponsabiity newRole(ChainOfResponsabiity role)=>nextHandler=role;

}