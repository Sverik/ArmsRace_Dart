library end_ui;

import 'dart:html';
import 'server.dart';

class EndUi {
  Element endDiv;
  Element closeButton;
  Element battleWinner;
  Conn conn;
  var endClosed;

  EndUi(Element endDiv, Conn conn, void endClosed()) :
    this.endDiv = endDiv,
    this.endClosed = endClosed,
    this.conn = conn {
    closeButton = endDiv.querySelector("#closeButton");
    battleWinner = querySelector("#battleWinner");
  }

  void init() {
    closeButton.onClick.listen((e) {
      endDiv.style.visibility = "hidden";
      endClosed();
    });
  }

  void show(GameState game) {
    endDiv.style.visibility = "visible";
    battleWinner.innerHtml = '...';
    conn.getBattle(game.id, (Battle battle){
      if (battle.draw) {
        battleWinner.innerHtml = "it's a draw!";
      } else {
        if (battle.winner == 0) {
          battleWinner.innerHtml = game.player1;
        } else if (battle.winner == 1) {
          battleWinner.innerHtml = game.player2;
        } else {
          battleWinner.innerHtml = "wat?";
        }
      }
    });
  }
}