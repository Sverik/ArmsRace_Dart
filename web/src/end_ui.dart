library end_ui;

import 'dart:html';
import 'server.dart';

class EndUi {
  Element endDiv;
  Element closeButton;
  var endClosed;

  EndUi(Element endDiv, void endClosed()) :
    this.endDiv = endDiv,
    this.endClosed = endClosed {
    closeButton = endDiv.querySelector("#closeButton");
  }

  void init() {
    closeButton.onClick.listen((e) {
      endDiv.style.visibility = "hidden";
      endClosed();
    });
  }

  void show(GameState game) {
    endDiv.style.visibility = "visible";
    querySelector("#debug").innerHtml = game.id.toString();
  }
}