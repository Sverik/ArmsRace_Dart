library spec;

import 'dart:html';
import 'dart:convert';

class Spec {
	Map<int, EconomicBuilding> econ = new Map();

	void load(Function callback) {
	  var semicolon = ';'.codeUnitAt(0);
    var result = [];

    String url = "spec.json";
    HttpRequest.getString(url).then((content){
    	var decoded = JSON.decode(content);

    	for (var econJson in decoded["economicBuildings"]) {
    		EconomicBuilding econB = new EconomicBuilding(econJson);
    		econ[econB.id] = econB;
    	}

      callback();
    });
	}

	EconomicBuilding getEcon(int id) {
		return econ[id];
	}

}

class EconomicBuilding {
	int id;
	String name;
	int cost;
	int income;

	EconomicBuilding(var jsonMap) {
		id = jsonMap["id"];
		name = jsonMap["name"];
		cost = jsonMap["cost"];
		income = jsonMap["income"];
	}
}