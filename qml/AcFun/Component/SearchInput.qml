import QtQuick 1.1
import com.nokia.symbian 1.1

TextField {
    id: root;

    property string actionKeyLabel: "";
    property bool search_icon_visible: true;
    signal returnPressed;

    function platformOpenSoftwareInputPanel()
    {
        openSoftwareInputPanel();
    }

    function platformCloseSoftwareInputPanel()
    {
        closeSoftwareInputPanel();
    }

    function make_focus()
    {
        forceActiveFocus();
        platformOpenSoftwareInputPanel();
    }

    function make_blur()
    {
        platformCloseSoftwareInputPanel();
    }

    signal typeStopped;
    signal cleared;
    Keys.onReturnPressed:{
        root.returnPressed();
    }
    onTextChanged: {
        inputTimer.restart();
    }

    platformLeftMargin: searchIcon.width + platformStyle.paddingMedium;
    platformRightMargin: clearButton.width + platformStyle.paddingMedium;

    Timer {
        id: inputTimer;
        interval: 500;
        onTriggered: root.typeStopped();
    }

    Image {
        id: searchIcon;
        anchors { left: parent.left; leftMargin: platformStyle.paddingMedium; verticalCenter: parent.verticalCenter; }
        height: root.search_icon_visible ? constant.graphicSizeSmall : 10;
        width: root.search_icon_visible ? constant.graphicSizeSmall : 10;
        visible: root.search_icon_visible;
        sourceSize: Qt.size(platformStyle.graphicSizeSmall, platformStyle.graphicSizeSmall);
        source: privateStyle.toolBarIconPath("toolbar-search", true);
    }

    Item {
        id: clearButton;
        anchors { right: parent.right; rightMargin: platformStyle.paddingMedium; verticalCenter: parent.verticalCenter; }
        height: platformStyle.graphicSizeSmall;
        width: platformStyle.graphicSizeSmall;
        opacity: root.activeFocus ? 1 : 0;
        visible: !root.readOnly;
        Behavior on opacity {
            NumberAnimation { duration: 100; }
        }
        Image {
            anchors.fill: parent;
            sourceSize: Qt.size(platformStyle.graphicSizeSmall, platformStyle.graphicSizeSmall);
            source: privateStyle.imagePath(clearMouseArea.pressed?"qtg_graf_textfield_clear_pressed":"qtg_graf_textfield_clear_normal", root.platformInverted);
        }
        MouseArea {
            id: clearMouseArea;
            anchors.fill: parent;
            onClicked: {
                root.text = "";
                root.cleared();
                root.forceActiveFocus();
                root.platformOpenSoftwareInputPanel();
            }
        }
    }
}
