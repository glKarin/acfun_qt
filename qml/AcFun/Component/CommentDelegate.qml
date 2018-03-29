import QtQuick 1.1
import "../../js/main.js" as Script

AbstractItem {
	id: root;
	// begin(11 c)
	signal avatarClicked(string userId);
	signal contentTextClicked(string commentId, int floorindex, string userName, string content);
	// end(11 c)

	implicitHeight: contentCol.height+constant.paddingLarge*2;
	Image {
		id: avatar;
		anchors {
			left: root.paddingItem.left;
			top: root.paddingItem.top;
		}
		width: constant.graphicSizeMedium;
		height: constant.graphicSizeMedium;
		sourceSize: Qt.size(width, height);
		source: model.userAvatar||"../../gfx/avatar.jpg";
		// begin(11 c)
		MouseArea{
			anchors.fill: parent;
			onClicked: {
				root.avatarClicked(model.userId);
			}
		}
		// end(11 c)
	}
	// begin(11 a)
	MouseArea{
		anchors.fill: contentCol;
		onClicked: {
			root.contentTextClicked(model.commentId, model.floorindex, model.userName, model.content);
		}
	}
	// end(11 a)
	Column {
		id: contentCol;
		anchors {
			left: avatar.right; leftMargin: constant.paddingSmall;
			right: root.paddingItem.right; top: root.paddingItem.top;
		}
		Item {
			width: parent.width;
			height: childrenRect.height;
			Text {
				anchors.left: parent.left;
				font: constant.labelFont;
				color: constant.colorMid;
				text: model.userName;
			}
			Text {
				anchors.right: parent.right;
				font: constant.labelFont;
				color: constant.colorMid;
				text: "#"+model.floorindex;
			}
		}
		Text {
			width: parent.width;
			wrapMode: Text.Wrap;
			font: constant.labelFont;
			color: constant.colorLight;
			// begin(11 c)
			text: Script.format_comment(model.content, "../../gfx/assets", true);
			onLinkActivated:{
				//pageStack.pop();
				//signalCenter.viewDetail(link);
				Script.handle_link(link);
			}
			// end(11 c)
		}
	}
}
