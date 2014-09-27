library state;

class State {
	int money = 500;
	int income = 0;

	Map<int, int> boughtEcons = new Map();
	Map<int, int> boughtArms = new Map();

	int getArms(int id) {
    int count = boughtArms[id];
    if (count == null) {
      count = 0;
    }
    return count;
	}

	int getEcons(int id) {
		int count = boughtEcons[id];
		if (count == null) {
			count = 0;
		}
		return count;
	}

	void setArms(int id, int count) {
		boughtArms[id] = count;
	}

	void setEcons(int id, int count) {
		boughtEcons[id] = count;
	}

}