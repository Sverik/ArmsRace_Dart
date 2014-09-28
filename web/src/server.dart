library server;

import 'dart:html';
import 'dart:convert';
import 'dart:async';

class Conn {
  String url = "http://localhost:8080";
//  String url = "http://leafy-racer-709.appspot.com";

  void getUserInfo(void callback(PlayerInfo info)) {
    document.cookie = "secret=${getSecret()}";
    Future<HttpRequest> request = HttpRequest.request('$url/player/', withCredentials: true);
    request.catchError((o){
      callback( null );
    });
    request.then((request){
      PlayerInfo pi = readJson(request.response);
      callback(pi);
    });
  }

  void register(String name, callback(PlayerInfo info)) {
    Future<HttpRequest> request = HttpRequest.request('$url/register/$name', method: "POST");
    request.catchError((o){
      callback( null );
    });
    request.then((request){
      PlayerInfo pi = readJson(request.response);
      callback(pi);
    });
  }

  void queue(callback(String)) {
    Future<HttpRequest> request = HttpRequest.request('$url/queue/', withCredentials: true, method: "POST");
    request.catchError((e) {
      callback(null);
    });
    request.then((HttpRequest r){
      // TODO
      callback(r.response);
    });
  }

  PlayerInfo readJson(String jsonBlob) {
    var map = JSON.decode(jsonBlob);
    storeSecret( map["secret"] );
    PlayerInfo pi = new PlayerInfo(map);
    return pi;
  }

  void storeSecret(String secret) {
    window.localStorage["secret"] = secret;
  }

  String getSecret() {
    try {
      String secret = window.localStorage["secret"];
      secret = (secret == null ? "" : secret);
      return secret;
    } catch (e) {
      return "";
    }
  }

}

class PlayerInfo {
  String name;
  int wins;
  int played;

  PlayerInfo(var map) {
    try {
      name = map["username"];
      wins = map["wins"];
      played = map["played"];
    } catch (e) {
      name = e.toString();
    }
  }
}