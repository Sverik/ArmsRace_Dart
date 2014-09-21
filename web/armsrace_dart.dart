import 'dart:html';
import 'dart:async';

import 'src/logic.dart';
import 'src/ui.dart';
import 'src/state.dart';
import 'src/spec.dart';

/** Iga stepIntervalMs-inda millisekundi kohta tuleb üks samm teha. See muutuja näitab, millise millisekundi kohta viimati samm tehti. */
int previousStepTime = -1000;
const stepIntervalMs = 100;
Logic logic;
UserInterface ui;
State state;
Spec spec;

void main() {

	spec = new Spec();

	// Kui load lõpetab, kutsub ta parameetriks kaasa antud funktsiooni ehk initsialiseerimine jätkub.
	spec.load((){
		state = new State();
  	logic = new Logic(state, spec);

  	ui = new UserInterface(logic, state, spec);
  	ui.moneyAmount = querySelector("#money_amount_id");

  	Element econ1 = querySelector("#econ1");
  	Element econ2 = querySelector("#econ2");
  	Element build1 = econ1.querySelector("#buildButton");
  	build1.onClick.listen((MouseEvent e){
  		build1.classes.remove("enabled");
  		build1.classes.add("disabled");
  		econ2.classes.remove("hidden");
  		econ2.classes.add("enabled");
  		print("yes");
  	});

  	requestTick();
	});

}

void requestTick() {
	tick(new DateTime.now().millisecondsSinceEpoch);
}

void tick(int currentTime) {
	if (previousStepTime == -1000) {
		previousStepTime = currentTime;
	}

	while (previousStepTime + stepIntervalMs <= currentTime) {
		logic.step();
		ui.update();
		previousStepTime += stepIntervalMs;
	}

	new Future.delayed(const Duration(milliseconds: 20), () {
		requestTick();
	});
}
