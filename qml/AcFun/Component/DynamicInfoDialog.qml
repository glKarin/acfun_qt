import QtQuick 1.1
import com.nokia.symbian 1.1

HarmattanCommonDialog {
	id: root;

    property string message: "";

	signal linkActivated(url link);

	property int ui_SCROLLDECORATOR_LONG_MARGIN: 4;
	property int ui_FONT_DEFAULT: 24;

	property bool __isClosing: false;
	onStatusChanged: {
		if (status == DialogStatus.Closing){
			__isClosing = true;
		} else if (status == DialogStatus.Closed && __isClosing){
            root.destroy();
		}
	}
	Component.onCompleted: open();

	property variant m_platformStyle: QtObject{

		property int contentFieldMinSize: 24

		//spacing
		property int contentTopMargin: 21

		property string messageFontFamily: root.m_platformStyle.__fontFamily()
		property int messageFontPixelSize: ui_FONT_DEFAULT
		property color messageTextColor: "#ffffff"
		property string ui_FONT_FAMILY: "Nokia Pure Text";
		property string ui_FONT_FAMILY_FARSI: "Arial"

    function __fontFamily() {
            /*
        if (locale && locale.language == "fa") {
            return ui_FONT_FAMILY_FARSI;
        }
        */
        return ui_FONT_FAMILY;
    }

	}
    __platformModal: true;
	// the content field which contains the message text
	content: Item {
		id: queryContentWrapper

        property int maxListViewHeight : visualParent ? visualParent.height * 0.87 - h_platformStyle.titleBarHeight - h_platformStyle.contentSpacing - 50 : root.parent ? root.parent.height * 0.87 - h_platformStyle.titleBarHeight - h_platformStyle.contentSpacing - 50 : 350
		height: maxListViewHeight;
        width: parent.width;

		Item {
			id: queryContent
			width: parent.width

			y: root.m_platformStyle.contentTopMargin

			Flickable {
				id: queryFlickable
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.top: parent.top
				//anchors.bottom: parent.bottom
				height: queryContentWrapper.maxListViewHeight

				contentHeight: queryText.height
				flickableDirection: Flickable.VerticalFlick
				clip: true

				interactive:  queryText.height > queryContentWrapper.maxListViewHeight

				Text {
					id: queryText
					width: queryFlickable.width
					//horizontalAlignment: Text.AlignHCenter
					font.family: root.m_platformStyle.messageFontFamily
					font.pixelSize: root.m_platformStyle.messageFontPixelSize
					color: root.m_platformStyle.messageTextColor
					wrapMode: Text.WordWrap
					text: root.message
					onLinkActivated: root.linkActivated(link)
				}

			}


			ScrollDecorator {
				id: scrollDecorator
				flickableItem: queryFlickable
				anchors.rightMargin: - ui_SCROLLDECORATOR_LONG_MARGIN - 10 //ToDo: Don't use a hard-coded gap
			}

		}
	}
}

