import QtQuick 1.1
import com.nokia.symbian 1.1

Column {
    id: root;
    width: contentCol.width;
    property variant videos: model.videos;
    ListHeading {
        id: listHeading;
        ListItemText {
            id: list_item_list;
            anchors.fill: parent.paddingItem;
            role: "Heading";
            text: model.name;
        }
        MouseArea {
            anchors.fill: parent;
            enabled: model.action_name !== undefined && (model.action_name === 11 || model.action_name === 6)/*model.id !== undefined*/;
            onClicked: {
                internal.enterClass(model.action_name, model.id);
            }
        }
        Component.onCompleted: {
             if(model.action_name !== undefined && (model.action_name === 11 || model.action_name === 6))
             {
                 list_item_list.text += "   >>";
             }
        }
    }
    ListView {
        id: listView;
        anchors { left: parent.left; right: parent.right; }
        height: 90 + constant.graphicSizeSmall;
        model: videos;
        orientation: ListView.Horizontal;
        delegate: Item {
            implicitWidth: 120;
            implicitHeight: ListView.view.height;
            Image {
                id: previewImg;
                width: 120; height: 90;
                sourceSize: Qt.size(120, 90);
                source: model.previewurl;
                smooth: true;
                onStatusChanged: {
                    if (status === Image.Error){
                        source = "../../gfx/cover-day.png";
                    }
                }
            }
            Image {
                anchors.centerIn: previewImg;
                source: previewImg.status === Image.Ready
                        ? "" : "../../gfx/photos.svg";
            }
            Text {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom; }
                height: constant.graphicSizeSmall;
                horizontalAlignment: Text.AlignHCenter;
                verticalAlignment: Text.AlignVCenter;
                font: constant.labelFont;
                color: constant.colorLight;
                text: model.name;
                textFormat: Text.StyledText;
                elide: Text.ElideRight;
                maximumLineCount: 1;
                wrapMode: Text.Wrap;
            }
            Rectangle {
                anchors.fill: parent;
                color: "black";
                opacity: mouseArea.pressed ? 0.3 : 0;
            }
            MouseArea {
                id: mouseArea;
                anchors.fill: parent;
                onClicked: internal.enterClass(model.action_name, model.acId);
            }
        }
    }
}
