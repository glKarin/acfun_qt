import QtQuick 1.1
import com.nokia.symbian 1.1

// for port from Harmattan
ListHeading {
    id: root;
    property alias title: list_item_text.text;
    property bool inverted: false;

    platformInverted: inverted;
    ListItemText {
        id: list_item_text;
        anchors.fill: parent.paddingItem;
        role: "Heading";
        platformInverted: root.inverted;
    }
}
