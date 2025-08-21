package gui;

import openfl.display.Sprite;
import haxe.ui.Toolkit;
import haxe.ui.core.Screen;
import haxe.ui.components.*;
import haxe.ui.containers.*;
import core.*;
import ai.NullAgent;

class Main extends Sprite {
  var inputArea:TextArea;
  var outputArea:TextArea;
  var fromSel:DropDown;
  var toSel:DropDown;

  public function new() {
    super();
    Toolkit.init();
    buildUI();
  }

  function buildUI() {
    var root = new VBox();
    root.percentWidth = 100;
    root.percentHeight = 100;
    root.padding = 10;
    root.gap = 8;

    var top = new HBox();
    top.gap = 10;

    fromSel = new DropDown();
    fromSel.dataSource = langData();
    fromSel.selectedIndex = 0;
    toSel = new DropDown();
    toSel.dataSource = langData();
    toSel.selectedIndex = 1;

    var convertBtn = new Button();
    convertBtn.text = "Convert";
    convertBtn.onClick = _ -> convert();

    top.addComponent(new Label("From:"));
    top.addComponent(fromSel);
    top.addComponent(new Label("To:"));
    top.addComponent(toSel);
    top.addComponent(convertBtn);

    inputArea = new TextArea();
    inputArea.percentWidth = 100;
    inputArea.percentHeight = 45;
    inputArea.placeholder = "Paste source code here...";

    outputArea = new TextArea();
    outputArea.percentWidth = 100;
    outputArea.percentHeight = 45;
    outputArea.readonly = true;

    root.addComponent(top);
    root.addComponent(inputArea);
    root.addComponent(outputArea);

    Screen.instance.addComponent(root);
  }

  function langData() {
    var ds = new haxe.ui.data.ArrayDataSource<Dynamic>();
    for (name in ["javascript","python","haxe"]) {
      ds.add({ text: name, value: name });
    }
    return ds;
  }

  function convert() {
    var from = Language.normalize(fromSel.selectedItem.value);
    var to = Language.normalize(toSel.selectedItem.value);
    var conv = new core.Converter(new NullAgent());
    var res = conv.convert(inputArea.text, from, to);
    outputArea.text = res;
  }
}
