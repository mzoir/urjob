class Clients {

  final String username;
  String email;
  String id ;
  bool emailverified ;

  set username(String value) {
    username = value;
  }
  Clients ({
    required this.username,
    required this.email,
    required this.id,
    required this.emailverified

  });

  @override
  String toString() {
    return username+""+email+""+id+""+emailverified.toString();
  }
}