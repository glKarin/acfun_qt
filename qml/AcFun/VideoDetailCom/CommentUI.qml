import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog {
    id: root;

    property alias text: contentArea.text;
    property string quoteId: "";
    property int quoteFloor: 0;
    property string quoteUsername: "";
    property string quoteContent: "";

    titleText: "添加评论";

    buttonTexts: ["发送", "取消"];
    onButtonClicked: if (index === 0) accept();

    content: Item {
        width: parent.width;
        height: root.platformContentMaximumHeight;
        TextArea {
            id: contentArea;
            anchors { fill: parent; margins: constant.paddingLarge; }
            focus: true;
            textFormat: TextEdit.PlainText;
            placeholderText: root.quoteId.length === 0 ? "输入评论内容" : "引用  #%1 %2 : \n%3".arg(root.quoteFloor).arg(root.quoteUsername).arg(root.quoteContent);
        }
    }

    onStatusChanged: {
        if (status === DialogStatus.Open){
            contentArea.forceActiveFocus();
            contentArea.openSoftwareInputPanel();
        }
    }
}
