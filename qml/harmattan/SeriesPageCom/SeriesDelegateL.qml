import QtQuick 1.1
import "../Component"

AbstractItem {
    id: root;

    implicitHeight: 120 + constant.paddingLarge*2;
    onClicked: pageStack.push(Qt.resolvedUrl("SeriesDetailPage.qml"),
                              {acId: model.id});

    Image {
        id: preview;
        anchors {
            left: root.paddingItem.left;
            top: root.paddingItem.top;
            bottom: root.paddingItem.bottom;
        }
        clip: true;
        width: 160;
        sourceSize.width: 160;
        fillMode: Image.PreserveAspectCrop;
				// begin(11 c)
        source: model.cover_h || model.cover;
				// end(11 c)
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
            wrapMode: Text.Wrap;
            maximumLineCount: 1;
            textFormat: Text.PlainText;
            font: constant.subTitleFont;
            color: constant.colorMid;
            text: model.intro;
        }
        Text {
            width: parent.width;
            elide: Text.ElideRight;
            textFormat: Text.PlainText;
            font: constant.subTitleFont;
            color: constant.colorMid;
            text: model.subhead
        }
    }
}
