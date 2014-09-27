library server;

import 'dart:html';
import 'dart:convert';
import 'dart:async';

class Conn {
  String userSecret = null;
//  String url = "http://localhost:8081";
  String url = "http://leafy-racer-709.appspot.com";

  String enc(Object o) {
    return o.toString();
  }

  void getUserInfo(String name, void callback(PlayerInfo info)) {
    Future<HttpRequest> request = HttpRequest.request('$url/player/$name');
    request.catchError((o){
      PlayerInfo pi = new PlayerInfo();
//      pi.name = "error: " + JSON.encode(o, toEncodable: (v){ return v.toString(); });
      pi.name = "error: " + enc(o);
      callback(pi);
    });
    request.then((request){
      PlayerInfo pi = new PlayerInfo(jsonBlob: request.response);
      callback(pi);
    });
  }
}

class PlayerInfo {
  String name;

  PlayerInfo({String jsonBlob}) {
    var map = JSON.decode(jsonBlob);
    name = map["name"];
  }
}