import QtQuick 1.1
import com.nokia.meego 1.1

TextField {
    id: root;

		// begin(11 c)
		property alias actionKeyLabel: sip.actionKeyLabel;
		property bool search_icon_visible: true;
		signal returnPressed;

		function make_focus()
		{
			forceActiveFocus();
			platformOpenSoftwareInputPanel();
		}

		function make_blur()
		{
			platformCloseSoftwareInputPanel();
		}
		// end(11 c)
		
    signal typeStopped;
    signal cleared;

		// begin(11 c)
		platformSipAttributes:SipAttributes {
			id: sip;
			//actionKeyLabel: qsTr("Search");
			actionKeyHighlighted: actionKeyEnabled;
			actionKeyEnabled: root.text.length !== 0;
		}
		Keys.onReturnPressed:{
			root.returnPressed();
		}
		// end(11 c)

    onTextChanged: {
        inputTimer.restart();
    }

    platformStyle: TextFieldStyle {
			paddingLeft: searchIcon.width+constant.paddingMedium;
        paddingRight: clearButton.width;
    }

    Timer {
        id: inputTimer;
        interval: 500;
        onTriggered: root.typeStopped();
    }

    Image {
        id: searchIcon;
        anchors { left: parent.left; leftMargin: constant.paddingMedium; verticalCenter: parent.verticalCenter; }
				// begin(11 c)
				height: root.search_icon_visible ? constant.graphicSizeSmall : 10;
				width: root.search_icon_visible ? constant.graphicSizeSmall : 10;
				visible: root.search_icon_visible;
				// end(11 c)
        sourceSize: Qt.size(width, height);
        smooth: true;
				source: "image://theme/icon-m-toolbar-search";
    }

    ToolIcon {
        id: clearButton;
        anchors { right: parent.right; verticalCenter: parent.verticalCenter; }
        opacity: root.activeFocus ? 1 : 0;
        platformIconId: "toolbar-close";
				// begin(11 c)
				visible: !root.readOnly;
				// end(11 c)
        Behavior on opacity {
            NumberAnimation { duration: 100; }
        }
        onClicked: {
					// begin(11 c)
            root.text = "";
            root.cleared();
            root.forceActiveFocus();
            root.platformOpenSoftwareInputPanel();
						// end(11 c)
        }
    }
}
