import QtQuick 1.1

Item{
	id: root;
	objectName: "k_MeeGoTouchHomeFolder";
	property int border_width: 2;
	property color border_color: "white";
	property color bg_color: "black";
	property int animation_duration: 400;
	property alias title_color: title.color;
	property alias title_text: title.text;
	property alias content: content.children;
	property real target_height: 0;
	property bool base_of_content: false;
	property real header_offset: 0;
	property alias content_opacity: body.opacity;

	QtObject{
		id: qobj;
		property string c_SHOW_STATE: "show";
		property string c_HIDE_STATE: "hide";
		property real theight: root.base_of_content ? root.border_width + root.border_width + 8 + title_bar.height + root.target_height : root.target_height;
		property real min_height: root.border_width + root.border_width + 8 + title_bar.height;
	}

	visible: height >= qobj.min_height;

	function toggle()
	{
		if(state === qobj.c_SHOW_STATE)
		{
			state = qobj.c_HIDE_STATE;
		}
		else
		{
			state = qobj.c_SHOW_STATE;
		}
	}

	function open()
	{
			state = qobj.c_SHOW_STATE;
	}

	function close()
	{
			state = qobj.c_HIDE_STATE;
	}

	width: parent.width;
	state: qobj.c_HIDE_STATE;

	states: [
		State{
			name: qobj.c_SHOW_STATE;
			PropertyChanges {
				target: root;
				height: qobj.theight;
			}
		}
		,
		State{
			name: qobj.c_HIDE_STATE;
			PropertyChanges {
				target: root;
				height: 0;
			}
		}
	]
	transitions: [
		Transition {
			from: qobj.c_HIDE_STATE;
			to: qobj.c_SHOW_STATE;
			NumberAnimation{
				target: root;
				property: "height";
				easing.type: Easing.OutExpo;
				duration: root.animation_duration;
			}
		}
		,
		Transition {
			from: qobj.c_SHOW_STATE;
			to: qobj.c_HIDE_STATE;
			NumberAnimation{
				target: root;
				property: "height";
				easing.type: Easing.InExpo;
				duration: root.animation_duration;
			}
		}
	]

	// top line
	Rectangle{
		id: top_line;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.top: parent.top;
		anchors.topMargin: 8;
		height: root.border_width;
		color: root.border_color;
	}
	// triangle
	Rectangle{
		id: triangle;
		anchors.left: parent.left;
		anchors.leftMargin: root.header_offset/* + width / 2*/;
		anchors.top: parent.top;
		z: 1;
		width: 20;
		height: width;
		color: root.bg_color;
		rotation: 45;
		border.width: root.border_width;
		border.color: root.border_color;
	}
	// title
	Rectangle{
		id: title_bar;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.top: top_line.bottom;
		height: 60;
		z: 3;
		color: root.bg_color;
		Text{
			id: title;
			anchors.fill: parent;
			anchors.leftMargin: constant.paddingLarge;
			font: constant.labelFont;
			horizontalAlignment: Text.AlignLeft;
			verticalAlignment: Text.AlignVCenter;
			elide: Text.ElideRight;
			textFormat: Text.PlainText;
			color: "white";
			text: "";
		}
	}
	// body
	Rectangle{
		id: body;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.top: title_bar.bottom;
		anchors.bottom: root.base_of_content ? undefined : bottom_line.top;
		z: 2;
		color: root.bg_color;
		height: root.base_of_content ? content.height : undefined;
		Item{
			id: content;
			anchors.left: parent.left;
			anchors.top: parent.top;
			anchors.right: parent.right;
			anchors.bottom: root.base_of_content ? undefined : parent.bottom;
			//height: root.base_of_content ? childrenRect.height : undefined;
			state: root.base_of_content ? root.state : "";
			visible: height >= childrenRect.height;
			states: [
				State{
					name: qobj.c_SHOW_STATE;
					PropertyChanges {
						target: content;
						height: root.target_height;
					}
				}
				,
				State{
					name: qobj.c_HIDE_STATE;
					PropertyChanges {
						target: content;
						height: 0;
					}
				}
			]
			transitions: [
				Transition {
					from: qobj.c_HIDE_STATE;
					to: qobj.c_SHOW_STATE;
					NumberAnimation{
						target: content;
						property: "height";
						easing.type: Easing.OutExpo;
						duration: root.animation_duration;
					}
				}
				,
				Transition {
					from: qobj.c_SHOW_STATE;
					to: qobj.c_HIDE_STATE;
					NumberAnimation{
						target: content;
						property: "height";
						easing.type: Easing.InExpo;
						duration: root.animation_duration;
					}
				}
			]
		}
	}
	// bottom line
	Rectangle{
		id: bottom_line;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.top: root.base_of_content ? body.bottom : undefined;
		anchors.bottom: root.base_of_content ? undefined : parent.bottom;
		height: root.border_width;
		color: root.border_color;
	}
}
