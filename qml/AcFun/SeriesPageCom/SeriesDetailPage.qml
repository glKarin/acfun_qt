import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"
import "../../js/main.js" as Script

MyPage {
    id: page;

    title: viewHeader.title;

    property string acId;
    onAcIdChanged: internal.getlist();

    tools: ToolBarLayout {
        ToolButton {
            iconSource: "toolbar-back";
            onClicked: pageStack.pop();
        }
        ToolIcon {
            platformIconId: "../../gfx/favourite.svg";
            opacity: internal.is_fav ? 1.0 : 0.5;
            onClicked: internal.toggle_favorite();
        }
        ToolIcon {
            platformIconId: "toolbar-refresh";
            onClicked: internal.getlist();
        }
        ToolIcon {
            platformIconId: "toolbar-add";
            visible: internal.choose_player && (signalCenter.player_loader || false) && (signalCenter.player_loader.item || false) && (signalCenter.player_loader.item.loaded || false) && signalCenter.player_loader.state === signalCenter.player_loader.__MIN;
            onClicked: {
                if(internal.choose_player && signalCenter.player_loader && signalCenter.player_loader.item && signalCenter.player_loader.item.loaded && signalCenter.player_loader.state === signalCenter.player_loader.__MIN)
                {
                    signalCenter.player_loader.item.nor();
                }
                circle_menu.close();
            }
        }
        CheckBox {
            text: "播放时选择";
            checked: internal.choose_player;
            onClicked:
            {
                internal.choose_player = checked;
                if(!internal.choose_player)
                {
                    circle_menu.close();
                }
            }
        }
    }

    QtObject {
        id: internal;

        property string name;
        property string previewurl;
        property string desc;
        property string username;
        property bool is_fav: false;
        property int count: 0;
        property int nextPage: 1;
        property bool hasNext: false;
        property int pageSize: 18; //20;
        property int pageCount: 0;
        property bool choose_player: false;

        function getlist(option){
            if(!option)
            {
                get_bangumi_detail();
                return;
            }
            get_episode(option);
        }

        function get_bangumi_detail()
        {
            loading = true;
            view.model.clear();
            pageCount = 0;
            hasNext = false;
            nextPage = 1;
            count = 0;
            name = "";;
            previewurl = "";;
            desc = "";;
            username = "";;

            var opt = {acId: acId};
            function s(obj){
                loading = false;
                previewurl = obj.vdata.coverImageV;
                name = obj.vdata.title;
                desc = obj.vdata.intro;
                username = obj.vdata.updateContent;
                get_episode();
                is_favorite();
            }
            function f(err){ loading = false; signalCenter.showMessage(err); }
            Script.get_bangumi_detail(opt, s, f);
        }

        function get_episode(option)
        {
            loading = true;
            var opt = { albumId: acId, model: view.model, "pageSize": pageSize }
            if (view.count === 0||nextPage === 1) option = "renew";
            option = option || "renew";
            if (option === "renew"){
                opt.renew = true;
                nextPage = 1;
            } else {
                opt.pageNo = nextPage;
            }
            function s(obj){
                loading = false;
                count = obj.vdata.totalCount;
                pageCount = parseInt(obj.vdata.totalCount / pageSize) + (obj.vdata.totalCount % pageSize ? 1 : 0);
                if (nextPage >= pageCount){
                    hasNext = false;
                } else {
                    hasNext = true;
                    nextPage = obj.vdata.pageNo + 1;
                }
            }
            function f(err){
                loading = false;
                signalCenter.showMessage(err);
            }
            Script.getSeriesEpisodes(opt, s, f);
        }

        function play(sid)
        {
            if(!sid)
            {
                return;
            }
            if(choose_player)
            {
                circle_menu.sid = sid;
                circle_menu.open();
            }
            else
            {
                if(signalCenter.player_loader && signalCenter.player_loader.item)
                {
                    signalCenter.player_loader.item.exit();
                }
                if(signalCenter.streamtype_dialog)
                {
                    signalCenter.streamtype_dialog.close();
                }
                circle_menu.close();
                signalCenter.playVideo(sid, "", sid, sid);
            }
        }

        function open_player_window(vid){
            if(signalCenter.streamtype_dialog)
            {
                signalCenter.streamtype_dialog.close();
            }
            signalCenter.create_player_window(vid, "", vid, vid);
        }

        function open_streamtype_dialog(vid){
            if(signalCenter.player_loader && signalCenter.player_loader.state !== signalCenter.player_loader.__MIN && signalCenter.player_loader.item && signalCenter.player_loader.item.video_player)
            {
                signalCenter.player_loader.item.video_player.pause();
            }
            signalCenter.create_streamtype_dialog(vid, "", vid, vid);
        }

        function addToFav(){
            if (Script.checkAuthData()){
                loading = true;
                function s(){ loading = false; is_fav = true; signalCenter.showMessage("收藏番剧成功!") }
                function f(err, e){ loading = false; if(e) { if(e.eid === 610002) internal.is_fav = true; } signalCenter.showMessage(err); }
                Script.favorite_bangumi(acId, s, f, "add");
            }
        }
        function is_favorite()
        {
            if (Script.is_signin()){
                loading = true;
                function s(obj){
                    loading = false;
                    is_fav = obj.vdata !== null ? obj.vdata : false;
                }
                function f(err){ loading = false; signalCenter.showMessage(err); }
                Script.favorite_bangumi(acId, s, f);
            }
        }

        function unfav(){
            if (Script.checkAuthData()){
                var url = Script.AcApi.FAVORITE_BANGUMI.arg(page.acId);
                url += "?access_token="+acsettings.accessToken;
                helperListener.reqUrl = url;
                networkHelper.createDeleteRequest(url);
                loading = true;
            }
        }

        function toggle_favorite()
        {
            if(is_fav)
            {
                unfav();
            }
            else
            {
                addToFav();
            }
        }
    }

    Connections {
        id: helperListener;
        property string reqUrl;
        target: networkHelper;
        onRequestFinished: {
            if (url.toString() === helperListener.reqUrl){
                loading = false;
                try
                {
                    var obj = JSON.parse(message);
                    if(Script.check_error(Script.AcApi.FAVORITE_BANGUMI, obj, function(err){
                                          signalCenter.showMessage(err);
                }))
                    {
                        return;
                    }
                    internal.is_fav = false;
                    signalCenter.showMessage("已取消收藏番剧");
                }
                catch(e)
                {
                    signalCenter.showMessage("取消收藏番剧出现错误");
                }
            }
        }
        onRequestFailed: {
            if (url.toString() === helperListener.reqUrl){
                loading = false;
                signalCenter.showMessage("取消收藏番剧失败");
            }
        }
    }

    ViewHeader {
        id: viewHeader;
        title: "剧集详细";
    }

    GridView {
        id: view;
        anchors { fill: parent; topMargin: viewHeader.height; }
        model: ListModel {}
        cellWidth: app.inPortrait ? width / 3 : width / 5;
        cellHeight: cellWidth + constant.graphicSizeSmall;
        header: episodeHeaderComp;
        delegate: episodeDelegateComp;
        footer: FooterItem {
            listView: view;
            visible: internal.hasNext;
            enabled: !loading;
            onClicked: internal.getlist("next");
        }
    }

    Component {
        id: episodeHeaderComp;
        Column {
            id: headerCol;
            width: GridView.view.width;
            Image {
                anchors { left: parent.left; right: parent.right; }
                height: 150;
                source: internal.previewurl;
                fillMode: Image.PreserveAspectCrop;
                smooth: true;
                clip: true;
                Rectangle {
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom; }
                    height: constant.graphicSizeSmall;
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#00000000" }
                        GradientStop { position: 1.0; color: "#A0000000" }
                    }
                    Text {
                        anchors { fill: parent; margins: constant.paddingLarge; }
                        horizontalAlignment: Text.AlignLeft;
                        verticalAlignment: Text.AlignVCenter;
                        elide: Text.ElideRight;
                        text: internal.name;
                        font: constant.titleFont;
                        color: constant.colorLight;
                    }
                }
            }
            Row {
                anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium; }
                height: constant.graphicSizeSmall;
                spacing: constant.paddingMedium;
                Image {
                    anchors.verticalCenter: parent.verticalCenter;
                    sourceSize: Qt.size(constant.graphicSizeTiny,
                                        constant.graphicSizeTiny);
                    source: "../../gfx/image_upman_small.png";
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter;
                    font: constant.subTitleFont;
                    color: constant.colorMid;
                    text: internal.username;
                }
            }
            Text {
                anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium; }
                wrapMode: Text.Wrap;
                font: constant.subTitleFont;
                color: constant.colorMid;
                text: internal.desc;
            }
            ListHeading {
                ListItemText {
                    anchors.fill: parent.paddingItem;
                    role: "Heading";
                    text: "剧集列表";
                }
            }
        }
    }

    Component {
        id: episodeDelegateComp;
        Item {
            id: episodeDelegate;
            implicitWidth: GridView.view.cellWidth;
            implicitHeight: GridView.view.cellHeight;
            Image {
                id: preview;
                anchors {
                    left: parent.left; top: parent.top;
                    right: parent.right; margins: constant.paddingSmall;
                }
                clip: true;
                height: width;
                sourceSize.width: width;
                fillMode: Image.PreserveAspectCrop;
                source: model.previewurl || Qt.resolvedUrl("../../gfx/bangumi_episode_img.png");
            }
            Text {
                anchors {
                    left: parent.left; right: parent.right;
                    top: preview.bottom; bottom: parent.bottom;
                }
                horizontalAlignment: Text.AlignHCenter;
                verticalAlignment: Text.AlignVCenter;
                text: model.subhead;
                font: constant.subTitleFont;
                color: constant.colorLight;
                width: parent.width;
                elide: Text.ElideMiddle;
            }
            Rectangle {
                anchors.fill: parent;
                color: "black";
                opacity: mouseArea.pressed ? 0.3 : 0;
            }
            MouseArea {
                id: mouseArea;
                anchors.fill: parent;
                onClicked: internal.play(model.videoId);
            }
        }
    }

    CircleMenu{
        id: circle_menu;
        property string sid: "";

        radius: 240;
        center_radius: 120;
        animation_duration: 200;
        x: parent.width - width - constant.paddingMedium;
        y: parent.height - height - constant.paddingMedium;
        z: 21;
        tools: CircleMenuLayout{
            auto_scale_items: true;
            out_circle_radius: circle_menu.radius;
            in_circle_radius: circle_menu.center_radius;
            ToolIcon {
                platformIconId: "toolbar-settings";
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("../SettingPage.qml"));
                    circle_menu.close();
                }
            }
            ToolIcon {
                platformIconId: "toolbar-mediacontrol-play";
                onClicked: {
                    if(circle_menu.sid.length !== 0)
                    {
                        internal.open_player_window(circle_menu.sid);
                    }
                    circle_menu.close();
                }
            }
            ToolIcon {
                platformIconId: "toolbar-mediacontrol-play";
                opacity: 0.5;
                onClicked: {
                    if(circle_menu.sid.length !== 0)
                    {
                        internal.open_streamtype_dialog(circle_menu.sid);
                    }
                    circle_menu.close();
                }
            }
        }
    }

    onStatusChanged: {
        if(status !== PageStatus.Active && circle_menu.opened)
        {
            circle_menu.close();
        }
    }

    Component.onDestruction: {
        signalCenter.destory_streamtype_dialog();
        signalCenter.destory_player_window();
    }
}
