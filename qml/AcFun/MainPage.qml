import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"
import "MainPageCom"
import "../js/main.js" as Script

MyPage {
    id: page;
    title: "Acfun for Symbian";

    tools: ToolBarLayout {
        ToolButton {
            Timer { id: quitTimer; interval: 3000; }
            iconSource: "toolbar-back";
            onClicked: {
                if (quitTimer.running) Qt.quit();
                else { quitTimer.start(); signalCenter.showMessage("再按一次退出程序") }
            }
        }
        ToolButton {
            iconSource: "../gfx/calendar.svg";
            onClicked: pageStack.push(Qt.resolvedUrl("SeriesPage.qml"));
        }
        ToolButton {
            iconSource: "../gfx/rank.svg";
            onClicked: pageStack.push(Qt.resolvedUrl("RankingPage.qml"));
        }
        ToolButton {
            iconSource: "toolbar-menu";
            onClicked: mainMenu.open();
        }
    }

    Connections {
        target: signalCenter;
        onInitialized: {
            if (acsettings.showFirstHelp){
                Qt.createComponent("MainPageCom/FirstStartInfo.qml").createObject(page);
            }
            if(utility.is_update())
            {
                signalCenter.open_info_dialog("更新", signalCenter.c_KARIN_UPDATE, undefined, function(){
                    internal.refresh();
                });
            }
            else
            {
                internal.refresh();
            }
        }
    }

    QtObject {
        id: internal;

        function refresh(){
            Script.getVideoCategories();
            get_home();
        }

        function get_home()
        {
            headerView.loading = true;
            headerView.error = false;
            placeHolder.loading = true;
            placeHolder.error = false;
            var opt = {
                "header_model": headerView.model,
                "category_model": homeModel
            };
            function s(){
                headerView.loading = false;
                placeHolder.loading = false;
            }
            function f(err){
                headerView.loading = false;
                placeHolder.loading = false;
                signalCenter.showMessage(err);
                headerView.error = true;
                placeHolder.error = true;
            }
            Script.make_home(opt, s, f);
        }

        function enterClass(action_name, href){
            Script.handle_home_action(action_name, href);
        }
    }

    Menu {
        id: mainMenu;
        MenuLayout {
            MenuItem {
                text: "分区";
                onClicked: pageStack.push(Qt.resolvedUrl("ExtensionPage.qml"));
            }
            MenuItem {
                text: "设置";
                onClicked: pageStack.push(Qt.resolvedUrl("SettingPage.qml"));
            }
            MenuItem {
                text: "关于";
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"));
            }
            MenuItem {
                text: "个人中心";
                onClicked: {
                    if (Script.checkAuthData()){
                        var prop = { uid: acsettings.userId }
                        pageStack.push(Qt.resolvedUrl("UserPage.qml"), prop);
                    }
                }
            }
            MenuItem {
                text: "里区入口~";
                onClicked: {
                    var p = pageStack.push(Qt.resolvedUrl("SeriesPageCom/WikiPage.qml"));
                    p.load();
                }
            }
        }
    }

    ViewHeader {
        id: viewHeader;
        Image {
            anchors.centerIn: parent;
            sourceSize.height: parent.height - constant.paddingMedium*2;
            source: "../gfx/image_logo.png";
        }
        ToolButton {
            anchors {
                right: parent.right; verticalCenter: parent.verticalCenter;
            }
            iconSource: "toolbar-search";
            onClicked: pageStack.push(Qt.resolvedUrl("SearchPage.qml"));
        }
    }

    Flickable {
        id: view;
        anchors { fill: parent; topMargin: viewHeader.height; }
        contentWidth: view.width;
        contentHeight: contentCol.height;
        Column {
            id: contentCol;
            anchors { left: parent.left; right: parent.right; }
            PullToActivate {
                myView: view;
                enabled: !busyInd.visible;
                onRefresh: internal.refresh();
            }
            HeaderView {
                id: headerView;
                onRefresh: {
                    Script.getVideoCategories();
                    internal.get_home();
                }
            }
            Repeater {
                model: ListModel { id: homeModel; }
                HomeRow {}
            }
            Item {
                id: placeHolder;
                property bool loading: false;
                property bool error: false;
                anchors { left: parent.left; right: parent.right; }
                height: view.height - headerView.height;
                visible: homeModel.count === 0;
                Button {
                    width: height;
                    anchors.centerIn: parent;
                    iconSource: privateStyle.toolBarIconPath("toolbar-refresh");
                    visible: placeHolder.error;
                    onClicked: {
                        Script.getVideoCategories();
                        internal.get_home();
                    }
                }
            }
        }
    }

    BusyIndicator {
        id: busyInd;
        anchors.centerIn: parent;
        running: true;
        width: constant.graphicSizeLarge;
        height: constant.graphicSizeLarge;
        visible: placeHolder.loading || headerView.loading;
    }

    ScrollDecorator { flickableItem: view; }
}
