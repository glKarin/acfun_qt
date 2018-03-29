import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"
import "../../js/main.js" as Script

MyPage {
    id: page;

    title: "我的发布";
    tools: ToolBarLayout {
        ToolButton {
            iconSource: "toolbar-back";
            onClicked: pageStack.pop();
        }
        ToolButton {
            iconSource: "toolbar-refresh";
            onClicked: internal.getlist();
        }
    }

    QtObject {
        id: internal;

        function getlist()
        {
            if(!Script.checkAuthData())
            {
                signalCenter.showMessage("请先登录");
                return;
            }
            view.getlist();
        }
    }

    ViewHeader {
        id: viewHeader;
        title: page.title;
    }

    UserContributeView{
        id: view;
        anchors {
            left: parent.left; top: viewHeader.bottom; right: parent.right;
            bottom: parent.bottom;
        }
        userId: acsettings.userId;
    }
    Component.onCompleted: internal.getlist();
}
