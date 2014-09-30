library end_ui;

import 'dart:async';
import 'dart:html';
import 'server.dart';
import 'battle.dart';

class EndUi {
  Element endDiv;
  Element closeButton;
  Element battleWinner;
  Element map;
  Conn conn;
  var endClosed;
  var getArmImageName;

  EndUi(Element endDiv, Conn conn, void endClosed(), String getArmImageName(Armament)) :
    this.endDiv = endDiv,
    this.endClosed = endClosed,
    this.conn = conn,
    this.getArmImageName = getArmImageName {
    closeButton = endDiv.querySelector("#closeButton");
    battleWinner = endDiv.querySelector("#battleWinner");
    map = endDiv.querySelector("#map");
  }

  void init() {
    closeButton.onClick.listen((e) {
      endDiv.style.visibility = "hidden";
      endClosed();
    });
  }

  void show(GameState game) {
    endDiv.style.visibility = "visible";
    map.children.clear();
    battleWinner.innerHtml = '...';
    conn.getBattle(game.id, (Battle battle){
      _showBattle(game, battle);
    });
  }

  void _showBattle(GameState game, Battle battle) {
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

    Map<String, BattleElement> bes = new Map();
    // grid step
    int gS = map.client.width ~/ 20;
    var m = (List<BattleUnit> bus) {
      bus.forEach((BattleUnit bu){
        ImageElement image = new ImageElement(src: getArmImageName(bu.type), width: gS, height: gS);
        image.classes.add("battleUnit");
        image.style.left = "${bu.loc.x * gS}px";
        image.style.top = "${bu.loc.y * gS}px";
        map.children.add(image);

        DivElement d = new DivElement();
        d.classes.add("battleUnitCount");
        d.style.left = "${bu.loc.x * gS}px";
        d.style.top = "${bu.loc.y * gS}px";
        d.innerHtml = "${bu.n}";
        map.children.add(d);

        bes["${bu.loc.x}x${bu.loc.y}"] = new BattleElement(bu, image, d);
        //print("bu ${bu.type.name}, x: ${bu.loc.x}, y: ${bu.loc.y}, left: ${bu.loc.x * gS}, top: ${bu.loc.y * gS}");
      });
    };
    m(battle.initialUnitsP1);
    m(battle.initialUnitsP2);

    var showRound = (Round r){
      //print("-=round=-");
      r.events.forEach((BattleEvent e){
        if (e is MoveEvent) {
          BattleElement be = bes.remove("${e.from.x}x${e.from.y}");
          //print("${be != null ? be.bu.type.name : "NULL"}: ${e.from.x}x${e.from.y} ---> ${e.to.x}x${e.to.y}");
          bes["${e.to.x}x${e.to.y}"] = be;
          if (be != null) {
            be.image.style.left = "${e.to.x * gS}px";
            be.image.style.top = "${e.to.y * gS}px";
            be.text.style.left = "${e.to.x * gS}px";
            be.text.style.top = "${e.to.y * gS}px";
          }
        } else if (e is ShootEvent) {
          BattleElement be = bes["${e.from.x}x${e.from.y}"];
          String k = "";
          if (e.newHealth.numUnits <= 0) {
            bes.remove("${e.to.x}x${e.to.y}");
            k = ", NU=0";
            if (be != null) {
              be.image.style.visibility = "hidden";
              be.text.style.visibility = "hidden";
            }
          }
          //print("${be.bu.type.name}: ${e.from.x}x${e.from.y} ---* ${e.to.x}x${e.to.y}$k");
        }
      });
    };

    Iterator<Round> iter = battle.log.iterator;
    var playback;
    playback = () {
      if (iter.moveNext()) {
        Round r = iter.current;
        showRound(r);
        new Future.delayed(const Duration(seconds: 1), (){
          playback();
        });
      }
    };

    playback();

  }

}

class BattleElement {
  BattleUnit bu;
  ImageElement image;
  DivElement text;

  BattleElement(BattleUnit bu, ImageElement image, DivElement text) :
    this.bu = bu,
    this.image = image,
    this.text = text;
}