import QtQuick 1.1
import com.nokia.symbian 1.1
import CustomWebKit 1.0
import "../Component"
import "../../js/main.js" as Script
import "../../js/database.js" as Database

MyPage {
    id: page;

    title: viewHeader.title;

    tools: ToolBarLayout {
        ToolButton {
            iconSource: "toolbar-back";
            onClicked: {
                if(from_where !== "list")
                {
                    pageStack.pop(undefined, true);
                }
                pageStack.pop();
            }
        }
        ToolButton {
            iconSource: "../../gfx/favourite.svg";
            opacity: internal.is_fav ? 1.0 : 0.5;
            onClicked: internal.toggle_favorite();
        }
        ToolButton {
            iconSource: "../../gfx/edit.svg";
            onClicked: internal.createCommentUI();
        }
        ToolButton {
            iconSource: "toolbar-share";
            onClicked: internal.share();
        }
    }

    property string acId;
    property string from_where: "list";
    onAcIdChanged: internal.getDetail();

    QtObject {
        id: internal;

        property variant detail: ({});

        property variant commentUI: null;

        property int pageNumber: 1;
        property int totalNumber: 0;
        property int pageSize: 50;
        property bool is_fav: false;

        function is_favorite()
        {
            if (Script.is_signin()){
                loading = true;
                function s(obj){
                    loading = false;
                    is_fav = obj.vdata !== null ? obj.vdata : false;
                }
                function f(err){ loading = false; signalCenter.showMessage(err); }
                Script.favorite(acId, s, f);
            }
        }

        function unfav(){
            if (Script.checkAuthData()){
                var url = Script.AcApi.FAVORITE.arg(page.acId);
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

        function getComments(option){
            loading = true;
            var opt = { acId: acId, model: commentListView.model , pageSize: pageSize}
            if (commentListView.count === 0) option = "renew";
            option = option || "renew";
            if (option === "renew"){
                opt.renew = true;
                totalNumber = 0;
                pageNumber = 1;
            } else {
                opt.cursor = pageNumber + 1;
            }
            function s(obj){
                loading = false;
                pageNumber = obj.data.page.pageNo;
                totalNumber = obj.data.page.totalCount;
                pageSize = obj.data.page.pageSize;
            }
            function f(err){ loading = false; signalCenter.showMessage(err); }
            Script.getVideoComments(opt, s, f);
        }

        function createQuoteCommentUI(commentId, floor, username, content){
            if (!Script.checkAuthData()) return;
            if (!commentUI){
                commentUI = Qt.createComponent("CommentUI.qml").createObject(page);
                commentUI.accepted.connect(sendComment);
            }
            commentUI.text = "";
            commentUI.quoteId = commentId;
            commentUI.quoteFloor = floor;
            commentUI.quoteUsername = username;
            commentUI.quoteContent = content;
            commentUI.open();
        }
        function createCommentUI(){
            if (!Script.checkAuthData()) return;
            if (!commentUI){
                commentUI = Qt.createComponent("CommentUI.qml").createObject(page);
                commentUI.accepted.connect(sendComment);
            }
            commentUI.text = "";
            commentUI.quoteId = "";
            commentUI.quoteFloor = 0;
            commentUI.quoteUsername = "";
            commentUI.quoteContent = "";
            commentUI.open();
        }

        function sendComment(){
            var text = commentUI.text;
            if (text.length < 5){
                signalCenter.showMessage("回复长度过短。回复字数应不少于5个字符。");
                return;
            }
            loading = true;
            var opt = { acId: acId, content: text }
                        if(commentUI.quoteId.length !== 0)
                        {
                            opt.quoteId = commentUI.quoteId;
                        }
            function s(){ loading = false; signalCenter.showMessage("发送成功"); getComments(); }
            function f(err){ loading = false; signalCenter.showMessage(err); }
            Script.sendComment(opt, s, f);
        }

        function getDetail(){
            loading = true;
            function s(obj){ loading = false; detail = obj.vdata; loadText(); getComments(); is_favorite(); /*log();*/ }
            function f(err){
                loading = false;
                signalCenter.showMessage(err);
                if(from_where !== "list")
                {
                    pageStack.pop(undefined, true);
                }
            }
            Script.get_article_detail(acId, s, f);
        }

        function addToFav(){
            if (Script.checkAuthData()){
                loading = true;
                function s(){ loading = false; is_fav = true; signalCenter.showMessage("收藏文章成功!") }
                function f(err, e){ loading = false; if(e) { if(e.eid === 610001) internal.is_fav = true; } signalCenter.showMessage(err); }
                Script.addToFav(acId, s, f);
            }
        }

        function log(){
            Database.storeHistory(acId, detail.channelId, detail.title, detail.image,
                                  detail.visit.views, detail.owner.name);
        }

        function share(){
            if(detail.shareUrl)
            {
                var url = "http://service.weibo.com/share/share.php";
                url += "?url="+encodeURIComponent(internal.detail.shareUrl);
                url += "&type=3";
                url += "&title="+encodeURIComponent(internal.detail.title||"");
                url += "&pic="+encodeURIComponent(internal.detail.cover||internal.detail.image||"");
                utility.openURLDefault(url);
            }
        }

        function loadText(){
            var model = repeater.model;
            model.clear();
            var partRep = /\[NextPage](.*?)\[\/NextPage]/g
            var text = detail.article.content;
            if (!partRep.test(text)){
                model.append({title: "", text: text});
            } else {
                for (var info = partRep.exec(text), startIndex = 0;
                     info;
                     startIndex = partRep.lastIndex, info = partRep.exec(text)){
                    var prop = {
                        title: info[1],
                        text: text.substring(startIndex, partRep.lastIndex)
                    };
                    model.append(prop);
                }
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
                    if(Script.check_error(Script.AcApi.FAVORITE, obj, function(err){
                                          signalCenter.showMessage(err);
                }))
                    {
                        return;
                    }
                    internal.is_fav = false;
                    signalCenter.showMessage("已取消收藏文章");
                }
                catch(e)
                {
                    signalCenter.showMessage("取消收藏文章出现错误");
                }
            }
        }
        onRequestFailed: {
            if (url.toString() === helperListener.reqUrl){
                loading = false;
                signalCenter.showMessage("取消收藏文章失败");
            }
        }
    }

    ViewHeader {
        id: viewHeader;
        anchors.top: parent.top;
        anchors.left: parent.left;
        anchors.right: parent.right;
        //width: view.width;
        title: internal.detail.title || "";
    }
    ListHeading {
        id: section_header;
        anchors.top: viewHeader.bottom;
        anchors.left: parent.left;
        anchors.right: parent.right;
        ListItemText {
            anchors.fill: parent.paddingItem;
            role: "Heading";
            text: internal.detail.owner ? internal.detail.owner.name : "";
        }
        MouseArea{
            anchors.fill: parent;
            onClicked: {
                if(internal.detail.owner)
                {
                    signalCenter.view_user_detail_by_id(internal.detail.owner["id"]);
                }
            }
        }
    }
    ButtonRow {
        id: tabRow;
        anchors {
            left: parent.left;
            right: parent.right;
            bottom: parent.bottom
        }
        TabButton {
            text: "文章详请";
            tab: web_view;
        }
        TabButton {
            text: "评论";
            tab: commentView;
        }
    }

    TabGroup {
        id: tabGroup;
        anchors {
            left: parent.left; right: parent.right;
            top: section_header.bottom; bottom: tabRow.top;
        }
        currentTab: web_view;
        clip: true;

        Item{
            id: web_view;
            anchors.fill: parent;
            Flickable {
                id: view;
                anchors.fill: parent;
                contentWidth: contentCol.width;
                contentHeight: contentCol.height;
                boundsBehavior: Flickable.StopAtBounds;
                clip: true;
                Column {
                    id: contentCol;
                    Repeater {
                        id: repeater;
                        model: ListModel {}
                        Column {
                            ListHeading {
                                platformInverted: true
                                visible: model.title !== "";
                                ListItemText {
                                    platformInverted: true;
                                    anchors.fill: parent.paddingItem;
                                    role: "Heading";
                                    text: model.title;
                                }
                            }
                            WebView {
                                id: webView;
                                preferredWidth: view.width;
                                preferredHeight: view.height;
                                html: model.text;
                                onLinkClicked: signalCenter.view_link(link);
                                settings {
                                    standardFontFamily: platformStyle.fontFamilyRegular;
                                    defaultFontSize: platformStyle.fontSizeMedium;
                                    defaultFixedFontSize: platformStyle.fontSizeMedium;
                                    minimumFontSize: platformStyle.fontSizeMedium;
                                    minimumLogicalFontSize: platformStyle.fontSizeMedium;
                                    autoLoadImages: acsettings.articleLoadImage;
                                }
                            }
                        }
                    }
                    Text {
                        width: view.width;
                        wrapMode: Text.Wrap;
                        font: constant.labelFont;
                        color: constant.colorMid;
                        text: internal.detail.desc||"";
                    }
                }
            }
            ScrollDecorator { flickableItem: view; }
        }

        Item {
            id: commentView;
            anchors.fill: parent;
            ListView {
                id: commentListView;
                anchors.fill: parent;
                model: ListModel {}
                header: PullToActivate {
                    myView: commentListView;
                    enabled: !loading;
                    onRefresh: internal.getComments();
                }
                delegate: Component{
                    CommentDelegate{
                        onAvatarClicked: {
                            if(userId)
                            {
                                signalCenter.view_user_detail_by_id(userId);
                            }
                        }
                        onContentTextClicked: {
                            if(commentId)
                            {
                                internal.createQuoteCommentUI(commentId, floorindex, userName, content);
                            }
                        }
                    }
                }
                footer: FooterItem {
                    visible: internal.pageSize*internal.pageNumber<internal.totalNumber;
                    enabled: !loading;
                    onClicked: internal.getComments("next");
                }
                ScrollDecorator { flickableItem: parent; }
            }
        }

    }
}
