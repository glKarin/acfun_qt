import QtQuick 1.1

Item {
    id: root;
		// begin(11 a)
		property bool inverted: false;
		// end(11 a)

    property string title;

    implicitWidth: parent.width;
    implicitHeight: text.height + constant.paddingMedium + constant.paddingLarge;

    Text {
        id: text;
        anchors {
            left: parent.left; leftMargin: constant.paddingSmall;
            top: parent.top; topMargin: constant.paddingLarge;
        }
        font: constant.titleFont;
				// begin(11 c)
				color: root.inverted ? "white" : constant.colorLight;
				// end(11 c)
        text: root.title;
    }

    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; }
        height: 1;
				// begin(11 c)
				color: root.inverted ? "white" : constant.colorDisabled;
				// end(11 c)
    }
}
