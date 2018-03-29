import QtQuick 1.1
import com.nokia.symbian 1.1
// begin(11 a)
import com.nokia.extras 1.1
// end(11 a)
import "Component"
import "../js/main.js" as Script

MyPage {
    id: page;

    property int cid: -1;
    property int pid: -1;
    property string cname;

    title: viewheader.title;

    tools: ToolBarLayout {
        ToolButton {
            iconSource: "toolbar-back";
            onClicked: pageStack.pop();
        }
        ToolButton {
            iconSource: "toolbar-refresh";
            onClicked: getlist();
        }
    }

    function getlist(){ internal.loadModel(); internal.getlist(); }

    QtObject {
        id: internal;

        property int pageNumber: 1;
        property int totalNumber: 0;
        property int pageSize: 20;

        property bool has_next_page: false;
        property int classId: page.cid;
        property string className;

        function make_tumbler_model()
        {
            tumblermodel.clear();
            if(!signalCenter.videocategories)
            {
                return;
            }
            Script.make_one_category_model(signalCenter.videocategories, tumblermodel);
        }

        function setClass(){
            var item = tumblermodel.get(channelstc.selectedIndex);
            if (item){
                var item2 = item.children.get(subchannelstc.selectedIndex);
                if(item2)
                {
                    classId = item2.channel_id;
                    className = item2.value;
                    page.cname = item.value;
                }
            }
        }

        function loadModel(){
            make_tumbler_model();
            var c_id = 0;
            var sub_c_id = 0;
            if(page.pid === 0)
            {
                c_id = page.cid;
                sub_c_id = -1;
            }
            else
            {
                c_id = page.pid;
                sub_c_id = page.cid;
            }
            //console.log(page.cid + "_" + page.pid);
            var i;
            for(i = 0; i < tumblermodel.count; i++)
            {
                if(tumblermodel.get(i).channel_id == c_id)
                {
                    channelstc.selectedIndex = i;
                    var item = tumblermodel.get(i);
                    subchannelstc.items = item.children;
                    if(sub_c_id === -1)
                    {
                        subchannelstc.selectedIndex = 0;
                    }
                    else
                    {
                        subchannelstc.selectedIndex = 0;
                        var j;
                        for(j = 0; j < item.children.count; j++)
                        {
                            if(item.children.get(j).channel_id == sub_c_id)
                            {
                                subchannelstc.selectedIndex = j;
                                break;
                            }
                        }
                    }
                    page.cname = tumblermodel.get(i).value;
                    className = item.children && item.children.count > 0 ? item.children.get(0).value : "推荐";
                    break;
                }
            }
        }
        // end(11 c)

        function getlist(option){
            loading = true;
            // begin(11 c)
            var opt = { model: view.model, "class": classId, "pageSize": pageSize };
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
            Script.getClass(opt, s, f);
        }
    }


    Row{
        id: channelRow;
        property real theight: 185;
        function toggle()
        {
            if(state === "show")
            {
                state = "hide";
            }
            else if(state === "hide")
            {
                state = "show";
            }
        }
        anchors.top: viewheader.bottom;
        anchors.left: parent.left;
        anchors.right: parent.right;
        width: parent.width;
        height: 185;
        state: "show";
        visible: height >= 80;
        states: [
            State{
                name: "show";
                PropertyChanges {
                    target: channelRow;
                    height: theight;
                }
            }
            ,
            State{
                name: "hide";
                PropertyChanges {
                    target: channelRow;
                    height: 0;
                }
            }
        ]
        transitions: [
            Transition {
                from: "hide";
                to: "show";
                NumberAnimation{
                    target: channelRow;
                    property: "height";
                    easing.type: Easing.OutExpo;
                    duration: 400;
                }
            }
            ,
            Transition {
                from: "show";
                to: "hide";
                NumberAnimation{
                    target: channelRow;
                    property: "height";
                    easing.type: Easing.InExpo;
                    duration: 400;
                }
            }
        ]
        z: 1;
        Rectangle{
            id:tumbler;
            width:vtumbler.width;
            height: parent.height;
            z:1;
            VTumbler {
                id: vtumbler;
                //anchors.fill: parent;
                height: parent.height;
                columns: [channelstc, subchannelstc];
                TumblerColumn {
                    id:channelstc;
                    items:ListModel{id: tumblermodel}
                    label:"频道";
                    selectedIndex: 0;
                    onSelectedIndexChanged: {
                        subchannelstc.items = items.get(selectedIndex).children;
                        subchannelstc.selectedIndex = 0;
                    }
                }

                TumblerColumn {
                    id:subchannelstc;
                    items: null; // channelstc.items.get(channelstc.selectedIndex).children;
                    label:"子频道";
                    selectedIndex: 0;
                }
            }
        }
        ToolIcon{
            width: parent.width - tumbler.width;
            height: width;
            anchors.verticalCenter: parent.verticalCenter;
            platformIconId: "toolbar-search";
            onClicked:{
                internal.setClass();
                internal.getlist();
            }
        }
    }

    ViewHeader {
        id: viewheader;
        title: page.cname + "-" + internal.className;
        ToolButton {
            anchors {
                right: parent.right; verticalCenter: parent.verticalCenter;
            }
            iconSource: "toolbar-menu";
            onClicked: channelRow.toggle();
        }
    }

    ListView {
        id: view;
        anchors { fill: parent; topMargin: viewheader.height + channelRow.height; }
        model: ListModel {}
        delegate: CommonDelegate {}
        footer: FooterItem {
            visible: internal.has_next_page;
            enabled: !loading;
            onClicked: internal.getlist("next");
        }
        clip: true;
    }

    ScrollDecorator { flickableItem: view; }
}
