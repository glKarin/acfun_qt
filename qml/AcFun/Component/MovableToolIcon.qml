import QtQuick 1.1
import com.nokia.symbian 1.1

Rectangle{
	id: root;
	property bool enabled: true;
	property color pressed_color: "lightseagreen";
	property color released_color: "lightskyblue";
	property color disabled_color: "lightgrey";
	property alias platformIconId: icon.platformIconId;
	property alias icon_rotation: icon.rotation;
	property real minimumX: 0
	property real maximumX: 0;
	property real minimumY: 0;
	property real maximumY: 0;

	property alias pressed: mouse_area.pressed;

	height: width;
	radius: width / 2;
	color: enabled ? (mouse_area.pressed ? pressed_color : released_color) : disabled_color;

	ToolIcon{
		id: icon;
		anchors.fill: parent;
		enabled: false;
	}
	MouseArea{
		id: mouse_area;
		anchors.fill: parent;
		enabled: root.visible && root.enabled;
		z: 1;
		drag.target: root;
		drag.minimumX: root.minimumX
		drag.maximumX: root.maximumX;
		drag.minimumY: root.minimumY;
		drag.maximumY: root.maximumY;
	}

	/*
	Behavior on x{
		NumberAnimation{}
	}

	Behavior on y{
		NumberAnimation{}
	}
	*/
}
