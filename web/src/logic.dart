library logic;

import 'state.dart';
import 'spec.dart';

class Logic {

	int stepCounter = 0;

	Spec spec;
	State state;

	bool incomeDirty = true;

	Logic(State state, Spec spec) : this.state = state, this.spec = spec {
	}

	void buildEcon(int id) {
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

	void buildArm(int id) {
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

			spec.econ.forEach((int id, EconomicBuilding econB){
				int count = state.getEcons(id);
				state.income += count * econB.income;
			});

			incomeDirty = false;
		}

		state.money += state.income;
	}
}