import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"
import "../../js/database.js" as Database

MyPage {
    id: page;
    title: "播放历史";

    tools: ToolBarLayout {
        ToolButton {
            iconSource: "toolbar-back";
            onClicked: pageStack.pop();
        }
        ToolButton {
            iconSource: "toolbar-refresh";
            onClicked: Database.loadHistory(view.model);
        }
        ToolButton {
            iconSource: "toolbar-delete";
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
    ViewHeader {
        id: viewHeader;
        title: page.title;
    }

    ListView {
        id: view;
        anchors { fill: parent; topMargin: viewHeader.height; }
        model: ListModel {}
        delegate: CommonDelegate {
            Button {
                anchors {
                    right: parent.right;
                    verticalCenter: parent.verticalCenter;
                }
                opacity: 0.6;
                enabled: !loading;
                width: height;
                iconSource: privateStyle.toolBarIconPath("toolbar-delete");
                visible: qobj.deleteMode;
                onClicked: qobj.remove_one(model.acId, index);
            }
        }
    }

    ScrollDecorator { flickableItem: view; }

    Component.onCompleted: Database.loadHistory(view.model);
}
