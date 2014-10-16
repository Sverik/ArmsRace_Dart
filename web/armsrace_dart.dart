import 'dart:html';
import 'dart:async';

import 'src/logic.dart';
import 'src/ui.dart';
import 'src/state.dart';
import 'src/spec.dart';
import 'src/greet_ui.dart';
import 'src/end_ui.dart';
import 'src/server.dart';

const stepIntervalMs = 200;
const pollIntervalSteps = 15; // 5 sammu sekundis, 3 sekundi tagant poll
const NO_PREVIOUS_STEP = -1000;

/** Iga stepIntervalMs-inda millisekundi kohta tuleb üks samm teha. See muutuja näitab, millise millisekundi kohta viimati samm tehti. */
int previousStepTime = NO_PREVIOUS_STEP;

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

  Uri u = Uri.parse(window.location.search);

  conn = new Conn(dev: u.queryParameters.containsKey("dev"));

  greet = new GreetUi(querySelector("#greet"), window.localStorage, conn, startGame);
  greet.init();
  greet.show();

	spec = new Spec(conn);

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

    end = new EndUi(querySelector("#gameEnd"), conn, endGameClosed, ui.getArmImageName);
    end.init();

    try {
      if (u.queryParameters.containsKey("battle")) {
        int gameId = int.parse(u.queryParameters["battle"]);
        GameState gs = new GameState({
          "id" : gameId,
          "yourNumber" : 1,
          "player1" : "Alice",
          "player2" : "Bob",
          "winner": "Alice"
        });
        end.show(gs);
      }
    } catch (e) {}

  	window.onResize.listen((e){
  	  ui.resize();
  	});
	});

}

void startGame(GameState game) {
  gameState = game;
  state.reset();
  ui.reset();
  ui.updateState(game);
  logic.updateState(game);
  running = true;
  previousStepTime = NO_PREVIOUS_STEP;
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
	if (previousStepTime == NO_PREVIOUS_STEP) {
		previousStepTime = currentTime;
	}

	while (previousStepTime + stepIntervalMs <= currentTime) {
	  stepCounter++;

    handleRemote();
		logic.step();
		ui.update();
		previousStepTime += stepIntervalMs;

	  if (gameState.finished == true) {
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
