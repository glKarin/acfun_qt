import QtQuick 1.1
import com.nokia.meego 1.1

AbstractItem{
	id: root;

	objectName: "k_SelectButton";

	property bool opened: false;
	property bool animated: false;
	property alias text: label.text;
	property alias value: value_text.text;
	
	onClicked: {
		if(animated)
		{
			toggle();
		}
	}

	function open()
	{
		opened = true;
	}

	function close()
	{
		opened = false;
	}

	function toggle()
	{
		opened ^= 1;
	}

	Column{
		anchors.margins: constant.paddingMedium;
		anchors.fill: parent;
		spacing: constant.paddingMedium;

		Row{
			height: parent.height / 2;
			width: parent.width;
			anchors.horizontalCenter: parent.horizontalCenter;
			spacing: constant.paddingMedium;
			Text {
				id: label;
				width: parent.width - icon.width - parent.spacing;
				horizontalAlignment: Text.AlignHCenter;
				font: constant.labelFont;
				elide: Text.ElideRight;
				color: constant.colorLight;
				text: "";
			}
			ToolIcon{
				id: icon;
				anchors.verticalCenter: parent.verticalCenter;
				platformIconId: "toolbar-up";
				//enabled: false;
				onClicked: root.clicked();
				state: root.opened ? "" : "close";

				transform: Rotation {
					id: rotation;
					origin: Qt.vector3d(icon.width / 2, icon.height / 2, 0);
					axis: Qt.vector3d(1, 0, 0);
					angle: 0;
				}
				states: [
					State{
						name: "close";
						PropertyChanges {
							target: rotation;
							angle: -180;
						}
					}
				]
				transitions: [
					Transition {
						RotationAnimation {
							direction: RotationAnimation.Clockwise;
							duration: 100;
						}
					}
				]
			}
		}

		Text {
			id: value_text;
			height: parent.height / 2 - parent.spacing;
			width: parent.width;
			horizontalAlignment: Text.AlignHCenter;
			font: constant.subTitleFont;
			elide: Text.ElideRight;
			color: constant.colorMid;
			text: "";
		}
	}
}
