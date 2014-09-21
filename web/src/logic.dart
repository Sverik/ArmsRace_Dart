library logic;

import 'state.dart';
import 'spec.dart';

class Logic {

	int stepCounter = 0;

	Spec spec;
	State state;

	Logic(State state, Spec spec) : this.state = state, this.spec = spec {
	}

	void step() {
		stepCounter++;
		state.money ++;
	}
}