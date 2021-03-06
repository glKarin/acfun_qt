import QtQuick 1.1

AbstractItem {
    id: root;

    implicitHeight: 180 + constant.paddingLarge*2;
		onClicked: {
			signalCenter.view_album_detail(model.albumId);
		}

		Image {
			id: preview;
			anchors {
				left: root.paddingItem.left;
				top: root.paddingItem.top;
				bottom: root.paddingItem.bottom;
			}
			clip: true;
			width: 130;
			sourceSize.width: 130;
			fillMode: Image.PreserveAspectCrop;
			source: model.cover;
		}
		Column {
			anchors {
				left: preview.right; leftMargin: constant.paddingMedium;
				right: root.paddingItem.right; top: root.paddingItem.top;
			}
			Text {
				width: parent.width;
				elide: Text.ElideRight;
				wrapMode: Text.Wrap;
				maximumLineCount: 1;
				textFormat: Text.PlainText;
				font: constant.titleFont;
				color: constant.colorLight;
				text: model.title;
			}
			Text {
				width: parent.width;
				elide: Text.ElideRight;
				//textFormat: Text.PlainText;
				font: constant.labelFont;
				color: constant.colorLight;
				text: "<b>UP: </b>" + model.creatorName;
			}
			Text {
				width: parent.width;
				elide: Text.ElideRight;
				wrapMode: Text.Wrap;
				maximumLineCount: 3;
				textFormat: Text.PlainText;
				font: constant.subTitleFont;
				color: constant.colorMid;
				text: model.intro;
			}
			Text {
				width: parent.width;
				elide: Text.ElideRight;
				//textFormat: Text.PlainText;
				font: constant.subTitleFont;
				color: constant.colorLight;
				text: "<b>稿件数量: </b>" + model.contentSize;
			}
		}
	}

