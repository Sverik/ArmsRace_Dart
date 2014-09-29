library state;

class State {
	int money = 500;
	int income = 0;

	Map<String, int> boughtEcons = new Map();
	Map<String, int> boughtArms = new Map();

	bool attacked = false;
	bool peaceOffer = false;

	State({var map}) {
	  if (map != null) {
  	  money = map['money'];
  	  income = map['income'];

  	  boughtEcons = map['econs'];
  	  boughtArms = map['arms'];
	  }
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