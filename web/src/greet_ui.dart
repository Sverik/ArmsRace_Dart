library greet_ui;

import 'dart:html';

class GreetUi {
  Element greetDiv;

  GreetUi(Element greetDiv) :
    this.greetDiv = greetDiv;

  void init() {
    Element startButton = greetDiv.querySelector("#startButton");
    startButton.onClick.listen((e){
      greetDiv.style.visibility = "hidden";
    });
  }
}