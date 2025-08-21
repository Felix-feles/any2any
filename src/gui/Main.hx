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
  var statusLbl:Label;

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
    root.spacing = 8;

    var top = new HBox();
    top.spacing = 10;

    fromSel = new DropDown();
    fromSel.dataSource = langData();
    fromSel.selectedIndex = 0;
    toSel = new DropDown();
    toSel.dataSource = langData();
    toSel.selectedIndex = 1;

    var convertBtn = new Button();
    convertBtn.text = "Convert";
    convertBtn.onClick = _ -> convert();

    var swapBtn = new Button();
    swapBtn.text = "Swap";
    swapBtn.onClick = _ -> {
      var tmp = fromSel.selectedIndex;
      fromSel.selectedIndex = toSel.selectedIndex;
      toSel.selectedIndex = tmp;
    };

    var clearBtn = new Button();
    clearBtn.text = "Clear";
    clearBtn.onClick = _ -> {
      inputArea.text = "";
      outputArea.text = "";
      statusLbl.text = "";
    };

    var fromLbl = new Label();
    fromLbl.text = "From:";
    top.addComponent(fromLbl);
    top.addComponent(fromSel);
    var toLbl = new Label();
    toLbl.text = "To:";
    top.addComponent(toLbl);
    top.addComponent(toSel);
    top.addComponent(convertBtn);
    top.addComponent(swapBtn);
    top.addComponent(clearBtn);

    inputArea = new TextArea();
    inputArea.percentWidth = 100;
    inputArea.percentHeight = 45;
    inputArea.placeholder = "Paste source code here...";

    outputArea = new TextArea();
    outputArea.percentWidth = 100;
    outputArea.percentHeight = 45;
    outputArea.readOnly = true;

    root.addComponent(top);
    root.addComponent(inputArea);
    root.addComponent(outputArea);

    statusLbl = new Label();
    root.addComponent(statusLbl);

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
    statusLbl.text = 'Converted from ' + Std.string(from) + ' to ' + Std.string(to);
  }
}
