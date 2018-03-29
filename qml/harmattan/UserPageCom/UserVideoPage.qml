import QtQuick 1.1
import com.nokia.meego 1.1
import "../Component"
import "../../js/main.js" as Script

MyPage {
    id: page;

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back";
            onClicked: pageStack.pop();
        }
        ToolIcon {
            platformIconId: "toolbar-refresh";
            onClicked: internal.getlist();
        }
    }

    QtObject {
        id: internal;

				// begin(11 c)
				function getlist()
				{
					if(!Script.checkAuthData())
					{
						signalCenter.showMessage("请先登录");
						return;
					}
					view.getlist();
				}
				// end(11 c)
    }

    ViewHeader {
        id: viewHeader;
        title: page.title;
    }
		// begin(11 c)
		UserContributeView{
			id: view;
			anchors {
				left: parent.left; top: viewHeader.bottom; right: parent.right;
				bottom: parent.bottom;
			}
			userId: acsettings.userId;
		}
		// end(11 c)

    Component.onCompleted: internal.getlist();
}
