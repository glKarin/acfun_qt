import QtQuick 1.1

AbstractItem {
    id: root;

		implicitHeight: 100 + constant.paddingLarge*2;
    onClicked: signalCenter.view_user_detail_by_id(model.userId);

    Image {
        id: preview;
        anchors {
            left: root.paddingItem.left;
            top: root.paddingItem.top;
            bottom: root.paddingItem.bottom;
        }
        clip: true;
        width: 100;
        sourceSize.width: 100;
        fillMode: Image.PreserveAspectCrop;
        source: model.avatar;
    }
    Column {
        anchors {
            left: preview.right; leftMargin: constant.paddingMedium;
            right: root.paddingItem.right; top: root.paddingItem.top;
        }
        Text {
            width: parent.width;
            elide: Text.ElideRight;
            textFormat: Text.PlainText;
            font: constant.titleFont;
            color: constant.colorLight;
            text: model.username;
        }
        Text {
            width: parent.width;
            elide: Text.ElideRight;
            wrapMode: Text.Wrap;
            maximumLineCount: 1;
            textFormat: Text.PlainText;
            font: constant.subTitleFont;
            color: constant.colorMid;
            text: model.signature || "";
        }
        Text {
            width: parent.width;
            elide: Text.ElideRight;
            //textFormat: Text.PlainText;
            font: constant.subTitleFont;
            color: constant.colorDisabled;
						text: "<b>投稿: </b>" + model.contributes + "   " + "<b>粉丝: </b>" + model.followedCount;
        }
    }
}



