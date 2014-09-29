import 'dart:html';
import 'dart:async';

import 'src/logic.dart';
import 'src/ui.dart';
import 'src/state.dart';
import 'src/spec.dart';
import 'src/greet_ui.dart';
import 'src/end_ui.dart';
import 'src/server.dart';

/** Iga stepIntervalMs-inda millisekundi kohta tuleb üks samm teha. See muutuja näitab, millise millisekundi kohta viimati samm tehti. */
int previousStepTime = -1000;
const stepIntervalMs = 200;
const pollIntervalSteps = 15; // 5 sammu sekundis, 3 sekundi tagant poll

int stepCounter = 0;
int lastPollStep = 0;

Logic logic;
UserInterface ui;
Conn conn;
State state;
Spec spec;
bool running = false;

GreetUi greet;
EndUi end;

GameState gameState;

void main() {

  conn = new Conn();

  greet = new GreetUi(querySelector("#greet"), window.localStorage, conn, startGame);
  greet.init();
  greet.show();

  end = new EndUi(querySelector("#gameEnd"), endGameClosed);
  end.init();

	spec = new Spec();

	// Kui load lõpetab, kutsub ta parameetriks kaasa antud funktsiooni ehk initsialiseerimine jätkub.
	spec.load((){
	  state = new State();
  	logic = new Logic(state, spec, conn);

  	ui = new UserInterface(logic, state, spec, conn);
  	ui.moneyAmount = querySelector("#money_amount");
  	ui.incomeAmount = querySelector("#income_amount");
  	ui.economy = querySelector("#economy");
  	ui.arms = querySelector("#arms");
  	ui.init();

  	window.onResize.listen((e){
  	  ui.resize();
  	});
	});

}

void startGame(GameState game) {
  gameState = game;
  ui.updateState(game);
  logic.updateState(game);
  running = true;
  requestTick();
}

void endGameClosed() {
  greet.show();
}

void requestTick() {
  if (running) {
	 tick(new DateTime.now().millisecondsSinceEpoch);
  }
}

void tick(int currentTime) {
	if (previousStepTime == -1000) {
		previousStepTime = currentTime;
	}

	while (previousStepTime + stepIntervalMs <= currentTime) {
	  stepCounter++;

    handleRemote();
		logic.step();
		ui.update();
		previousStepTime += stepIntervalMs;

	  if (gameState.finished) {
      running = false;
      end.show(gameState);
    }
	}

	new Future.delayed(const Duration(milliseconds: 20), () {
		requestTick();
	});
}

void updateState(GameState game) {
  gameState = game;
  logic.updateState(game);
  ui.updateState(game);
}

void handleRemote() {
  if (stepCounter - lastPollStep >= pollIntervalSteps) {
    conn.pollGame(state, gameState.id.toString(), updateState);
    lastPollStep = stepCounter;
  }
}
