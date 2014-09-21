library state;

class State {
	int money = 500;

	Map<int, int> boughtEcons = new Map();

	int getEcons(int id) {
		int count = boughtEcons[id];
		if (count == null) {
			count = 0;
		}
		return count;
	}

	void setEcons(int id, int count) {
		boughtEcons[id] = count;
	}

}