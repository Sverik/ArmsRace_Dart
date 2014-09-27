library ui;

import 'dart:html';
import 'logic.dart';
import 'state.dart';
import 'spec.dart';

class UserInterface {
  bool layoutValid = false;

	Logic logic;
	State state;
	Spec spec;

	Element moneyAmount;
	Element incomeAmount;
	Element economy;
	Element arms;

	Map<int, BuildableElement> armElems = new Map();
	Map<int, BuildableElement> econElems = new Map();

	UserInterface(Logic logic, State state, Spec spec) :
		this.logic = logic,
		this.state = state,
		this.spec = spec;

	void init() {

		spec.econ.forEach(addEconElem);
		spec.arms.forEach(addArmElem);

	}

  String getArmImageName(int id) {
    switch (id) {
      case 1: return "assault_rifle_60.png";
      case 2: return "machine_gun_60.png";
      default: return "tank_60.png";
    }

  }

	void addArmElem(int id, Armament arm) {
    addElem("arm", id, logic.buildArm, arm.name, arm.cost, arms,
        [new ExtraData("dam", "4"),
         new ExtraData("hp", "10")],
        (DivElement buildingRow, DivElement buildButton, DivElement built){

          BuildableElement elem = new BuildableElement(
              arm.cost,
              getArmImageName(id),
              (){
               return state.getArms(id);
              },
              buildingRow,
              buildButton,
              built
          );
          armElems[arm.id] = elem;

         }
    );
	}

	String getEconImageName(int id) {
	  switch (id) {
	    case 1: return "small_farm_60.png";
	    case 2: return "blacksmith_60.png";
	    case 3: return "docks_60.png";
	    case 4: return "pub_60.png";
	    case 5: return "hotel_60.png";
	    case 6: return "steel_mill_60.png";
	    case 7: return "ic_fab_60.png";
	    case 8: return "plastic_factory_60.png";
	    case 9: return "film_studio_60.png";
	    case 10: return "btc_mine_60.png";
	    default: return "small_farm_60.png";
	  }
	}

	void addEconElem(int id, EconomicBuilding econ) {
	  addElem("econ", id, logic.buildEcon, econ.name, econ.cost, economy,
	      [new ExtraData("income", econ.income.toString())],
	      (DivElement buildingRow, DivElement buildButton, DivElement built){

    	    BuildableElement elem = new BuildableElement(
    	        econ.cost,
    	        getEconImageName(id),
    	        (){
    	         return state.getEcons(id);
        	    },
    	        buildingRow,
    	        buildButton,
    	        built
	        );
          econElems[econ.id] = elem;

	       }
	  );

	}

	void addElem(String idPrefix, int id, void buildHook(int id), String itemName, int cost, Element container, List<ExtraData> extra, void processCreated(DivElement buildingRow, DivElement buildButton, DivElement built)) {
    // <div id="econ${econ.id}" class="econBuilding hidden">
    DivElement buildingRow = new DivElement();
    buildingRow.id = '$idPrefix$id';
    buildingRow.classes.add("econBuilding");
    buildingRow.classes.add("hidden");

    // <div class="econBuild">
    DivElement build = new DivElement();
    buildingRow.children.add(build);
    build.classes.add("econBuild");

    // <div id="buildButton" class="buildButton hidden">
    DivElement buildButton = new DivElement();
    build.children.add(buildButton);
    buildButton.classes.add("buildButton");
    buildButton.classes.add("hidden");
    buildButton.onClick.listen((MouseEvent notUsed){
      buildHook(id);
    });

    // <div class="buildButtonContent">
    DivElement buildButtonContent = new DivElement();
    buildButton.children.add(buildButtonContent);
    buildButtonContent.classes.add("buildButtonContent");
    buildButtonContent.innerHtml = "+";

    // <div class="buildDesc">
    DivElement buildDesc = new DivElement();
    build.children.add(buildDesc);
    buildDesc.classes.add("buildDesc");

    // <div id="name" class="b_name">${econ.name}</div>
    DivElement name = new DivElement();
    buildDesc.children.add(name);
    name.classes.add("b_name");
    name.innerHtml = itemName;

    // <div id="cost" class="b_cost">${econ.cost}</div>
    DivElement costRow = new DivElement();
    buildDesc.children.add(costRow);
    costRow.classes.add("b_cost");
    costRow.innerHtml = '<span class="costLabel">cost: </span>' + cost.toString();

    extra.forEach((ExtraData e){
      // <div id="income" class="b_income">${econ.income}</div>
      DivElement extraD = new DivElement();
      buildDesc.children.add(extraD);
      extraD.classes.add("b_income");
      extraD.innerHtml = '<span class="incomeLabel">${e.name}: </span>${e.value}';
    });

    // <div class="econBuiltSpacer">&nbsp;</div>
    DivElement builtSpacer = new DivElement();
    buildingRow.children.add(builtSpacer);
    builtSpacer.classes.add("econBuiltSpacer");
    builtSpacer.innerHtml = "&nbsp;";

    // <div class="econBuilt">
    DivElement built = new DivElement();
    buildingRow.children.add(built);
    built.classes.add("econBuilt");
    //econBuilt.innerHtml = "0";

    // <div class="clear"></div>
    DivElement clear = new DivElement();
    buildingRow.children.add(clear);
    clear.classes.add("clear");

    container.children.add(buildingRow);

    processCreated(buildingRow, buildButton, built);

/*
    sb.write('''
            <div id="econ${econ.id}" class="econBuilding hidden">
              <div class="econBuild">
                <div id="buildButton" class="buildButton hidden">
                  <div class="buildButtonContent">
                  +
                  </div>
                </div>
                <div class="buildDesc">
                  <div id="name" class="b_name">${econ.name}</div>
                  <div id="cost" class="b_cost">${econ.cost}</div>
                  <div id="income" class="b_income">${econ.income}</div>
                </div>
              </div>
              <div class="econBuiltSpacer">&nbsp;</div>
              <div class="econBuilt">
              5
              </div>
              <div class="clear"></div>
            </div>
      ''');
*/
	}

