library spec;

import 'dart:html';
import 'dart:convert';

class Spec {
	List<EconomicBuilding> econ = new List();

	void load(Function callback) {
	  var semicolon = ';'.codeUnitAt(0);
    var result = [];

    String url = "spec.json";
    HttpRequest.getString(url).then((content){
    	var decoded = JSON.decode(content);

    	print(decoded["economicBuildings"].runtimeType);
    	for (var econJson in decoded["economicBuildings"]) {
    		EconomicBuilding econB = new EconomicBuilding(econJson);
    		econ.add(econB);
    	}

      callback();
    });
	}

}

class EconomicBuilding {
	int id;
	String name;
	int cost;

	EconomicBuilding(var jsonMap) {
		id = jsonMap["id"];
		name = jsonMap["name"];
		cost = jsonMap["cost"];
	}
}