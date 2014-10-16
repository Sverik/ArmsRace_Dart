library greet_ui;

import 'dart:html';
import 'server.dart';
import 'dart:async';

class GreetUi {
  static const pollIntervalSec = 5;
  static const maxQueueWaitSec = 300;
  static const maxTriesBeforeAllowReplay = 9;

  Element greetDiv;
  Element nameElem;
  TextInputElement nameInput;
  ButtonInputElement setNameButton;
  Element registerDiv;
  Element startButton;
  Element startStatus;
  Storage storage;
  Conn conn;

  int queuePollStart;

  PlayerInfo playerInfo = null;
  bool startEnabled = false;
  int findOpponentTryCount;

  var gameStartCallback;

  GreetUi(Element greetDiv, Storage storage, Conn conn, void gameStartCallback(GameState)) :
    this.greetDiv = greetDiv,
    this.storage = storage,
    this.conn = conn,
    this.gameStartCallback = gameStartCallback {

    nameElem = greetDiv.querySelector("#nameTitle");
    nameInput = greetDiv.querySelector("#nameInput");
    setNameButton = greetDiv.querySelector("#setName");
    registerDiv = greetDiv.querySelector("#register");
    startButton = greetDiv.querySelector("#startButton");
    startStatus = greetDiv.querySelector("#startStatus");

  }

  void nameChanged(Event evt) {
    setNameButton.disabled = nameInput.value.trim().length <= 1;
  }

  void init() {
    setNameButton.onClick.listen((e){
      nameInput.readOnly = true;
      setNameButton.disabled = true;
      conn.register( nameInput.value, playerRegistered );
    });

    nameInput
        ..onChange.listen(nameChanged)
        ..onKeyDown.listen(nameChanged)
        ..onKeyUp.listen(nameChanged)
        ..onCut.listen(nameChanged)
        ..onPaste.listen(nameChanged);

    _enableStart(false);
    conn.getUserInfo(initialCheck);

    nameInput.readOnly = false;
    setNameButton.disabled = true;
    _setPlayerInfo(playerInfo);
    startStatus.innerHtml = "";

    startButton.onClick.listen((e){
      if ( ! startEnabled) {
        return;
      }

      _enableStart(false);
      findOpponentTryCount = 0;
      queuePollStart = new DateTime.now().millisecondsSinceEpoch;
      queryQueue();
    });

  }

  void show() {
    startStatus.innerHtml = "";
    greetDiv.style.visibility = "visible";
  }

  void _setPlayerInfo(PlayerInfo playerInfo) {
    this.playerInfo = playerInfo;
    if (playerInfo != null) {
      nameElem.innerHtml = playerInfo.name;
    } else {
      nameElem.innerHtml = "...";
    }
    _enableStart(playerInfo != null);
  }

  void _enableStart(bool enable) {
    if (enable) {
      startButton.classes.remove("sDisabled");
      startButton.classes.add("sEnabled");
    } else {
      startButton.classes.add("sDisabled");
      startButton.classes.remove("sEnabled");
    }
    startEnabled = enable;
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

  void queryQueue() {
    findOpponentTryCount++;
    startStatus.innerHtml = 'Searching for opponent, try #$findOpponentTryCount...';
    conn.queue(findOpponentTryCount > maxTriesBeforeAllowReplay, queueResponse );
  }

  void queueResponse(GameState game) {
    if (game == null || game.finished == true /* || game.endTime < conn.getCurrentServerTime() */) {
      // Ei ole mängu leitud
      if (new DateTime.now().millisecondsSinceEpoch - queuePollStart < maxQueueWaitSec * 1000) {
        // Registreerime uue päringu
        new Future.delayed(const Duration(seconds: pollIntervalSec), () {
          queryQueue();
        });

      } else {
        // Lõpetame pollimise
        startStatus.innerHtml = "No opponent found, please try again later.";
        _enableStart(true);
      }
    } else {
      // Mäng leitud
      greetDiv.style.visibility = "hidden";
      gameStartCallback(game);
      _enableStart(true);
    }
  }
}