import 'dart:html';
import 'dart:async';

import 'src/logic.dart';
import 'src/ui.dart';
import 'src/state.dart';
import 'src/spec.dart';
import 'src/greet_ui.dart';

/** Iga stepIntervalMs-inda millisekundi kohta tuleb üks samm teha. See muutuja näitab, millise millisekundi kohta viimati samm tehti. */
int previousStepTime = -1000;
const stepIntervalMs = 200;
Logic logic;
UserInterface ui;
State state;
Spec spec;

void main() {

  GreetUi greet = new GreetUi(querySelector("#greet"));

  greet.init();

	spec = new Spec();

	// Kui load lõpetab, kutsub ta parameetriks kaasa antud funktsiooni ehk initsialiseerimine jätkub.
	spec.load((){
		state = new State();
  	logic = new Logic(state, spec);

  	ui = new UserInterface(logic, state, spec);
  	ui.moneyAmount = querySelector("#money_amount");
  	ui.incomeAmount = querySelector("#income_amount");
  	ui.economy = querySelector("#economy");
  	ui.arms = querySelector("#arms");
  	ui.init();

  	window.onResize.listen((e){
  	  ui.resize();
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
