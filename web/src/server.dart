library server;

import 'dart:html';
import 'dart:convert';
import 'dart:async';
import 'state.dart';
import 'spec.dart';
import 'battle.dart';

class Conn {
  String url = "http://leafy-racer-709.appspot.com";

  /** serveri aeg miinus kohalik aeg */
  int serverLocalTimeDiff = 0;

  Conn({bool dev}) {
    if (dev != null && dev == true) {
      url = "http://localhost:8080";
    }
  }

  void getUserInfo(void callback(PlayerInfo info)) {
    Future<HttpRequest> request = HttpRequest.request('$url/player/', withCredentials: true);
    request.catchError((o){
      callback( null );
    });
    request.then((request){
      PlayerInfo pi = getPlayerInfo(request.response);
      callback(pi);
    });
  }

  void register(String name, callback(PlayerInfo info)) {
    Future<HttpRequest> request = HttpRequest.request('$url/register/$name', withCredentials: true, method: "POST");
    request.catchError((o){
      callback( null );
    });
    request.then((request){
      PlayerInfo pi = getPlayerInfo(request.response);
      callback(pi);
    });
  }

  void queue(callback(GameState)) {
    Future<HttpRequest> request = HttpRequest.request('$url/queue/', withCredentials: true, method: "POST");
    request.catchError((e) {
      callback(null);
    });
    request.then((HttpRequest r){
      if (r.response.toString().length <= 0) {
        callback(null);
      } else {
        callback(getGameState(r.response));
      }
    });
  }

  GameState getGameState(String jsonBlob) {
    try {
      var map = JSON.decode(jsonBlob);
      GameState gs = new GameState(map);
      serverLocalTimeDiff = gs.currentTime - new DateTime.now().millisecondsSinceEpoch;
      return gs;
    } catch (e) {
      return null;
    }
  }

  int getCurrentServerTime() {
    return new DateTime.now().millisecondsSinceEpoch + serverLocalTimeDiff;
  }

  PlayerInfo getPlayerInfo(String jsonBlob) {
    var map = JSON.decode(jsonBlob);
    _storeSecret( map["secret"] );
    PlayerInfo pi = new PlayerInfo(map);
    return pi;
  }

  void pollGame(State state, String gameId, void response(GameState)) {
    String jsonBlob = JSON.encode(state, toEncodable: (Object o){
      Map<String, Object> map = new Map();
      map["money"] = state.money;
      map['arms'] = state.boughtArms;
      map['econs'] = state.boughtEcons;
      map["peaceOffer"] = state.peaceOffer;
      map["attacked"] = state.attacked;
      return map;
    });
    Future<HttpRequest> request = HttpRequest.request(
        '$url/game/$gameId',
        withCredentials: true,
        method: "POST",
        sendData: jsonBlob,
        requestHeaders: {"Content-Type": "application/json"}
        );
    request.catchError((e){
      response(null);
    });
    request.then((HttpRequest r){
      response(getGameState(r.response));
    });
  }

  void getArms(void response(Map jsonMap)) {
    HttpRequest.request(
        '$url/arms/',
        withCredentials: true,
        method: "GET"
        )
        ..catchError((e){
          response(null);
        })
        ..then((HttpRequest r){
          if (r.response == null) {
            response(null);
          } else {
            response(JSON.decode(r.response));
          }
        });
  }

  void getBattle(int gameId, void response(Battle battle)) {
    HttpRequest.request(
        '$url/battle/$gameId',
        withCredentials: true,
        method: "GET"
        )
        ..catchError((e){
          response(null);
        })
        ..then((HttpRequest r){
          if (r.response == null) {
            response(null);
          } else {
            response(new Battle(JSON.decode(r.response)));
          }
        });
  }

  // Neid vist pole enam vaja?
  void _storeSecret(String secret) {
    window.localStorage["secret"] = secret;
  }

  String _getSecret() {
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

class GameState {
   int id;

   int yourNumber;

   String player1;
   String player2;

   int startTime;
   int endTime;
   int currentTime;

   int attackTime;
   int attacker;

   bool peaceOffer1;
   bool peaceOffer2;

   String state1;
   String state2;

   State opponentState;

  // 0 == not finished, 1 == p1 won, 2 == p2 won, 3 == draw
   int winner;
   bool finished;

   GameState(var map) {
     try {
       id = map["id"];

       yourNumber = map["yourNumber"];

       player1 = map["player1"];
       player2 = map["player2"];

       startTime = map["startTime"];
       endTime = map["endTime"];
       currentTime = map["currentTime"];

       attackTime = map["attackTime"];
       attacker = map["attacker"];

       peaceOffer1 = map["peaceOffer1"];
       peaceOffer2 = map["peaceOffer2"];

       state1 = map["state1"];
       state2 = map["state2"];

       String stateJson = (yourNumber == 1 ? state2 : state1);
       var st = JSON.decode(stateJson);
       opponentState = new State(map: st);

       winner = map["winner"];
       finished = map["finished"];

     } catch (e) {

     }
   }
}

