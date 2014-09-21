library ui;

import 'dart:html';
import 'logic.dart';
import 'state.dart';
import 'spec.dart';

class UserInterface {
	Logic logic;
	State state;
	Spec spec;

	Element moneyAmount;
	Element incomeAmount;
	Element economy;

	Map<int, EconomyElement> econElems = new Map();

	UserInterface(Logic logic, State state, Spec spec) :
		this.logic = logic,
		this.state = state,
		this.spec = spec;

	void init() {

		spec.econ.forEach((int id, EconomicBuilding econ) {
			// <div id="econ${econ.id}" class="econBuilding hidden">
			DivElement econBuildingRow = new DivElement();
			econBuildingRow.id = 'econ${econ.id}';
			econBuildingRow.classes.add("econBuilding");
			econBuildingRow.classes.add("hidden");

			// <div class="econBuild">
			DivElement econBuild = new DivElement();
			econBuildingRow.children.add(econBuild);
			econBuild.classes.add("econBuild");

			// <div id="buildButton" class="buildButton hidden">
			DivElement buildButton = new DivElement();
			econBuild.children.add(buildButton);
			buildButton.classes.add("buildButton");
			buildButton.classes.add("hidden");
			buildButton.onClick.listen((MouseEvent notUsed){
				logic.buildEcon(econ.id);
			});

			// <div class="buildButtonContent">
			DivElement buildButtonContent = new DivElement();
			buildButton.children.add(buildButtonContent);
			buildButtonContent.classes.add("buildButtonContent");
			buildButtonContent.innerHtml = "+";

			// <div class="buildDesc">
			DivElement buildDesc = new DivElement();
			econBuild.children.add(buildDesc);
			buildDesc.classes.add("buildDesc");

			// <div id="name" class="b_name">${econ.name}</div>
			DivElement name = new DivElement();
			buildDesc.children.add(name);
			name.classes.add("b_name");
			name.innerHtml = econ.name;

			// <div id="cost" class="b_cost">${econ.cost}</div>
			DivElement costRow = new DivElement();
			buildDesc.children.add(costRow);
			costRow.classes.add("b_cost");
			costRow.innerHtml = '<span class="costLabel">cost: </span>' + econ.cost.toString();

			// <div id="income" class="b_income">${econ.income}</div>
			DivElement income = new DivElement();
			buildDesc.children.add(income);
			income.classes.add("b_income");
			income.innerHtml = '<span class="incomeLabel">income: </span>' + econ.income.toString();

			// <div class="econBuiltSpacer">&nbsp;</div>
			DivElement econBuiltSpacer = new DivElement();
			econBuildingRow.children.add(econBuiltSpacer);
			econBuiltSpacer.classes.add("econBuiltSpacer");
			econBuiltSpacer.innerHtml = "&nbsp;";

			// <div class="econBuilt">
			DivElement econBuilt = new DivElement();
			econBuildingRow.children.add(econBuilt);
			econBuilt.classes.add("econBuilt");
			//econBuilt.innerHtml = "0";

			// <div class="clear"></div>
			DivElement clear = new DivElement();
			econBuildingRow.children.add(clear);
			clear.classes.add("clear");

			economy.children.add(econBuildingRow);

			EconomyElement econElem = new EconomyElement(econ, state, econBuildingRow, buildButton, econBuilt);
			econElems[econ.id] = econElem;

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
		});

	}

	void update() {
		moneyAmount.setInnerHtml(state.money.toString());

		econElems.forEach((int id, EconomyElement econElem){
			econElem.updateState(state.money);
		});

		incomeAmount.setInnerHtml(state.income.toString());
	}
}

class EconomyElement {
	EconomicBuilding spec;
	State state;
	DivElement root;
	DivElement buildButton;
	DivElement built;
	int visibilityState = -1; // 0: hidden, 1: disabled, 2: enabled (-1: esialgne olek, kõigest erinev)
	int currentCount = 0;

	EconomyElement(EconomicBuilding spec, State state, DivElement root, DivElement buildButton, DivElement built) :
		this.spec = spec,
		this.state = state,
		this.root = root,
		this.buildButton = buildButton,
		this.built = built;

  void updateState(int money) {
  	int oldVisibilityState = visibilityState;

  	if (money >= spec.cost) {
  		visibilityState = 2;
  	} else {
  		visibilityState = 1;
  	}

		// Peidame ainult esimesel korral kui piisavalt raha pole.
  	if ((oldVisibilityState == -1 || oldVisibilityState == 0) && (money < spec.cost / 2)) {
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

  	int count = state.getEcons(spec.id);
  	if (count != currentCount) {
  		// Uuendame näidatavat arvu
  		currentCount = count;
//  		built.innerHtml = currentCount.toString();
  		built.children.clear();
  		num step = (built.client.width - 44) / currentCount;
  		num pos = 0;
  		for (var i = 0 ; i < currentCount ; i++) {
	  		ImageElement image = new ImageElement(src: "farm.png", width: 40, height: 40);
	  		image.classes.add("econImage");
	  		image.style.marginLeft = '${pos.floor()}px';
	  		image.style.marginTop = '${(pos.floor() % 5) - 2}px';
	  		built.children.add(image);
	  		pos += step;
  		}
  		built.children.add(
  				new LabelElement()
  					..classes.add("econCount")
  					..innerHtml='$currentCount'
  		);
  	}

  }
}