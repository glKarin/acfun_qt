import QtQuick 1.1
import com.nokia.symbian 1.1

Item{
	id: root;

    objectName: "k_SwitchItem";
	property string text: "";
	property string open_text: "";
	property string close_text: "";
	property bool state_visible: false;
	property bool inverted: false;
	property bool label_proxy: false;

	property alias checked: switcher.checked;

	clip: true;

	Row{
		anchors.fill: parent;
		anchors.margins: constant.paddingSmall;
		spacing: constant.paddingLarge;
		Text{
			anchors.verticalCenter: parent.verticalCenter;
			width: parent.width - parent.spacing - switcher.width;
			font: constant.titleFont;
			color: root.inverted ? "white" : constant.colorLight;
			elide: Text.ElideRight;
			text: root.text + (root.state_visible ? ": " + (switcher.checked ? root.open_text : close_text) : "");
			MouseArea{
				enabled: root.label_proxy;
				anchors.fill: parent;
				onClicked: {
					switcher.checked ^= 1;
				}
			}
		}
		Switch{
			id: switcher;
			anchors.verticalCenter: parent.verticalCenter;
		}
	}
}
