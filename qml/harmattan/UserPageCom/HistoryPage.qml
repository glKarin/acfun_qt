import QtQuick 1.1
import com.nokia.meego 1.1
import "../Component"
import "../../js/database.js" as Database

MyPage {
    id: page;

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back";
            onClicked: pageStack.pop();
        }
        ToolIcon {
            platformIconId: "toolbar-refresh";
            onClicked: Database.loadHistory(view.model);
        }
        ToolIcon {
            platformIconId: "toolbar-delete";
            onClicked: {
                var s = function(){
                    Database.clearHistory();
                    view.model.clear();
                }
                signalCenter.createQueryDialog("警告",
                                               "确定要清空历史记录？",
                                               "确定",
                                               "取消",
                                               s);
            }
        }
    }

		// begin(11 c)
		QtObject{
			id: qobj;
			property bool deleteMode: true;

			function remove_one(acid, index)
			{
				if(!acid || isNaN(index))
				{
					return;
				}
				Database.remove_one(acid.toString());
				view.model.remove(index);
			}
		}
		// end(11 c)

    ViewHeader {
        id: viewHeader;
        title: page.title;
    }

    ListView {
        id: view;
        anchors { fill: parent; topMargin: viewHeader.height; }
        model: ListModel {}
				// begin(11 c)
				delegate: CommonDelegate {
						Button {
							anchors {
								right: parent.right;
								verticalCenter: parent.verticalCenter;
							}
							opacity: 0.6;
							platformStyle: ButtonStyle {
								buttonWidth: buttonHeight;
							}
							enabled: !loading;
							iconSource: "image://theme/icon-m-toolbar-delete"
							visible: qobj.deleteMode;
							onClicked: qobj.remove_one(model.acId, index);
						}
				}
				// end(11 c)
    }

    ScrollDecorator { flickableItem: view; }

    Component.onCompleted: Database.loadHistory(view.model);
}
