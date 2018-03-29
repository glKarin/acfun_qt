import QtQuick 1.1
import com.nokia.meego 1.1
import "../Component"

Column {
    id: root;
    width: contentCol.width;
    property variant videos: model.videos;
    SectionHeader {
        id: listHeading;
        title: model.name;
        Text {
            anchors {
                right: parent.right; rightMargin: constant.paddingSmall;
                top: parent.top; topMargin: constant.paddingLarge;
            }
            font: constant.titleFont;
            color: constant.colorLight;
						// begin(11 c)
						text: (model.action_name !== undefined && (model.action_name === 11 || model.action_name === 6))/*model.id !== undefined*/ ? ">>" : "";
						// end(11 c)
        }
        MouseArea {
            anchors.fill: parent;
						// begin(11 c)
						enabled: model.action_name !== undefined && (model.action_name === 11 || model.action_name === 6)/*model.id !== undefined*/;
						onClicked: {
							internal.enterClass(model.action_name, model.id);
						}
						// end(11 c)
        }
    }
    ListView {
        id: listView;
        anchors { left: parent.left; right: parent.right; }
        height: 120 + constant.graphicSizeSmall;
        model: videos;
        orientation: ListView.Horizontal;
        delegate: Item {
            implicitWidth: 160;
            implicitHeight: ListView.view.height;
            Image {
                id: previewImg;
                width: 160; height: 120;
                sourceSize: Qt.size(160, 120);
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
                        ? "" : "image://theme/icon-m-toolbar-gallery";
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
								// begin(11 c)
								onClicked: internal.enterClass(model.action_name, model.acId);
								// end(11 c)
            }
        }
    }
}
