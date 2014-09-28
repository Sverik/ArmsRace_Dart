library greet_ui;

import 'dart:html';
import 'server.dart';

class GreetUi {
  Element greetDiv;
  Element nameElem;
  TextInputElement nameInput;
  ButtonInputElement setNameButton;
  Element registerDiv;
  Storage storage;
  Conn conn;

  GreetUi(Element greetDiv, Storage storage, Conn conn) :
    this.greetDiv = greetDiv,
    this.storage = storage,
    this.conn = conn {

    nameElem = greetDiv.querySelector("#nameTitle");
    nameInput = greetDiv.querySelector("#nameInput");
    setNameButton = greetDiv.querySelector("#setName");
    registerDiv = greetDiv.querySelector("#register");

  }

  void init() {
    setNameButton.onClick.listen((e){
      nameInput.readOnly = true;
      setNameButton.disabled = true;
      conn.register( nameInput.value, playerRegistered );
    });

    conn.getUserInfo(initialCheck);

    Element startButton = greetDiv.querySelector("#startButton");
    startButton.onClick.listen((e){
      greetDiv.style.visibility = "hidden";
    });

  }

  void initialCheck(PlayerInfo playerInfo) {
    if (playerInfo == null) {
      // secret on tundmatu, tuleb regada
      // kasutajanime valimise UI nähtavaks
      registerDiv.style.visibility = "visible";
    } else {
      // mängija info kätte saadud
      // mängija info UI nähtavaks
      nameElem.innerHtml = playerInfo.name;
    }
  }

  void playerRegistered(PlayerInfo playerInfo) {
    if (playerInfo == null) {
      // mis nüüd?
      nameInput.readOnly = false;
      setNameButton.disabled = false;
    } else {
      registerDiv.style.visibility = "hidden";
      nameElem.innerHtml = playerInfo.name;
    }
  }
}