library state;

class State {
	int money;
	int income;

	Map<String, int> boughtEcons;
	Map<String, int> boughtArms;

	bool attacked;
	bool peaceOffer;

	State({var map}) {
	  if (map != null) {
  	  money = map['money'];
  	  income = map['income'];

  	  boughtEcons = map['econs'];
  	  boughtArms = map['arms'];
	  }
	}

	void reset() {
	  money = 500;
	  income = 0;

	  boughtEcons = new Map();
	  boughtArms = new Map();

	  attacked = false;
	  peaceOffer = false;
	}

	int getArms(String id) {
    int count = boughtArms[id];
    if (count == null) {
      count = 0;
    }
    return count;
	}

	int getEcons(String id) {
		int count = boughtEcons[id];
		if (count == null) {
			count = 0;
		}
		return count;
	}

	void setArms(String id, int count) {
		boughtArms[id] = count;
	}

	void setEcons(String id, int count) {
		boughtEcons[id] = count;
	}

}