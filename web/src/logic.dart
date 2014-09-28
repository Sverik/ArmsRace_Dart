library logic;

import 'state.dart';
import 'spec.dart';
import 'server.dart';

class Logic {
  static const pollIntervalSteps = 15; // 5 sammu sekundis, 3 sekundi tagant poll

	int stepCounter = 0;
	int lastPollStep = 0;

	Spec spec;
	State state;
	Conn conn;

	bool incomeDirty = true;

	Logic(State state, Spec spec, Conn conn) : this.state = state, this.spec = spec, this.conn = conn {
	}

	void buildEcon(String id) {
		EconomicBuilding econ = spec.getEcon(id);
		// Igaks juhuks.
		if (econ == null) {
			return;
		}

		// Kui raha ei ole, ei saa osta.
		if (econ.cost > state.money) {
			return;
		}

		state.setEcons(id, state.getEcons(id) + 1);
		state.money -= econ.cost;

		incomeDirty = true;
	}

	void buildArm(String id) {
    Armament arm = spec.getArm(id);
    // Igaks juhuks.
    if (arm == null) {
      return;
    }

    // Kui raha ei ole, ei saa osta.
    if (arm.cost > state.money) {
      return;
    }

    state.setArms(id, state.getArms(id) + 1);
    state.money -= arm.cost;
	}

	void step() {
		stepCounter++;

		if (incomeDirty) {
			state.income = 0;

			spec.econ.forEach((String id, EconomicBuilding econB){
				int count = state.getEcons(id);
				state.income += count * econB.income;
			});

			incomeDirty = false;
		}

		state.money += state.income;

		handleRemote();
	}

  void handleRemote() {
    if (stepCounter - lastPollStep >= pollIntervalSteps) {
      conn.pollGame(state, (GameState gameState){
      });
      lastPollStep = stepCounter;
    }
  }
}