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

	UserInterface(Logic logic, State state, Spec spec) :
		this.logic = logic,
		this.state = state,
		this.spec = spec;

	void update() {
		moneyAmount.setInnerHtml(state.money.toString());
	}
}