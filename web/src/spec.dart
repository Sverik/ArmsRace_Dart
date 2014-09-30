library spec;

import 'dart:html';
import 'dart:convert';
import 'server.dart';

class Spec {
	Map<String, EconomicBuilding> econ = new Map();
	Map<String, Armament> arms = new Map();
	Conn conn;
	var loadCallback;

	Spec(Conn conn) :
	  this.conn = conn;

	void load(Function callback) {
	  loadCallback = callback;
	  var semicolon = ';'.codeUnitAt(0);
    var result = [];

    String url = "spec.json";
    HttpRequest.getString(url).then((content){
      var decoded = JSON.decode(content);

      for (var econJson in decoded["economicBuildings"]) {
        EconomicBuilding econB = new EconomicBuilding(econJson);
        econ[econB.id] = econB;
      }

      conn.getArms(_processUnits);
    });

	}

  void _processUnits(Map jsonMap) {
    jsonMap.forEach((var k, var v) {
      Armament arm = new Armament(k, v);
      arms[arm.id] = arm;
    });
    loadCallback();
  }

	EconomicBuilding getEcon(String id) {
		return econ[id];
	}

	Armament getArm(String id) {
	  return arms[id];
	}

}

class EconomicBuilding {
	String id;
	String name;
	int cost;
	int income;

	EconomicBuilding(var jsonMap) {
		id = jsonMap["id"].toString();
		name = jsonMap["name"];
		cost = jsonMap["cost"];
		income = jsonMap["income"];
	}
}

class Armament {
  String id;
  String name;
  int cost;

  /** initial health */
  int maxHealth;
  /** damage per second (per unit), total damage is dps*live.units */
  int dps;
  /** damage per second against armored units */
  int armoredDPS;
  int movementSpeed;
  int reloadTime;
  int range100;
  /* -1 if no limit */
  int maxShots = -1;

  bool splashDamage     = false;
  bool armored          = false;
  bool shootWhileMoving = false;
  bool targetsArmored   = false;

  Armament(String id, var jsonMap) {
    this.id = id;
    name = jsonMap["name"];
    cost = jsonMap["cost"];

    maxHealth = jsonMap["maxHealth"];
    dps = jsonMap["dps"];
    armoredDPS = jsonMap["armoredDPS"];
    movementSpeed = jsonMap["movementSpeed"];
    reloadTime = jsonMap["reloadTime"];
    range100 = jsonMap["range100"];
    maxShots = jsonMap["maxShots"];

    splashDamage = jsonMap["splashDamage"];
    armored = jsonMap["armored"];
    shootWhileMoving = jsonMap["shootWhileMoving"];
    targetsArmored = jsonMap["targetsArmored"];
  }

}
