library battle;

import 'spec.dart';

class Battle {
  int winner;
  bool draw;
  List<BattleUnit> initialUnitsP1;
  List<BattleUnit> initialUnitsP2;
  List<Round> log;

  Battle(var map) {
    winner = map["winner"];
    draw = map["draw"];
    initialUnitsP1 = new List();
    initialUnitsP2 = new List();
    (map["initialUnits"][0] as List).forEach((e){
      initialUnitsP1.add(new BattleUnit(e));
    });
    (map["initialUnits"][1] as List).forEach((e){
      initialUnitsP2.add(new BattleUnit(e));
    });

    log = new List();
    (map["log"] as List).forEach((e){
      log.add(new Round(e));
    });
  }
}

class Round {
  List<BattleEvent> events;

  Round(var list) {
    events = new List();
    (list as List).forEach((var e){
      if (e["event"] == "move") {
        events.add(new MoveEvent(e));
      } else if (e["event"] == "shoot") {
        events.add(new ShootEvent(e));
      }
    });
  }
}

class BattleUnit {
  Armament type;
  Health health;
  int n;
  Location loc;

  BattleUnit(var map) {
    n = map["n"];
    type = new Armament(map["type"]);
    health = new Health(map["health"]);
    loc = new Location(map["loc"]);
  }
}

class Health {
  int numUnits;
  int unitHP;
  int weakestHP;

  Health(var map) {
    numUnits = map["numUnits"];
    unitHP = map["unitHP"];
    weakestHP = map["weakestHP"];
  }
}

class Location {
  int x;
  int y;

  Location(var list) {
    x = list[0];
    y = list[1];
  }
}

class BattleEvent {
}

class MoveEvent implements BattleEvent {
  Location from;
  Location to;

  MoveEvent(Map map) {
    from = new Location(map["from"]);
    to = new Location(map["to"]);
  }
}

class ShootEvent implements BattleEvent {
  Location from;
  Location to;
  Health newHealth;

  ShootEvent(var map) {
    from = new Location(map["from"]);
    to = new Location(map["to"]);
    newHealth = new Health(map["newHealth"]);
  }
}