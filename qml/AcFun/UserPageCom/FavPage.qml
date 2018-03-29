import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"
import "../../js/main.js" as Script

MyPage {
    id: page;
    title: "我的收藏";

    tools: ToolBarLayout {
        ToolButton {
            iconSource: "toolbar-back";
            onClicked: pageStack.pop();
        }
        ToolButton {
            iconSource: "toolbar-refresh";
            onClicked: internal.getlist();
        }
        ToolButton {
            iconSource: internal.deleteMode ? "../../gfx/ok.svg"
                                            : "toolbar-delete";
            onClicked: internal.deleteMode = !internal.deleteMode;
        }
    }

    QtObject {
        id: internal;

        property bool deleteMode: false;

        function getlist(type, option)
        {
            internal.deleteMode = false;
            if(!type)
            {
                video_view.hasNext = false;
                bangumi_view.hasNext = false;
                article_view.hasNext = false;
                album_view.hasNext = false;
                video_view.nextPage = 1;
                bangumi_view.nextPage = 1;
                article_view.nextPage = 1;
                album_view.nextPage = 1;

                tabGroup.currentTab = video_view;
                tabRow.checkedButton = video_btn;
                option = undefined;
            }

            if(!type || type === "video")
            {
                get_fav_video(option);
            }
            if(!type || type === "article")
            {
                get_fav_article(option);
            }
            if(!type || type === "album")
            {
                get_fav_album(option);
            }
            if(!type || type === "bangumi")
            {
                get_fav_bangumi(option);
            }
        }

        function get_fav_video(option){
            if(Script.checkAuthData())
            {
                loading = true;
                var opt = { type: 0, model: video_view.model, "pageSize": video_view.pageSize }
                if (video_view.nextPage === 1) option = "renew";
                option = option || "renew";
                if (option === "renew"){
                    opt.renew = true;
                    video_view.nextPage = 1;
                } else {
                    opt.pageNo = video_view.nextPage;
                }
                function s(obj){
                    loading = false;
                    if (obj.vdata.totalCount <= 0){
                        video_view.hasNext = false;
                        signalCenter.showMessage("已经没有更多了");
                    } else {
                        video_view.hasNext = true;
                        video_view.nextPage = obj.vdata.pageNo + 1;
                    }
                }
                function f(err){
                    loading = false;
                    signalCenter.showMessage(err);
                }
                Script.getFavVideos(opt, s, f);
            }
        }

        function get_fav_bangumi(option)
        {
            if(Script.checkAuthData())
            {
                loading = true;
                var opt = { model: bangumi_view.model, "pageSize": bangumi_view.pageSize }
                if (bangumi_view.nextPage === 1) option = "renew";
                option = option || "renew";
                if (option === "renew"){
                    opt.renew = true;
                    bangumi_view.nextPage = 1;
                } else {
                    opt.pageNo = bangumi_view.nextPage;
                }
                function s(obj){
                    loading = false;
                    if (obj.vdata.totalCount <= 0){
                        bangumi_view.hasNext = false;
                        signalCenter.showMessage("已经没有更多了");
                    } else {
                        bangumi_view.hasNext = true;
                        bangumi_view.nextPage = obj.vdata.pageNo + 1;
                    }
                }
                function f(err){
                    loading = false;
                    signalCenter.showMessage(err);
                }
                Script.get_fav_bangumi(opt, s, f);
            }
        }

        function get_fav_article(option)
        {
            if(Script.checkAuthData())
            {
                loading = true;
                var opt = { type: 1, model: article_view.model, "pageSize": article_view.pageSize }
                if (article_view.nextPage === 1) option = "renew";
                option = option || "renew";
                if (option === "renew"){
                    opt.renew = true;
                    article_view.nextPage = 1;
                } else {
                    opt.pageNo = article_view.nextPage;
                }
                function s(obj){
                    loading = false;
                    if (obj.vdata.totalCount <= 0){
                        article_view.hasNext = false;
                        signalCenter.showMessage("已经没有更多了");
                    } else {
                        article_view.hasNext = true;
                        article_view.nextPage = obj.vdata.pageNo + 1;
                    }
                }
                function f(err){
                    loading = false;
                    signalCenter.showMessage(err);
                }
                Script.getFavVideos(opt, s, f);
            }
        }

        function get_fav_album(option)
        {
            if(Script.checkAuthData())
            {
                loading = true;
                var opt = { model: album_view.model, "pageSize": album_view.pageSize }
                if (album_view.nextPage === 1) option = "renew";
                option = option || "renew";
                if (option === "renew"){
                    opt.renew = true;
                    album_view.nextPage = 1;
                } else {
                    opt.pageNo = album_view.nextPage;
                }
                function s(obj){
                    loading = false;
                    if (obj.vdata.totalCount <= 0){
                        album_view.hasNext = false;
                        signalCenter.showMessage("已经没有更多了");
                    } else {
                        album_view.hasNext = true;
                        album_view.nextPage = obj.vdata.pageNo + 1;
                    }
                }
                function f(err){
                    loading = false;
                    signalCenter.showMessage(err);
                }
                Script.get_fav_album(opt, s, f);
            }
        }

        function unfav(type, idx, acId){
            if (Script.checkAuthData()){
                var url;
                if(type === "video")
                {
                    url = Script.AcApi.FAVORITE.arg(acId.toString());
                }
                else if(type === "article")
                {
                    url = Script.AcApi.FAVORITE.arg(acId.toString());
                }
                else if(type === "album")
                {
                    url = Script.AcApi.FAVORITE_ALBUM.arg(acId.toString());
                }
                else if(type === "bangumi")
                {
                    url = Script.AcApi.FAVORITE_BANGUMI.arg(acId.toString());
                }
                else
                {
                    return;
                }
                url += "?access_token="+acsettings.accessToken;
                helperListener.index = idx;
                helperListener.type = type;
                helperListener.reqUrl = url;
                networkHelper.createDeleteRequest(url);
                loading = true;
            }
        }
    }

    Connections {
        id: helperListener;
        property string type;
        property string reqUrl;
        property int index;
        target: networkHelper;
        onRequestFinished: {
            if (url.toString() === helperListener.reqUrl){
                loading = false;
                try
                {
                    var obj = JSON.parse(message);
                    var u;
                    var m;
                    if(helperListener.type === "video")
                    {
                        u = Script.AcApi.FAVORITE;
                        m = video_view.model;
                    }
                    else if(helperListener.type === "article")
                    {
                        u = Script.AcApi.FAVORITE;
                        m = article_view.model;
                    }
                    else if(helperListener.type === "album")
                    {
                        u = Script.AcApi.FAVORITE_ALBUM;
                        m = album_view.model;
                    }
                    else if(helperListener.type === "bangumi")
                    {
                        u = Script.AcApi.FAVORITE_BANGUMI;
                        m = bangumi_view.model;
                    }
                    else
                    {
                        return;
                    }
                    if(Script.check_error(u, obj, function(err){
                                          signalCenter.showMessage(err);
                }))
                    {
                        return;
                    }
                    m.remove(helperListener.index);
                }
                catch(e)
                {
                    var n;
                    if(helperListener.type === "video")
                    {
                        n = "视频";
                    }
                    else if(helperListener.type === "article")
                    {
                        n = "文章";
                    }
                    else if(helperListener.type === "album")
                    {
                        n = "合辑";
                    }
                    else if(helperListener.type === "bangumi")
                    {
                        n = "番剧";
                    }
                    else
                    {
                        n = "";
                    }
                    signalCenter.showMessage("取消收藏%1出现错误".arg(n));
                }
            }
        }
        onRequestFailed: {
            if (url.toString() === helperListener.reqUrl){
                loading = false;
                var n;
                if(helperListener.type === "video")
                {
                    n = "视频";
                }
                else if(helperListener.type === "article")
                {
                    n = "文章";
                }
                else if(helperListener.type === "album")
                {
                    n = "合辑";
                }
                else if(helperListener.type === "bangumi")
                {
                    n = "番剧";
                }
                else
                {
                    n = "";
                }
                signalCenter.showMessage("取消收藏%1失败".arg(n));
            }
        }
    }

    ViewHeader {
        id: viewHeader;
        title: page.title;
    }

    ButtonRow {
        id: tabRow;
        anchors {
            left: parent.left; top: viewHeader.bottom; right: parent.right;
        }
        TabButton {
            id: video_btn;
            text: "视频";
            tab: video_view;
        }
        TabButton {
            text: "文章";
            tab: article_view;
        }
        TabButton {
            text: "合辑";
            tab: album_view;
        }
        TabButton {
            text: "番剧";
            tab: bangumi_view;
        }
    }


    TabGroup {
        id: tabGroup;
        anchors {
            left: parent.left; right: parent.right;
            top: tabRow.bottom; bottom: parent.bottom;
        }
        currentTab: video_view;
        onCurrentTabChanged: {
            internal.deleteMode = false;
        }
        clip: true;

        Item{
            id: video_view;
            property int nextPage: 1;
            property int pageSize: 20;
            property bool hasNext: false;
            property variant model: ListModel{}

            anchors.fill: parent;

            Text {
                anchors.centerIn: parent;
                elide: Text.ElideRight;
                font: constant.titleFont;
                color: constant.colorLight;
                text: "<b>未收藏视频</b>";
                visible: !loading && parent.model.count === 0;
                z: 2;
                clip: true;
            }

            ListView {
                id: video_list;
                anchors.fill: parent;
                clip: true;
                model: parent.model;
                visible: parent.model.count > 0;
                delegate: CommonDelegate {
                    Button {
                        anchors {
                            right: parent.right;
                            verticalCenter: parent.verticalCenter;
                        }
                        enabled: !loading;
                        width: height;
                        iconSource: privateStyle.toolBarIconPath("toolbar-delete");
                        visible: tabGroup.currentTab === video_view && internal.deleteMode;
                        onClicked: internal.unfav("video", index, model.acId);
                    }
                }
                footer: FooterItem {
                    visible: video_view.hasNext;
                    enabled: !loading;
                    onClicked: internal.getlist("video", "next");
                }
                header: PullToActivate {
                    myView: video_list;
                    enabled: !loading;
                    onRefresh: internal.getlist("video");
                }
                ScrollDecorator { flickableItem: parent; }
            }
        }

        Item{
            id: article_view;
            property int nextPage: 1;
            property int pageSize: 20;
            property bool hasNext: false;
            property variant model: ListModel{}

            anchors.fill: parent;

            Text {
                anchors.centerIn: parent;
                elide: Text.ElideRight;
                font: constant.titleFont;
                color: constant.colorLight;
                text: "<b>未收藏文章</b>";
                visible: !loading && parent.model.count === 0;
                z: 2;
                clip: true;
            }

            ListView {
                id: article_list;
                anchors.fill: parent;
                clip: true;
                model: parent.model;
                visible: parent.model.count > 0;
                delegate: CommonDelegate {
                    Button {
                        anchors {
                            right: parent.right;
                            verticalCenter: parent.verticalCenter;
                        }
                        enabled: !loading;
                        width: height;
                        iconSource: privateStyle.toolBarIconPath("toolbar-delete");
                        visible: tabGroup.currentTab === article_view && internal.deleteMode;
                        onClicked: internal.unfav("article", index, model.acId);
                    }
                }
                footer: FooterItem {
                    visible: article_view.hasNext;
                    enabled: !loading;
                    onClicked: internal.getlist("article", "next");
                }
                header: PullToActivate {
                    myView: article_list;
                    enabled: !loading;
                    onRefresh: internal.getlist("article");
                }
                ScrollDecorator { flickableItem: parent; }
            }
        }

        Item{
            id: album_view;
            property int nextPage: 1;
            property int pageSize: 20;
            property bool hasNext: false;
            property variant model: ListModel{}

            anchors.fill: parent;

            Text {
                anchors.centerIn: parent;
                elide: Text.ElideRight;
                font: constant.titleFont;
                color: constant.colorLight;
                text: "<b>未收藏合辑</b>";
                visible: !loading && parent.model.count === 0;
                z: 2;
                clip: true;
            }

            ListView {
                id: album_list;
                anchors.fill: parent;
                clip: true;
                model: parent.model;
                visible: parent.model.count > 0;
                delegate: AlbumDelegate {
                    Button {
                        anchors {
                            right: parent.right;
                            verticalCenter: parent.verticalCenter;
                        }
                        enabled: !loading;
                        width: height;
                        iconSource: privateStyle.toolBarIconPath("toolbar-delete");
                        visible: tabGroup.currentTab === album_view && internal.deleteMode;
                        onClicked: internal.unfav("album", index, albumId);
                    }
                }
                footer: FooterItem {
                    visible: album_view.hasNext;
                    enabled: !loading;
                    onClicked: internal.getlist("album", "next");
                }
                header: PullToActivate {
                    myView: album_list;
                    enabled: !loading;
                    onRefresh: internal.getlist("album");
                }
                ScrollDecorator { flickableItem: parent; }
            }
        }

        Item{
            id: bangumi_view;
            property int nextPage: 1;
            property int pageSize: 20;
            property bool hasNext: false;
            property variant model: ListModel{}

            anchors.fill: parent;

            Text {
                anchors.centerIn: parent;
                elide: Text.ElideRight;
                font: constant.titleFont;
                color: constant.colorLight;
                text: "<b>未收藏番剧</b>";
                visible: !loading && parent.model.count === 0;
                z: 2;
                clip: true;
            }

            ListView {
                id: bangumi_list;
                anchors.fill: parent;
                clip: true;
                visible: parent.model.count > 0;
                model: parent.model;
                delegate: BangumiDelegate {
                    Button {
                        anchors {
                            right: parent.right;
                            verticalCenter: parent.verticalCenter;
                        }
                        enabled: !loading;
                        width: height;
                        iconSource: privateStyle.toolBarIconPath("toolbar-delete");
                        visible: tabGroup.currentTab === bangumi_view && internal.deleteMode;
                        onClicked: internal.unfav("bangumi", index, model.id);
                    }
                }
                footer: FooterItem {
                    visible: bangumi_view.hasNext;
                    enabled: !loading;
                    onClicked: internal.getlist("bangumi", "next");
                }
                header: PullToActivate {
                    myView: bangumi_list;
                    enabled: !loading;
                    onRefresh: internal.getlist("bangumi");
                }
                ScrollDecorator { flickableItem: parent; }
            }
        }

    }

    Connections{
        target: Qt.application;
        onActiveChanged: {
            if(!Qt.application.active)
            {
                internal.deleteMode = false;
            }
        }
    }

    onStatusChanged: {
        if(status !== PageStatus.Active)
        {
            internal.deleteMode = false;
        }
    }

    Component.onCompleted: internal.getlist();
}
