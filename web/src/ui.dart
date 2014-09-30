library ui;

import 'dart:html';
import 'logic.dart';
import 'state.dart';
import 'spec.dart';
import 'server.dart';

class UserInterface {
  bool layoutValid = false;

	Logic logic;
	State state;
	Spec spec;
	Conn conn;

	Element moneyAmount;
	Element incomeAmount;
	Element economy;
	Element arms;

	Element opponentName;
	Element opponentStatus;
	Element oppBuildings;
	Element oppArms;
	Element gameEndType;
	Element gameTimeRemaining;

	Element warmup;
	Element warmupTimeRemaining;
	bool warmupVisible = true;

	Element attackButton;

	GameState game = null;

	bool stateValid = true;

	Map<String, BuildableElement> armElems = new Map();
	Map<String, BuildableElement> econElems = new Map();

	UserInterface(Logic logic, State state, Spec spec, Conn conn) :
		this.logic = logic,
		this.state = state,
		this.spec = spec,
		this.conn = conn {
	  opponentName = querySelector("#opponentName");
	  opponentStatus = querySelector("#opponentStatus");
	  gameEndType = querySelector("#gameEndType");
	  gameTimeRemaining = querySelector("#gameTimeRemaining");
	  oppBuildings = querySelector("#oppBuildings");
	  oppArms = querySelector("#oppArms");

	  warmup = querySelector("#warmup");
	  warmupTimeRemaining = querySelector("#warmupTime");

	  attackButton = querySelector("#btnAttack");
	}

	void init() {

		spec.econ.forEach(addEconElem);
		List<Armament> arms = new List.from(spec.arms.values, growable : false);
		arms.sort((Armament a, Armament b){
		  return a.cost - b.cost;
		});
		arms.forEach(addArmElem);

		attackButton.onClick.listen((e){
		  if ( ! state.attacked) {
  		  state.attacked = true;
		  }
		});

	}

	void reset() {
	  warmup.style.visibility = "visible";
	  warmupVisible = true;
	  opponentStatus.innerHtml = '&nbsp;';
	  gameEndType.innerHtml = "with a battle";
	  gameTimeRemaining.classes.remove("attacking");
    attackButton.classes.add("enabled");
    attackButton.classes.remove("disabled");
	}

  String getArmImageName(Armament arm) {
    switch (arm.type) {
      case 'marine': return "assault_rifle.png";
      case 'chemical troops': return "machine_gun.png";
      case 'sniper': return "sniper.png";
      case 'tank': return "tank.png";
      default: return "tank.png";
    }

  }

	void addArmElem(Armament arm) {
    _addElem("arm", arm.id, logic.buildArm, arm.name, arm.cost, arms,
        [new ExtraData("hp", arm.maxHealth.toString()),
         new ExtraData("dps", arm.dps.toString()),
         new ExtraData("reload", arm.reloadTime.toString())],
        (DivElement buildingRow, DivElement buildButton, DivElement built){

          BuildableElement elem = new BuildableElement(
              arm.cost,
              getArmImageName(arm),
              (){
               return state.getArms(arm.id);
              },
              buildingRow,
              buildButton,
              built
          );
          armElems[arm.id] = elem;

         }
    );
	}

	String getEconImageName(String id) {
	  switch (id) {
	    case '1': return "small_farm.png";
	    case '2': return "blacksmith.png";
	    case '3': return "docks.png";
	    case '4': return "pub.png";
	    case '5': return "hotel.png";
	    case '6': return "steel_mill.png";
	    case '7': return "ic_fab.png";
	    case '8': return "plastic_factory.png";
	    case '9': return "film_studio.png";
	    case '10': return "btc_mine.png";
	    default: return "small_farm.png";
	  }
	}

	void addEconElem(String id, EconomicBuilding econ) {
	  _addElem("econ", id, logic.buildEcon, econ.name, econ.cost, economy,
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

	void _addElem(String idPrefix, String id, void buildHook(String id), String itemName, int cost, Element container, List<ExtraData> extra, void processCreated(DivElement buildingRow, DivElement buildButton, DivElement built)) {
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
    buildButton.classes.add("button");
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
	  bool currentStateValid = stateValid;

		moneyAmount.setInnerHtml(state.money.toString());

		econElems.forEach((String id, BuildableElement elem){
			elem.updateState(state.money, state.attacked, layoutValid);
		});

		armElems.forEach((String id, BuildableElement elem){
			elem.updateState(state.money, state.attacked, layoutValid);
		});

		incomeAmount.setInnerHtml(state.income.toString());

		_updateWarmup();

		_updateTime();

		_updateOpponentState();

		_updateDecisionState();

		if (currentLayoutValid == layoutValid) {
		  layoutValid = true;
		}

		if (currentStateValid == stateValid) {
		  stateValid = true;
		}

	}

	void _updateWarmup() {
	  if (warmupVisible) {
  	  if (conn.getCurrentServerTime() < game.startTime) {
  	    int millisToStart = game.startTime - conn.getCurrentServerTime();
  	    warmupTimeRemaining.innerHtml = _toMinutesSeconds(millisToStart);
  	  } else {
  	    warmup.style.visibility = "hidden";
  	    warmupVisible = false;
  	  }
	  }
	}

	void _updateTime() {
    int remainingMilliseconds = game.endTime - conn.getCurrentServerTime();
    gameTimeRemaining.innerHtml = _toMinutesSeconds(remainingMilliseconds);

	}

	void _updateOpponentState() {
	  if ( ! stateValid) {
	    // Vastase ehitised
	    int econTotalCount = 0;
	    int armsTotalCount = 0;
	    if (game.opponentState != null) {
	      game.opponentState.boughtEcons.forEach((String id, int count){
	        econTotalCount += count;
	      });
	      game.opponentState.boughtArms.forEach((String id, int count){
	        armsTotalCount += count;
	      });
	    }
      oppBuildings.innerHtml = econTotalCount.toString();
      oppArms.innerHtml = armsTotalCount.toString();

      // Kas vastane rümdas?
      if (game.attacker != 0 && game.attacker != game.yourNumber) {
        opponentStatus.innerHtml = "Attacking soon!!";
      }
	  }
	}

	void _updateDecisionState() {
    if (game.attacker != 0 || state.attacked) {
      gameTimeRemaining.classes.add("attacking");
      attackButton.classes.remove("enabled");
      attackButton.classes.add("disabled");
    }
	}

	String _toMinutesSeconds(int millis) {
    if (millis < 0) {
      millis = 0;
    }
    int minutes = millis ~/ (60 * 1000);
    millis -= minutes * 60 * 1000;
    int seconds = millis ~/ 1000;
    return '$minutes:${seconds < 10 ? '0' : ''}$seconds';

	}

  void resize() {
    layoutValid = false;
  }

  void updateState(GameState game) {
    stateValid = false;
    // uuendame ainult uue mängu puhul
    if (this.game == null || game.id != this.game.id) {
      opponentName.innerHtml = (game.yourNumber == 1 ? game.player2 : game.player1);
    }

    this.game = game;

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

  void updateState(int money, bool attacked, bool layoutValid) {
  	int oldVisibilityState = visibilityState;

  	if (money >= cost && ! attacked) {
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