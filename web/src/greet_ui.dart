library greet_ui;

import 'dart:html';
import 'server.dart';

class GreetUi {
  Element greetDiv;
  Element nameElem;
  TextInputElement nameInput;
  ButtonInputElement setNameButton;
  Element registerDiv;
  Element startButton;
  Storage storage;
  Conn conn;

  PlayerInfo playerInfo = null;

  GreetUi(Element greetDiv, Storage storage, Conn conn) :
    this.greetDiv = greetDiv,
    this.storage = storage,
    this.conn = conn {

    nameElem = greetDiv.querySelector("#nameTitle");
    nameInput = greetDiv.querySelector("#nameInput");
    setNameButton = greetDiv.querySelector("#setName");
    registerDiv = greetDiv.querySelector("#register");
    startButton = greetDiv.querySelector("#startButton");

  }

  void init() {
    setNameButton.onClick.listen((e){
      nameInput.readOnly = true;
      setNameButton.disabled = true;
      conn.register( nameInput.value, playerRegistered );
    });

    conn.getUserInfo(initialCheck);

    startButton.onClick.listen((e){
      if (playerInfo == null) {
        return;
      }
      greetDiv.style.visibility = "hidden";
    });

  }

  void _setPlayerInfo(PlayerInfo playerInfo) {
    this.playerInfo = playerInfo;
    nameElem.innerHtml = playerInfo.name;
    startButton.classes.remove("sDisabled");
    startButton.classes.add("sEnabled");
  }

  void initialCheck(PlayerInfo playerInfo) {
    if (playerInfo == null) {
      // secret on tundmatu, tuleb regada
      // kasutajanime valimise UI nähtavaks
      registerDiv.style.visibility = "visible";
    } else {
      // mängija info kätte saadud
      // mängija info UI nähtavaks
      _setPlayerInfo(playerInfo);
    }
  }

  void playerRegistered(PlayerInfo playerInfo) {
    if (playerInfo == null) {
      // mis nüüd?
      nameInput.readOnly = false;
      setNameButton.disabled = false;
    } else {
      registerDiv.style.visibility = "hidden";
      _setPlayerInfo(playerInfo);
    }
  }
}