import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"
import "../js/main.js" as Script

MyPage {
    id: page;

    title: viewHeader.title;

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

    Component.onCompleted: {
        internal.make_channel_model(false);
        internal.getlist();
    }

    QtObject {
        id: internal;

        property int pageNumber: 1;
        property int totalNumber: 0;
        property int pageSize: 20;

        property bool has_next_page: false;
        property int classId: 0;
        property bool isoriginal: true; // instead of is_banana
        property int day: 1;

        function make_channel_model(force)
        {
            var b = false;
            if(force !== undefined)
            {
                b = force;
            }
            channel_list.model.clear();
            if(!b && signalCenter.videocategories)
            {
                Script.make_ranking_model(signalCenter.videocategories, channel_list.model);
            }
            else
            {
                function s()
                {
                    if(!signalCenter.videocategories)
                    {
                        return;
                    }
                    Script.make_ranking_model(signalCenter.videocategories, channel_list.model);
                }
                function f(err)
                {
                    titleBanner.loading = false;
                    titleBanner.error = true;
                    signalCenter.showMessage(err);
                }
                Script.get_categories(s, f);
            }
            channel_list.currentIndex = 0;
        }

        function getlist(option){
            loading = true;
            var opt = {
                model: view.model,
                "class": classId,
                isoriginal: isoriginal,
                "pageSize": pageSize,
                "day": day
            };
            if (view.count === 0) option = "renew";
            option = option || "renew";
            if (option === "renew"){
                opt.renew = true;
                totalNumber = 0;
                pageNumber = 1;
                has_next_page = false;
            } else {
                opt.cursor = pageNumber + 1;
            }
            function s(obj){
                loading = false;
                has_next_page = false;
                if(obj.vdata.list && Array.isArray(obj.vdata.list))
                {
                    if(obj.vdata.list.length !== 0)
                    {
                        if (option !== "renew"){
                            pageNumber += 1;
                        }
                        totalNumber += obj.vdata.list.length;
                        has_next_page = (obj.vdata.list.length === pageSize);
                    }
                    //pageSize = 20;
                }
            }
            function f(err){ loading = false; signalCenter.showMessage(err); }
            Script.get_rank(opt, s, f);
        }
    }

    ViewHeader {
        id: viewHeader;
        title: "排名";
    }

    Item{
        id: channel_tab;
        anchors {
            left: parent.left; right: parent.right;
            top: viewHeader.bottom;
        }
        height: 80;
        ListView {
            id: channel_list;
            anchors {
                fill: parent;
                leftMargin: constant.paddingSmall;
                rightMargin: constant.paddingSmall;
                topMargin: constant.paddingMedium;
                bottomMargin: constant.paddingMedium;
            }
            clip: true;
            orientation: ListView.Horizontal;
            model: ListModel {}
            spacing: constant.paddingMedium;
            delegate: Component {
                Item{
                    id: delegate_root
                    width: 120;
                    height: ListView.view.height;
                    Rectangle{
                        anchors.fill: parent;
                        anchors.margins: border.width;
                        color: delegate_root.ListView.isCurrentItem ? "lightskyblue" : "black";
                        radius: 10;
                        smooth: true;
                        border.width: 4;
                        border.color: delegate_root.ListView.isCurrentItem ? "red" : "lightseagreen";
                        Text{
                            anchors.verticalCenter: parent.verticalCenter;
                            width: parent.width;
                            horizontalAlignment: Text.AlignHCenter;
                            elide: Text.ElideRight;
                            text: model.name;
                            color: constant.colorLight;
                            font.family: constant.subTitleFont.family;
                            font.pixelSize: constant.subTitleFont.pixelSize;
                            font.bold: delegate_root.ListView.isCurrentItem;
                        }
                        MouseArea{
                            anchors.fill: parent;
                            onClicked: {
                                internal.isoriginal = model.is_banana;
                                internal.classId = model.channel_id;
                                delegate_root.ListView.view.currentIndex = index;
                                internal.getlist();
                            }
                        }
                    }
                }
            }
        }
    }

    ButtonRow {
        id: btnRow;
        anchors { top: channel_tab.bottom; left: parent.left; right: parent.right; }
        Button {
            //height: privateStyle.tabBarHeightLandscape;

            text: "日";
            onClicked: {
                internal.day = 1;
                internal.getlist();
            }
        }
        Button {
            //height: privateStyle.tabBarHeightLandscape;
            text: "周";
            onClicked: {
                internal.day = 7;
                internal.getlist();
            }
        }
        Button {
            //height: privateStyle.tabBarHeightLandscape;
            text: "不限";
            onClicked: {
                internal.day = -1;
                internal.getlist();
            }
        }
    }

    ListView {
        id: view;
        anchors {
            left: parent.left; right: parent.right;
            top: btnRow.bottom; bottom: parent.bottom;
        }
        clip: true;
        model: ListModel {}
        delegate: CommonDelegate {}
        footer: FooterItem {
            visible: internal.has_next_page;
            enabled: !loading;
            onClicked: internal.getlist("next");
        }
    }

    ScrollDecorator { flickableItem: view; }
}
