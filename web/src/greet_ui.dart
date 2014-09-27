library greet_ui;

import 'dart:html';
import 'server.dart';

class GreetUi {
  Element greetDiv;
  Element nameElem;
  TextInputElement nameInput;
  Element setNameButton;
  Storage storage;
  Conn conn;

  GreetUi(Element greetDiv, Storage storage, Conn conn) :
    this.greetDiv = greetDiv,
    this.storage = storage,
    this.conn = conn {

    nameElem = greetDiv.querySelector("#nameTitle");
    nameInput = greetDiv.querySelector("#nameInput");
    setNameButton = greetDiv.querySelector("#setName");

  }

  void init() {
    setNameButton.onClick.listen((e){
      if (true || storage.containsKey("secret")) {
        conn.userSecret = storage["secret"];
        conn.getUserInfo( nameInput.value, playerInfoReceived );
      }
    });

    Element startButton = greetDiv.querySelector("#startButton");
    startButton.onClick.listen((e){
      greetDiv.style.visibility = "hidden";
    });

  }

  void playerInfoReceived(PlayerInfo playerInfo) {
    nameElem.innerHtml = playerInfo.name;
  }
}