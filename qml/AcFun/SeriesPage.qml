import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"
import "SeriesPageCom" as Series
import "../js/main.js" as Script

MyPage {
    id: page;

    property int channelId: 1;
    Component.onCompleted: getlist();

    title: viewHeader.title;

    tools: ToolBarLayout {
        ToolButton {
            iconSource: "toolbar-back";
            onClicked: pageStack.pop();
        }
        ToolButton {
            iconSource: "toolbar-refresh";
            onClicked: getlist();
        }
        ToolButton {
            iconSource: flip.side === Flipable.Front
                        ? "toolbar-list" : "../gfx/grid.svg";
            onClicked: flip.state = flip.state === "" ? "back" : "";
        }
    }

    ViewHeader {
        id: viewHeader;
        title: "追剧"
    }

    QtObject{
        id: qobj;
        property int pageSize: 42;
        property int nextPage: 1;
        property int count: 0;
        property int pageCount: 0;
        property bool hasNext: false;
        property int is_new: 0;
        property int week: new Date().getDay();
        property int sorter: 1;
        property int asc: 0;

        function open_selection_dialog(i)
        {
            if(selection_dialog.index === i)
            {
                selection_dialog.toggle();
                return;
            }
            var si = row.children[i];
            selection_dialog.index = i;
            selection_dialog.header_offset = si.x + si.width / 2;
            selection_dialog.title_text = si.text;
            view.model = si.model;
            var index = 0;
            var param = ["sorter", "asc", "week"][i];
            var j;
            for(j = 0; j < view.model.count; j++)
            {
                if(view.model.get(j).value === qobj[param])
                {
                    index = j;
                    break;
                }
            }
            view.currentIndex = index;
            view.positionViewAtIndex(index, ListView.Beginning);
            selection_dialog.open();
        }

        function selected(n, v)
        {
            qobj[["sorter", "asc", "week"][selection_dialog.index]] = v;
            getlist();
        }
    }
    ButtonRow {
        id: buttonRow;
        anchors { left: parent.left; right: parent.right; top: viewHeader.bottom }
        Button {
            text: "全部"
            onClicked: {qobj.is_new = 0; getlist(); }
        }
        Button {
            text: "本季新番"
            onClicked: {qobj.is_new = 1; getlist(); }
        }
    }
    Row {
        id: row;
        anchors { left: parent.left; right: parent.right; top: buttonRow.bottom }
        height: 80;
        SelectButton {
            property variant model: ListModel{
                ListElement{
                    name: "更新日期";
                    value: 1;
                }
                ListElement{
                    name: "放送日期";
                    value: 6;
                }
                ListElement{
                    name: "创建日期";
                    value: 2;
                }
            }
            width: parent.width / 3;
            height: parent.height;
            text: "排序";
            value: {
                var i;
                switch(qobj.sorter)
                {
                case 2:
                    i = 2;
                    break;
                case 6:
                    i = 1;
                    break;
                case 1:
                default:
                    i = 0;
                    break;
                }
                return model.get(i).name;
            }
            onClicked: qobj.open_selection_dialog(0);
        }
        SelectButton {
            property variant model: ListModel{
                ListElement{
                    name: "倒序";
                    value: 0;
                }
                ListElement{
                    name: "正序";
                    value: 1;
                }
            }
            width: parent.width / 3;
            height: parent.height;
            text: "顺序";
            value: model.get(qobj.asc).name;
            onClicked: qobj.open_selection_dialog(1);
        }
        SelectButton {
            property variant model: ListModel{
                ListElement{
                    name: "星期日";
                    value: 0;
                }
                ListElement{
                    name: "星期一";
                    value: 1;
                }
                ListElement{
                    name: "星期二";
                    value: 2;
                }
                ListElement{
                    name: "星期三";
                    value: 3;
                }
                ListElement{
                    name: "星期四";
                    value: 4;
                }
                ListElement{
                    name: "星期五";
                    value:5;
                }
                ListElement{
                    name: "星期六";
                    value: 6;
                }
            }
            width: parent.width / 3;
            height: parent.height;
            visible: qobj.is_new == "1";
            text: "日期";
            value: model.get(qobj.week).name;
            onClicked: qobj.open_selection_dialog(2);
        }
    }

    Connections{
        target: Qt.application;
        onActiveChanged: {
            if(!Qt.application.active)
            {
                selection_dialog.close();
            }
        }
    }

    onStatusChanged: {
        if(status !== PageStatus.Active)
        {
            selection_dialog.close();
        }
    }

    MeeGoTouchHomeFolder{
        id: selection_dialog;
        property int index: -1;
        anchors.top: row.bottom;
        anchors.topMargin: constant.paddingMedium;
        anchors.leftMargin: constant.paddingLarge;
        anchors.rightMargin: constant.paddingLarge;
        anchors.left: parent.left;
        anchors.right: parent.right;
        z: 2;
        title_text: "";
        target_height: 300;
        base_of_content: false;
        content_opacity: 0.6;
        animation_duration: 180;

        content: ListView{
            id: view;
            anchors.fill: parent;
            clip: true;
            delegate: Component {
                id: defaultDelegate
                Item {
                    id: delegateItem
                    property string __colorString: "";
                    property bool selected: index == ListView.view.currentIndex;
                    property int itemHeight: 64
                    property color itemSelectedBackgroundColor: "#3D3D3D"
                    property color itemBackgroundColor: "transparent"
                    property int ui_CORNER_MARGINS: 22;
                    property url itemPressedBackground: ""; //image://theme/" + __colorString + "meegotouch-panel-inverted-background-pressed"
                    property url itemSelectedBackground: "" // "image://theme/" + __colorString + "meegotouch-list-fullwidth-background-selected"
                    property url itemBackground: ""
                    property color itemSelectedTextColor: "white"
                    property color itemTextColor: "white"
                    property int itemLeftMargin: 16
                    property int itemRightMargin: 16

                    height: itemHeight
                    anchors.left: parent.left
                    anchors.right: parent.right

                    MouseArea {
                        id: delegateMouseArea
                        anchors.fill: parent;
                        onPressed: parent.ListView.view.currentIndex = index;
                        onClicked: {
                            selection_dialog.close();
                            qobj.selected(model.name, model.value);
                        }
                    }

                    Rectangle {
                        id: backgroundRect
                        anchors.fill: parent
                        color: delegateItem.selected ? itemSelectedBackgroundColor : itemBackgroundColor
                    }

                    BorderImage {
                        id: background
                        anchors.fill: parent
                        border { left: ui_CORNER_MARGINS; top: ui_CORNER_MARGINS; right: ui_CORNER_MARGINS; bottom: ui_CORNER_MARGINS }
                        source: delegateMouseArea.pressed ? itemPressedBackground :
                                                            delegateItem.selected ? itemSelectedBackground :
                                                                                    itemBackground
                    }

                    Text {
                        id: itemText
                        elide: Text.ElideRight
                        color: delegateItem.selected ? itemSelectedTextColor : itemTextColor
                        anchors.verticalCenter: delegateItem.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: itemLeftMargin
                        anchors.rightMargin: itemRightMargin
                        text: model.name || modelData.name || modelData;
                        font: constant.labelFont;//root.platformStyle.itemFont
                    }
                }
            }
            ScrollDecorator { flickableItem: parent; }
        }
    }

    function getlist(option){
        selection_dialog.close();
        loading = true;
        var opt = {
            size: qobj.pageSize,
            "sorter": qobj.sorter,
            "asc": qobj.asc,
            model: seriesModel
        };
        if(qobj.is_new === 1)
        {
            opt.isNew = qobj.is_new;
            opt.week = qobj.week;
        }
        if (seriesModel.count === 0 || qobj.nextPage === 1) option = "renew";
        option = option || "renew";
        if (option === "renew"){
            opt.renew = true;
            qobj.nextPage = 1;
            opt.num = 1;
        } else {
            opt.num = qobj.nextPage;
        }
        function s(obj){
            loading = false;
            qobj.count = obj.data.totalCount;
            qobj.pageCount = obj.data.totalPage;
            if (obj.data.num >= obj.data.totalPage){
                qobj.hasNext = false;
            } else {
                qobj.hasNext = true;
                qobj.nextPage = obj.data.num + 1;
            }
        }
        function f(err){
            loading = false;
            signalCenter.showMessage(err);
        }
        Script.getPlaybill(opt, s, f);
    }

    ListModel { id: seriesModel; }

    Flipable {
        id: flip;
        anchors {
            left: parent.left; right: parent.right;
            top: row.bottom; bottom: parent.bottom;
        }
        front: GridView {
            id: gridView;
            clip: true;
            anchors.fill: parent;
            cellWidth: app.inPortrait ? width/3 : width/5;
            cellHeight: cellWidth/3*4+constant.paddingLarge;
            model: seriesModel;
            delegate: Series.SeriesDelegate {}
            footer: FooterItem {
                listView: GridView.view;
                visible: qobj.hasNext;
                enabled: !loading;
                onClicked: getlist("next");
            }
            ScrollDecorator { flickableItem: parent; }
        }
        back: ListView {
            id: listView;
            clip: true;
            anchors.fill: parent;
            model: seriesModel;
            delegate: Series.SeriesDelegateL {}
            section.property: "day";
            section.delegate: ListHeading {
                ListItemText {
                    anchors.fill: parent.paddingItem;
                    role: "Heading";
                    text: section;
                }
            }
            footer: FooterItem {
                visible: qobj.hasNext;
                enabled: !loading;
                onClicked: getlist("next");
            }
        }
        transform: Rotation {
            id: rotation;
            origin: Qt.vector3d(flip.width/2, flip.height/2, 0);
            axis: Qt.vector3d(0, 1, 0);
            angle: 0;
        }
        states: State {
            name: "back";
            PropertyChanges {
                target: rotation;
                angle: 180;
            }
        }
        transitions: Transition {
            RotationAnimation {
                direction: RotationAnimation.Clockwise;
            }
        }
    }

    ScrollDecorator {
        flickableItem: gridView;
        visible: flip.side === Flipable.Front;
    }
    SectionScroller {
        id: scroller;
        listView: null;
        visible: flip.side === Flipable.Back;
    }
}
