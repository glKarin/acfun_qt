import QtQuick 1.1
import com.nokia.meego 1.1
import "Component"
import "../js/main.js" as Script
import "../js/database.js" as Database

MyPage {
    id: page;

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back";
            onClicked: pageStack.pop();
        }
        ToolIcon {
					// begin(11 c)
					platformIconId: internal.is_fav ? "toolbar-favorite-mark" : "toolbar-favorite-unmark";
            onClicked: internal.toggle_favorite();
						// end(11 c)
        }
        ToolIcon {
            platformIconId: "toolbar-edit";
            onClicked: internal.createCommentUI();
        }
        ToolIcon {
            platformIconId: "toolbar-share";
            onClicked: internal.share();
        }
				// end(11 a)
				ToolIcon {
					platformIconId: "toolbar-view-menu";
					onClicked: circle_menu.toggle();
				}
				// end(11 a)
    }

    property string acId;
    onAcIdChanged: internal.getDetail();

    QtObject {
        id: internal;

        property variant detail: ({});

        property int pageNumber: 1;
        property int totalNumber: 0;
        property int pageSize: 50;
				// begin(11 a)
				property bool is_fav: false;
				// end(11 a)

        property Text textHelper: Text {
            font: constant.subTitleFont;
            text: " ";
            visible: false;
        }

        property variant commentUI: null;

        function createCommentUI(){
            if (!Script.checkAuthData()) return;
            if (!commentUI){
                commentUI = Qt.createComponent("VideoDetailCom/CommentUI.qml").createObject(page);
                commentUI.accepted.connect(sendComment);
            }
            commentUI.text = "";
						// begin(11 a)
						commentUI.quoteId = "";
						commentUI.quoteFloor = 0;
						commentUI.quoteUsername = "";
						commentUI.quoteContent = "";
						// end(11 a)
            commentUI.open();
        }

						// begin(11 a)
        function createQuoteCommentUI(commentId, floor, username, content){
            if (!Script.checkAuthData()) return;
            if (!commentUI){
                commentUI = Qt.createComponent("VideoDetailCom/CommentUI.qml").createObject(page);
                commentUI.accepted.connect(sendComment);
            }
            commentUI.text = "";
						commentUI.quoteId = commentId;
						commentUI.quoteFloor = floor;
						commentUI.quoteUsername = username;
						commentUI.quoteContent = content;
            commentUI.open();
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

				function open_player_window(aid, type, sid, cid){
					if(signalCenter.streamtype_dialog)
					{
						signalCenter.streamtype_dialog.close();
					}
					signalCenter.create_player_window(aid, type, sid, cid);
					internal.log();
				}

				function open_streamtype_dialog(aid, type, sid, cid){
					if(signalCenter.player_loader && signalCenter.player_loader.state !== signalCenter.player_loader.__MIN && signalCenter.player_loader.item && signalCenter.player_loader.item.video_player)
					{
						signalCenter.player_loader.item.video_player.pause();
					}
					signalCenter.create_streamtype_dialog(aid, type, sid, cid);
					internal.log();
				}
						// end(11 a)

        function sendComment(){
            var text = commentUI.text;
            if (text.length < 5){
                signalCenter.showMessage("回复长度过短。回复字数应不少于5个字符。");
                return;
            }
            loading = true;
						// begin(11 c)
            var opt = { acId: acId, content: text }
						if(commentUI.quoteId.length !== 0)
						{
							opt.quoteId = commentUI.quoteId;
						}
						// end(11 c)
            function s(){ loading = false; signalCenter.showMessage("发送成功"); getComments(); }
            function f(err){ loading = false; signalCenter.showMessage(err); }
            Script.sendComment(opt, s, f);
        }

        function getDetail(){
            titleBanner.error = false;
            titleBanner.loading = true;
            function s(obj){
                titleBanner.loading = false;
								// begin(11 c)
                detail = obj.vdata;
                if (obj.isArticle && isArticle(obj.channelId)){
                    pageStack.push(Qt.resolvedUrl("VideoDetailCom/ArticlePage.qml"),
                                   {acId: acId, from_where: "video"},
                                   true);
                } else {
                    getComments();
										is_favorite();
									}
									// end(11 c)
            }
            function f(err){
                titleBanner.loading = false;
                titleBanner.error = true;
                if (err === 403){
                    pageStack.push(Qt.resolvedUrl("VideoDetailCom/OldDetailPage.qml"),
                                   {acId: acId},
                                   true);
																	 // begin(11 a)
																 } else if (err === 110001){
                    pageStack.push(Qt.resolvedUrl("VideoDetailCom/ArticlePage.qml"),
                                   {acId: acId, from_where: "video"},
                                   true);
																	 // end(11 a)
                } else {
                    signalCenter.showMessage(err);
                }
            }
            Script.getVideoDetail(acId, s, f);
        }

        function getComments(option){
            loading = true;
						// begin(11 c)
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
						// end(11 c)
            function f(err){ loading = false; signalCenter.showMessage(err); }
            Script.getVideoComments(opt, s, f);
        }
        function addToFav(){
            if (Script.checkAuthData()){
                loading = true;
								// begin(11 c)
                function s(){ loading = false; is_fav = true; signalCenter.showMessage("收藏视频成功!") }
                function f(err, e){ loading = false; if(e) { if(e.eid === 610001) internal.is_fav = true; } signalCenter.showMessage(err); }
								// end(11 c)
                Script.addToFav(acId, s, f);
            }
        }
				function log(){
					// begin(11 c)
            Database.storeHistory(acId, detail.channelId, detail.title, detail.cover,
                                  detail.visit.views, detail.owner.name);
					// end(11 c)
        }
        function share(){
					// begin(11 c)
					if(detail.shareUrl)
					{
						var link = internal.detail.shareUrl;
						var title = internal.detail.title||"";
						utility.share(title, link);
					}
					// end(11 c)
				}

				// begin(11 c)
				function find_children(id, o)
				{
					if(!o || !Array.isArray(o) || o.length === 0)
					{
						return false;
					}

					var i;
					for (i = 0; i < o.length; i++)
					{
						var c = o[i];
						if (c.id === id || id == c.pid)
						{
							return true;
						}
						else
						{
							if(find_children(id, c.children))
							{
								return true;
							}
						}
					}
					return false;
				}
        function isArticle(id){
            var list = signalCenter.videocategories["article"];
						if(find_children(id, list))
						{
							return true;
						}
            return false;
        }
				// end(11 c)
    }

		// begin(11 a)
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
								signalCenter.showMessage("已取消收藏视频");
							}
							catch(e)
							{
								signalCenter.showMessage("取消收藏视频出现错误");
							}
            }
        }
        onRequestFailed: {
            if (url.toString() === helperListener.reqUrl){
                loading = false;
								signalCenter.showMessage("取消收藏视频失败");
            }
        }
    }
		// end(11 a)

    ViewHeader {
        id: viewHeader;
        title: "视频详细";
    }

    Item {
        id: titleBanner;

        property bool loading: false;
        property bool error: false;

        anchors { left: parent.left; right: parent.right; top: viewHeader.bottom; }
        height: 180 + constant.paddingMedium*2;

        z: 10;

        // Background

        // Preview
						// begin(11 c)
        AnimatedImage {
            id: preview;
            anchors {
                left: parent.left; top: parent.top;
                margins: constant.paddingMedium;
            }
            width: 240;
            height: 180;
						playing: Qt.application.active && page.status === PageStatus.Active && !(signalCenter.player_loader && signalCenter.player_loader.state !== signalCenter.player_loader.__MIN && signalCenter.player_loader.item && signalCenter.player_loader.item.video_player && signalCenter.player_loader.item.video_player.videoPlayer && signalCenter.player_loader.item.video_player.videoPlayer.isPlaying);
            //sourceSize: Qt.size(240, 180);
            smooth: true;
            source: internal.detail.cover||internal.detail.image||"";
						// end(11 c)
        }
        Image {
            anchors.centerIn: preview;
            source: visible ? "image://theme/icon-m-toolbar-gallery" : "";
            visible: preview.status != Image.Ready;
        }
        Button {
            platformStyle: ButtonStyle {
                buttonWidth: buttonHeight;
                inverted: true;
            }
            anchors.centerIn: preview;
            iconSource: "image://theme/icon-m-toolbar-mediacontrol-play-white";
        }
        Rectangle {
            color: "black";
            anchors.fill: preview;
            opacity: previewMouseArea.pressed ? 0.3 : 0;
        }
        MouseArea {
            id: previewMouseArea;
            anchors.fill: preview;
						// begin(11 c)
            enabled: (internal.detail.hasOwnProperty("videoCount") && internal.detail.videoCount > 0) || (internal.detail.hasOwnProperty("videos") && internal.detail.videos.length > 0);
										 // end(11 c)
            onClicked: {
                internal.log();
						// begin(11 c)
						if(signalCenter.player_loader && signalCenter.player_loader.item)
						{
							signalCenter.player_loader.item.exit();
						}
						if(signalCenter.streamtype_dialog)
						{
							signalCenter.streamtype_dialog.close();
						}
                var e = internal.detail.videos[0];
                signalCenter.playVideo(
                            page.acId,
                            e.sourceType,
                            e.sourceId,
                            e.commentId||e.videoId || e.danmakuId
                            );
										 // end(11 c)
            }
        }

        // Infomation
        Text {
            anchors {
                left: preview.right; leftMargin: constant.paddingLarge;
                right: parent.right; rightMargin: constant.paddingMedium;
                top: preview.top;
            }
            font: constant.labelFont;
            color: constant.colorLight;
            wrapMode: Text.Wrap;
            elide: Text.ElideRight;
            maximumLineCount: 2;
						// begin(11 c)
            text: internal.detail.title||"";
						// end(11 c)
        }

        Row {
					// begin(11 c)
					id: info_row;
					// end(11 c)
            visible: !titleBanner.error;
            anchors {
                left: preview.right; leftMargin: constant.paddingLarge;
                bottom: parent.bottom; bottomMargin: constant.paddingSmall;
            }
            spacing: constant.paddingMedium;
            Column {
                Repeater {
                    model: [
                        "../gfx/image_upman_small.png",
                        "../gfx/image_watches_small.png",
                        "../gfx/image_comments_small.png"
                    ]
                    Item {
                        width: internal.textHelper.height;
                        height: width;
                        Image {
                            anchors.centerIn: parent;
                            source: modelData;
                        }
                    }
                }
            }
            Column {
                Repeater {
                    model: [
											// begin(11 c)
                        internal.detail.owner ? internal.detail.owner.name : " ",
                        internal.detail.visit ? internal.detail.visit.views : "0",
                        internal.detail.visit ? internal.detail.visit.comments : "0"
												// end(11 c)
                    ]
                    Text {
                        font: constant.subTitleFont;
                        color: constant.colorMid;
                        text: modelData;
                    }
                }
            }
        }
				MouseArea{
					anchors.fill: info_row;
					onClicked: {
						if(internal.detail.owner)
						{
							signalCenter.view_user_detail_by_id(internal.detail.owner["id"]);
						}
					}
				}
        // Loading indicator
        Rectangle {
            anchors.fill: parent;
            color: "black";
            opacity: titleBanner.loading ? 0.3 : 0;
        }
        BusyIndicator {
            anchors.centerIn: parent;
            running: true;
            visible: titleBanner.loading;
            platformStyle: BusyIndicatorStyle {
                size: "large";
            }
        }
        Button {
            anchors.centerIn: parent;
            platformStyle: ButtonStyle {
                buttonWidth: buttonHeight;
            }
            iconSource: "image://theme/icon-m-toolbar-refresh";
            onClicked: internal.getDetail();
            visible: titleBanner.error;
        }
    }

    ButtonRow {
        id: tabRow;
        anchors {
            left: parent.left; top: titleBanner.bottom; right: parent.right;
        }
        TabButton {
            text: "评论";
            tab: commentView;
        }
        TabButton {
            text: "视频详请";
            tab: detailView;
        }
        TabButton {
            text: "视频段落";
            tab: episodeView;
        }
    }

    TabGroup {
        id: tabGroup;
        anchors {
            left: parent.left; right: parent.right;
            top: tabRow.bottom; bottom: parent.bottom;
        }
        currentTab: commentView;
        clip: true;
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
								// begin(11 c)
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
								// end(11 c)
                footer: FooterItem {
                    visible: internal.pageSize*internal.pageNumber<internal.totalNumber;
                    enabled: !loading;
                    onClicked: internal.getComments("next");
                }
            }
						ScrollDecorator { flickableItem: commentListView; }
        }
        Item {
            id: detailView;
            anchors.fill: parent;
            Text {
                anchors {
                    left: parent.left; right: parent.right;
                    top: parent.top; margins: constant.paddingMedium;
                }
                wrapMode: Text.Wrap;
                textFormat: Text.RichText;
                font: constant.labelFont;
                color: constant.colorLight;
                text: internal.detail.description||"";
            }
        }
        Item {
            id: episodeView;
            anchors.fill: parent;
            ListView {
                anchors.fill: parent;
								// begin(11 c)
                model: internal.detail.videos||[];
								clip: true;
                delegate: AbstractItem {
                    Text {
                        anchors.left: parent.paddingItem.left;
                        anchors.verticalCenter: parent.verticalCenter;
                        font: constant.labelFont;
                        color: constant.colorLight;
                        text: modelData.title||"视频片段"+(index+1);
                    }
                    onClicked: {
											// begin(11 a)
											if(signalCenter.player_loader && signalCenter.player_loader.item)
											{
												signalCenter.player_loader.item.exit();
											}
											if(signalCenter.streamtype_dialog)
											{
												signalCenter.streamtype_dialog.close();
											}
											// end(11 a)
                        internal.log();
                        signalCenter.playVideo(
                                    page.acId,
                                    modelData.sourceType,
                                    modelData.sourceId,
                                    modelData.commentId||modelData.videoId || modelData.danmakuId
                                    );
                    }
										// begin(11 a)
										Row{
											anchors.right: parent.right;
											anchors.top: parent.top;
											anchors.bottom: parent.bottom;
											spacing: constant.paddingLarge;
											z: 1;
											ToolIcon {
												anchors.verticalCenter: parent.verticalCenter;
												platformIconId: "toolbar-mediacontrol-play";
												onClicked: {
													internal.open_player_window(page.acId, modelData.sourceType, modelData.sourceId, modelData.commentId||modelData.videoId || modelData.danmakuId);
												}
											}
											ToolIcon {
												anchors.verticalCenter: parent.verticalCenter;
												platformIconId: "toolbar-mediacontrol-play-white";
												onClicked: {
													internal.open_streamtype_dialog(page.acId, modelData.sourceType, modelData.sourceId, modelData.commentId||modelData.videoId || modelData.danmakuId);
												}
											}
										}
										// end(11 a)
                }
								ScrollDecorator { flickableItem: parent; }
								// end(11 c)
            }
        }
    }

		// begin(11 a)

		CircleMenu{
			id: circle_menu;
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
						pageStack.push(Qt.resolvedUrl("SettingPage.qml"));
						circle_menu.close();
					}
				}
				ToolIcon {
					platformIconId: "toolbar-mediacontrol-play";
					onClicked: {
						var e = internal.detail.videos[0];
						internal.open_player_window(page.acId, e.sourceType, e.sourceId, e.commentId || e.videoId || e.danmakuId);
						circle_menu.close();
					}
				}
				ToolIcon {
					platformIconId: "toolbar-mediacontrol-play-white";
					onClicked: {
						var e = internal.detail.videos[0];
						internal.open_streamtype_dialog(page.acId, e.sourceType, e.sourceId, e.commentId || e.videoId || e.danmakuId);
						circle_menu.close();
					}
				}
				ToolIcon {
					platformIconId: "toolbar-up";
					visible: (signalCenter.player_loader || false) && (signalCenter.player_loader.item || false) && (signalCenter.player_loader.item.loaded || false) && signalCenter.player_loader.state === signalCenter.player_loader.__MIN;
					onClicked: {
						if(signalCenter.player_loader && signalCenter.player_loader.item && signalCenter.player_loader.item.loaded && signalCenter.player_loader.state === signalCenter.player_loader.__MIN)
						{
							signalCenter.player_loader.item.nor();
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
		// end(11 a)
	}
