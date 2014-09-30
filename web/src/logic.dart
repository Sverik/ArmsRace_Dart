library logic;

import 'state.dart';
import 'spec.dart';
import 'server.dart';

class Logic {
	Spec spec;
	State state;
	Conn conn;
	GameState gameState;

	bool incomeDirty = true;

	Logic(State state, Spec spec, Conn conn) : this.state = state, this.spec = spec, this.conn = conn {
	}

	void buildEcon(String id) {
    if ( ! _actionAllowed()) {
      return;
    }

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
	  if ( ! _actionAllowed()) {
	    return;
	  }

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
    if ( ! _stepAllowed()) {
      return;
    }

		if (incomeDirty) {
			state.income = 0;

			spec.econ.forEach((String id, EconomicBuilding econB){
				int count = state.getEcons(id);
				state.income += count * econB.income;
			});

			incomeDirty = false;
		}

		state.money += state.income;

	}

	void updateState(GameState gameState) {
	  this.gameState = gameState;
	}

	bool _actionAllowed() {
	  if ( ! _stepAllowed()) {
	    return false;
	  }

    if (state.attacked == true) {
      return false;
    }

	  return true;
	}

	bool _stepAllowed() {
	  if (gameState == null) {
	    return false;
	  }

	  if (gameState.finished == true) {
	    return false;
	  }

	  if (gameState.endTime < conn.getCurrentServerTime()) {
	    return false;
	  }

	  if (conn.getCurrentServerTime() < gameState.startTime) {
	    return false;
	  }

	  return true;
	}

}