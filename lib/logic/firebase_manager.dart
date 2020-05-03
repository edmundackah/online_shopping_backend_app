import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';


class FirebaseManager {

  /*
  This class holds all the code required to interact with the firebase backend
   */

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<String> login(String email, String password) async {
    await for ( var docs in Firestore.instance.collection("users")
        .where("email", isEqualTo: email)
        .where("login.password", isEqualTo: password).limit(1).snapshots()){

      if (docs.documents.length > 0 && docs.documents[0]["isAdmin"] == true) {
        //login successful
        return docs.documents[0].documentID;
      }
    };
  }

}