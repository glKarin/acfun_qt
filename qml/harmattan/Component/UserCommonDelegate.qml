import QtQuick 1.1

Component {
	id: deleComp;
	AbstractItem {
		id: root;
		//enabled: model.state === "approved";
		implicitHeight: 90 + constant.paddingLarge*2;
		onClicked: signalCenter.viewDetail(model.acId, model.type);
		Image {
			id: preview;
			anchors {
				left: root.paddingItem.left;
				top: root.paddingItem.top;
				bottom: root.paddingItem.bottom;
			}
			width: 120;
			source: model.previewurl
		}
		Rectangle {
			id: stateRect;
			anchors.right: root.paddingItem.right;
			anchors.verticalCenter: parent.verticalCenter;
			height: stateLabel.height + constant.paddingMedium*2;
			width: stateLabel.width + constant.paddingMedium*2;
			color: "transparent";
			border { width: 2; color: constant.colorMid; }
			Text {
				id: stateLabel;
				anchors.centerIn: parent;
				font: constant.subTitleFont;
				color: constant.colorMid;
				text: Qt.formatDate(new Date(model.releaseDate), "yyyy-MM-dd");
			}
		}
		Column {
			anchors {
				left: preview.right; leftMargin: constant.paddingMedium;
				right: stateRect.left; rightMargin: constant.paddingMedium;
				top: root.paddingItem.top;
			}
			Text {
				width: parent.width;
				elide: Text.ElideRight;
				textFormat: Text.PlainText;
				font: constant.titleFont;
				color: constant.colorLight;
				text: model.name;
			}
			Text {
				width: parent.width;
				elide: Text.ElideRight;
				textFormat: Text.PlainText;
				font: constant.subTitleFont;
				color: constant.colorMid;
				text: model.desc;
				maximumLineCount: 2;
				wrapMode: Text.Wrap;
			}
		}
	}
}

