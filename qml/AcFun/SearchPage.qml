import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"
import "../js/main.js" as Script
import "../js/keywordhistory.js" as KWdb

MyPage {
    id: page;

    title: "搜索";

    tools: ToolBarLayout {
        ToolButton {
            iconSource: "toolbar-back";
            onClicked: pageStack.pop();
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter;
            visible: view.model.count !== 0;
            elide: Text.ElideRight;
            textFormat: Text.PlainText;
            font: constant.labelFont;
            color: constant.colorLight;
            text: "按住搜索历史项可以删除该条";
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Active){
            searchInput.forceActiveFocus();
            searchInput.openSoftwareInputPanel();
            getlist();
        }
    }

    function getlist(opt){
        loading = true;
        if(!opt || opt === "hot")
        {
            function s(){ loading = false; }
            function f(err){ loading = false; signalCenter.showMessage(err); }
            Script.getHotkeys(hotModel, s, f);
        }
        if(!opt || opt === "history")
        {
            KWdb.loadHistory(view.model);
            loading = false;
        }
    }

    ViewHeader {
        id: viewHeader;

        SearchInput {
            id: searchInput;
            anchors {
                left: parent.left; right: searchBtn.left;
                margins: constant.paddingMedium;
                verticalCenter: parent.verticalCenter;
            }
            placeholderText: "输入关键词";
            actionKeyLabel: "搜索";
            onReturnPressed: {
                if (text.length === 0) return;
                searchBtn.clicked();
            }
        }

        Button {
            id: searchBtn;
            anchors {
                right: parent.right; rightMargin: constant.paddingMedium;
                verticalCenter: parent.verticalCenter;
            }
            text: "搜索";
            platformInverted: true;
            onClicked: {
                if (searchInput.text.length === 0) return;
                KWdb.storeHistory(searchInput.text);
                KWdb.loadHistory(view.model);
                var prop = { term: searchInput.text };
                var page = pageStack.push(Qt.resolvedUrl("SearchResultPage.qml"), prop);
                page.getlist();
            }
        }
    }

    SectionHeader {
        id: hot_header;
        anchors.top: viewHeader.bottom;
        anchors.left: parent.left;
        anchors.right: parent.right;
        title: "热门关键词"
        MouseArea{
            anchors.fill: parent;
            onClicked: {
                getlist("hot");
            }
        }
    }
    Flow {
        id: contentCol;
        anchors { top: hot_header.bottom; left: parent.left; right: parent.right; margins: constant.paddingMedium;}
        spacing: constant.paddingMedium;
        Repeater {
            model: ListModel { id: hotModel; }
            delegate: Component{
                Rectangle{
                    width: title.width + constant.paddingSmall;
                    height: title.height + constant.paddingSmall;
                    color: mouse_area.pressed ? "lightgray" : "black";
                    radius: 10;
                    smooth: true;
                    border.width: 2;
                    border.color: "lightseagreen";
                    Text{
                        id: title;
                        anchors.centerIn: parent;
                        text: model.name;
                        font: constant.subTitleFont;
                        color: constant.colorLight;
                        //font.bold: true;
                    }
                    MouseArea{
                        id: mouse_area;
                        anchors.fill: parent;
                        onClicked: {
                            searchInput.text = model.name;
                            searchBtn.clicked();
                        }
                    }
                }
            }
        }
    }
    SectionHeader {
        id: history_header;
        anchors.top: contentCol.bottom;
        anchors.left: parent.left;
        anchors.right: parent.right;
        title: "搜索历史"
        MouseArea{
            anchors.fill: parent;
            onClicked: {
                getlist("history");
            }
        }
    }
    ListView {
        id: view;
        anchors.top: history_header.bottom;
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.bottom: parent.bottom;
        model: ListModel {}
        clip: true;
        delegate: AbstractItem {
            Text {
                anchors { left: parent.paddingItem.left; verticalCenter: parent.verticalCenter; }
                font: constant.titleFont;
                color: constant.colorLight;
                text: model.name;
            }
            onClicked: {
                searchInput.text = model.name;
                searchBtn.clicked();
            }
            // begin(11 a)
            onPressAndHold:{
                KWdb.removeOneHistory(model.name);
                KWdb.loadHistory(view.model);
            }
            // end(11 a)
        }
        // begin(11 a)
        footer: FooterItem {
            text:"清空记录";
            visible: ListView.view.model.count !== 0;
            enabled: visible;
            onClicked: {
                KWdb.clearHistory();
                KWdb.loadHistory(view.model);
            }
        }
        // end(11 a)
    }
    ScrollDecorator { flickableItem: view; }
}
