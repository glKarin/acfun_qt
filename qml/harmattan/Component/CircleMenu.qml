import QtQuick 1.1
import com.nokia.meego 1.1

Item{
	id: root;

	objectName: "k_CircleMenu";

	property real radius;
	property real center_radius;
	property int animation_duration: 400;

	property alias tools: tool.children;

	property alias border: back.border;
	property alias color: back.color;
	property alias bg_opacity: back.opacity;

	property alias center_color: front.color;
	property alias center_opacity: front.opacity;
	property alias center_border: front.border;
	property bool opened: state === c_SHOW_STATE;
	property bool closed: state === c_HIDE_STATE;

	function open()
	{
		state = c_SHOW_STATE;
	}

	function close()
	{
		state = c_HIDE_STATE;
	}

	function toggle()
	{
		if(state === c_SHOW_STATE)
		{
			state = c_HIDE_STATE;
		}
		else
		{
			state = c_SHOW_STATE;
		}
	}

	width: radius;
	height: width;

	property real __per: center_radius / radius;
	property real __sub_width: width  * __per;
	property string c_SHOW_STATE: "show";
	property string c_HIDE_STATE: "hide";

	Behavior on x{
		NumberAnimation{}
	}

	Behavior on y{
		NumberAnimation{}
	}

	Rectangle{
		id: back;
		anchors.centerIn: parent;
		width: Math.max(root.width - border.width * 2, 0);
		height: width;
		radius: width / 2;
		smooth: true;
		color: "lightgrey";
		border.color: "black";
		border.width: 2;
		opacity: 0.6;
	}

	Rectangle{
		id: front;
		anchors.centerIn: parent;
		width: Math.max(root.__sub_width - border.width * 2, 0);
		height: width;
		z: Number.MAX_VALUE;
		radius: width / 2;
		smooth: true;
		color: "gray";
		border.color: "steelblue";
		border.width: 1;
		opacity: 0.8;
		ToolIcon{
			anchors.centerIn: parent;
			z: 1;
			width: Math.min(80, parent.width);
			height: width;
			platformIconId: "toolbar-close";
			onClicked: {
				root.close();
			}
		}
		MouseArea{
			anchors.fill: parent;
			drag.target: root;
			drag.minimumX: 0;
			drag.maximumX: root.parent ? root.parent.width - root.width : root.width;
			drag.minimumY: 0;
			drag.maximumY: root.parent ? root.parent.height - root.height : root.height;
			drag.filterChildren: true;
		}
	}

	Item{
		id: tool;
		anchors.fill: parent;
		z: 2;
		MouseArea{
			anchors.fill: parent;
			drag.target: root;
			drag.minimumX: 0;
			drag.maximumX: root.parent ? root.parent.width - root.width : root.width;
			drag.minimumY: 0;
			drag.maximumY: root.parent ? root.parent.height - root.height : root.height;
			drag.filterChildren: true;
		}
	}

	transform: Scale{
		id: scaler;
		origin.x : root.width / 2;
		origin.y : root.height / 2;
		xScale : 1.0;
		yScale : xScale;
	}

	states: [
		State{
			name: root.c_SHOW_STATE;
			changes: PropertyChanges{
				target: scaler;
				xScale: 1.0;
			}
		},
		State{
			name: root.c_HIDE_STATE;
			changes: PropertyChanges{
				target: scaler;
				xScale: 0.0;
			}
		}
	]

	transitions: [
		Transition{
			from: root.c_HIDE_STATE;
			to: root.c_SHOW_STATE;
			animations: NumberAnimation{
				target: scaler;
				property: "xScale";
				easing.type: Easing.OutExpo;
				duration: root.animation_duration;
			}
		},
		Transition{
			from: root.c_SHOW_STATE;
			to: root.c_HIDE_STATE;
			animations: NumberAnimation{
				target: scaler;
				property: "xScale";
				easing.type: Easing.InExpo;
				duration: root.animation_duration;
			}
		}
	]
	state: root.c_HIDE_STATE;
}

