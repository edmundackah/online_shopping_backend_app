import 'dart:convert';
import 'dart:math';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatEngine {

  //This class holds all the business logic for the chat bot
  String _sessionID;

  ChatEngine(){
    _sessionID = _randomString();
  }

  Future<List> detectIntent(String query) async {

    var _queryStruct = {
      "queryInput": {
        "text": {
          "text": "$query",
          "languageCode": "en"
        }
      },
      "queryParams": {
        "timeZone": "Europe/London"
      }
    };

    final _url = "https://dialogflow.googleapis.com/v2/projects/"
        "online-shopping-bdldtd/agent/sessions/$_sessionID:"
        "detectIntent";

    var _headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer ${await _getAuthKey()}",
    };

    //passing query to model for inferencing
    final res = await http.post(_url, headers: _headers, body: json.encode(_queryStruct));

    print("status code: ${res.statusCode}");

    if (res.statusCode == 200){
      //process server response
      final result = json.decode(res.body);

      return [res.statusCode, result];
    }

    return [res.statusCode];
  }

  Future<String> _getAuthKey() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    //check if token exists - if so, is it valid
    if (prefs.getString("authKey")!= null && prefs.getString("authExpiry")!= null ) {
      //check token expiry
      String expiry = prefs.getString("authExpiry");
      if (DateTime.parse(expiry).isBefore(DateTime.now()) == true) {
        //new token if old token has expired
        //print("new token if old token has expired");

        await prefs.setString("authKey", await _oAuth());
        //set new expiry
        await prefs.setString("authExpiry", DateTime.now().toString());
      }
    } else {
      //no token detected - issue new token
      //print("no token detected - issue new token");

      await prefs.setString("authKey", await _oAuth());
      //set new expiry
      await prefs.setString("authExpiry", DateTime.now().toString());
    }

    //print(prefs.getString("authKey"));

    return prefs.getString("authKey");
  }

  Future<String> _oAuth() async {

    var accountCredentials = new ServiceAccountCredentials.fromJson({
      "private_key_id": "0e3aa6d1bbe6e570f1cc5e3fa4cbcb58670f82b2",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQC2VrPed5Djjg1m\nQm00E1bomxhFr/razfnw3jEkWIg0B1QFBCvs3sKpA7TJh6HKwxRmcW2yEvqSmNJL\nHFdyj4kw0PHVp2sMjn244YbZ7uE0yUYIH0w0o8kZjmhKsQa+2isl5PgMttk8196V\nEvWpP3D1LrpdXfy2hrDSRssWE1f7281GMylDq+n6H9tD27j9suQzS8IUgqR030Am\nc0QLAr8q52BTagkV5ltSKLC8w6yAuYg5AFyfPDSRS9twpbdgbqRTrPXVWr/ctIr1\nTGXnEK86G4Vqe44PCzmzsrEZw2fYaKb+RHa+Og0u0WVw2Ob/RTjctY0YhZ95jfbl\nFq1+bSBrAgMBAAECggEAI4Q47fzxMnnhf0kyF0IrHAzVygEwxjz30eSdwtwhz6yb\nv4xj9/QeC6jmppiuOZ4NE7VFbjnHKBXvZGUFXZG64dDZQkoljmEU+RWo3DttD4ij\nBQL/p4M9sSYth1r7GuLJI8z5ShS1tOXBe90hD9IFMSTkdTpQ9sa+m37hoQ+shCij\n97XcR6NBk/tMpBDv86CGf9YbJQwreXXptAlzQG0hR8vipfjxA7VQY5aQID0bUnvA\nWL++syAj8lH/U7JMo/v44n0K3tB42/kJ9HdrIEhwENS7HSSFbTxPfT0wcJbQcjod\nh9vV8hrpyYo0I4xA/0+j9Fn+bU8RNISMbdfQkEwu2QKBgQD1PGLYH+t2uIfIpjBg\napnTPS4DOKxtKuBzKpPfKXowR/s363nVKpG8MytWhMASsV6zHdlnMhyjIpPwHmtH\nch/8bJ1ZecmGpOl3ANnK4v6mZQiM/yfS7MxSlcU2TDsdO4G42SrxkYC+SMg+m/an\n4G/D2t1DOn6qcqf4QldH13ArkwKBgQC+V5EWM2nK1mhXdEGSDul+2a/9duNuX/oQ\njphTpaJkxj3rWCJHLZzVkdw4BUXMS1PWROm0Yi/hcF0uhLjKgmTmADCux7tiODTY\nLwSgk60dkqYtop0G8/da/41d+DZcI6oAOWMVGALHQ5FqVqfbuKK3CQuZ7VGJsio6\nyj/OF2+uyQKBgHZ3XFyBVvL8A4QXXClHddXIqTCfMRRvcQvRVquoUsF+FEqYMzuZ\nm9spcNcTu+GL0259jec/GvxnmMWXPEXASNlc8solfgfQJIP7YjqTW2awSegq3mcT\nQ0Tl2uX2/1uIwoq0Rf16R5IkgK9WElpYnkUjtl1ipYvbZW8VRSqMVUCHAoGAPjkC\nBO/ptZVBptUqWkTlr8IZ9hHXZ02YwbDbuvx6idcEhtrY2cvfaTG1e9q9Znt5fKIq\ng/1VCa1hyMM6ZXka4tVNFNXWO9WD8Oft61BbVz+Jc4GlM5CtW+IOpJlvq88807Xu\n3gZrYhiEgO6zEPDawFsEn90kuo6zn2ReV1DyAYECgYBunwLkI6N+jU4hm2DOExoE\nFLWpcB5ESNmmj+cALxrd5lSXulh5qrk6zvm8go3wuP/5kAZI8B5EKac67INHdlEb\n/Hvs8mUeYVJEziCVGhjykjjqcbrekC4ExQK2OfCRmMT7fSt6GsjsMu8Xr4xWmx5e\ngLLqKRhjKmE+/atJN6Z/jQ==\n-----END PRIVATE KEY-----\n",
      "client_email": "flutter-client-access@online-shopping-bdldtd.iam.gserviceaccount.com",
      "client_id": "106586050333870313608",
      "type": "service_account"
    });
    List<String> scopes = ["https://www.googleapis.com/auth/dialogflow"];

    var client = new http.Client();
    AccessCredentials credentials = await obtainAccessCredentialsViaServiceAccount(accountCredentials, scopes, client);
    client.close();

    return credentials.accessToken.data.toString();
  }

  //used to generate a random string for session ID
  String _randomString() {
    var rand = new Random();
    var codeUnits = new List.generate(
        30,
            (index){
          return rand.nextInt(33)+89;
        }
    );

    return new String.fromCharCodes(codeUnits);
  }




}