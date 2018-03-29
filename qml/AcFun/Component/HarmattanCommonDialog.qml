import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog {
    id: genericDialog

    property bool __platformModal: false;
    property variant h_platformStyle: QtObject{
        property int titleBarHeight: 44;
        property int contentSpacing: 10;
        property real width: genericDialog.visualParent ? genericDialog.visualParent.width
                                                        : (genericDialog.parent ? genericDialog.parent.width : 360);
    }

    buttonTexts: ["关闭"];
    onButtonClicked: accept();
}