	void update() {
	  bool currentLayoutValid = layoutValid;

		moneyAmount.setInnerHtml(state.money.toString());

		econElems.forEach((int id, BuildableElement elem){
			elem.updateState(state.money, layoutValid);
		});

		armElems.forEach((int id, BuildableElement elem){
			elem.updateState(state.money, layoutValid);
		});

		incomeAmount.setInnerHtml(state.income.toString());

		if (currentLayoutValid == layoutValid) {
		  layoutValid = true;
		}
	}

  void resize() {
    layoutValid = false;
  }
}

class ExtraData {
  String name;
  String value;

  ExtraData(String name, String value) :
    this.name = name,
    this.value = value;
}

class BuildableElement {
  int cost;
	DivElement root;
	DivElement buildButton;
	DivElement built;
	int visibilityState = -1; // 0: hidden, 1: disabled, 2: enabled (-1: esialgne olek, kõigest erinev)
	int currentCount = 0;
	var imageName;
	var buildCount;

	BuildableElement(int cost, String imageName, int buildCount(), DivElement root, DivElement buildButton, DivElement built) :
		this.cost = cost,
		this.imageName = imageName,
		this.buildCount = buildCount,
		this.root = root,
		this.buildButton = buildButton,
		this.built = built;

  void updateState(int money, bool layoutValid) {
  	int oldVisibilityState = visibilityState;

  	if (money >= cost) {
  		visibilityState = 2;
  	} else {
  		visibilityState = 1;
  	}

		// Peidame ainult esimesel korral kui piisavalt raha pole.
  	if ((oldVisibilityState == -1 || oldVisibilityState == 0) && (money < cost / 2)) {
  		visibilityState = 0;
  	}

  	if (oldVisibilityState != visibilityState) {
  		root.classes.removeAll(["hidden", "disabled", "enabled"]);
  		buildButton.classes.removeAll(["hidden", "disabled", "enabled"]);

  		switch (visibilityState) {
  			case 0:
  				root.classes.add("hidden");
  				break;
  			case 1:
  				buildButton.classes.add("disabled");
  				root.classes.add("disabled");
  				break;
  			case 2:
  				buildButton.classes.add("enabled");
  				root.classes.add("enabled");
  				break;
  		}

  	}

  	int count = this.buildCount();
  	if (count != currentCount || (! layoutValid)) {
  		// Uuendame näidatavat arvu
  		currentCount = count;
  		built.children.clear();
  		num step = (built.client.width - 44) / currentCount;
  		num pos = 0;
  		for (var i = 0 ; i < currentCount ; i++) {
	  		ImageElement image = new ImageElement(src: imageName, width: 60, height: 60);
	  		image.classes.add("econImage");
	  		image.style.marginLeft = '${pos.floor()}px';
	  		image.style.marginTop = '${(pos.floor() % 5) - 2}px';
	  		built.children.add(image);
	  		pos += step;
  		}
  		if (currentCount > 1) {
    		built.children.add(
    				new LabelElement()
    					..classes.add("econCount")
    					..innerHtml='$currentCount'
    		);
  		}
  	}

  }
}