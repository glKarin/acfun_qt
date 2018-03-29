import QtQuick 1.1
import com.nokia.meego 1.1
import CustomWebKit 1.0
import "../Component"
import "../../js/main.js" as Script
import "../../js/database.js" as Database

MyPage {
    id: page;

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back";
            onClicked: {
								// begin(11 a)
								if(from_where !== "list")
								{
									pageStack.pop(undefined, true);
								}
								pageStack.pop();
								// end(11 a)
            }
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
    }

    property string acId;
		// begin(11 a)
		property string from_where: "list";
		// end(11 a)
    onAcIdChanged: internal.getDetail();

    QtObject {
        id: internal;

        property variant detail: ({});

        property variant commentUI: null;

				// begin(11 a)
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
				// end(11 a)

        function createCommentUI(){
            if (!Script.checkAuthData()) return;
            if (!commentUI){
                commentUI = Qt.createComponent("CommentUI.qml").createObject(page);
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
            function s(){ loading = false; signalCenter.showMessage("发送成功"); getComments(); }
						// end(11 c)
            function f(err){ loading = false; signalCenter.showMessage(err); }
            Script.sendComment(opt, s, f);
        }

        function getDetail(){
            loading = true;
						// begin(11 c)
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
						// end(11 c)
        }

        function addToFav(){
            if (Script.checkAuthData()){
                loading = true;
								// begin(11 c)
                function s(){ loading = false; is_fav = true; signalCenter.showMessage("收藏文章成功!") }
                function f(err, e){ loading = false; if(e) { if(e.eid === 610001) internal.is_fav = true; } signalCenter.showMessage(err); }
								// end(11 c)
                Script.addToFav(acId, s, f);
            }
        }

        function log(){
					// begin(11 c)
            Database.storeHistory(acId, detail.channelId, detail.title, detail.image,
                                  detail.visit.views, detail.owner.name);
																	// end(11 c)
        }

        function share(){
					// begin(11 c)
					if(detail.shareUrl)
					{
            var link = detail.shareUrl;
            var title = detail.title || "";
						utility.share(title, link);
					}
					// end(11 c)
        }

        function loadText(){
            var model = repeater.model;
            model.clear();
            var partRep = /\[NextPage](.*?)\[\/NextPage]/g
						// begin(11 c)
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
						// end(11 c)
        }
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
		// end(11 a)

		// begin(11 c)
		ViewHeader {
			id: viewHeader;
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.right: parent.right;
			//width: view.width;
			title: internal.detail.title || "";
		}
		SectionHeader {
			id: section_header;
			anchors.top: viewHeader.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			//width: view.width;
			title: internal.detail.owner ? internal.detail.owner.name : "";
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
				// begin(11 c)
				tab: web_view;
				// end(11 c)
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
								SectionHeader {
									width: webView.width;
									title: model.title;
									visible: title !== "";
								}
								WebView {
									id: webView;
									preferredWidth: view.width;
									preferredHeight: view.height;
									settings {
										standardFontFamily: "Nokia Pure Text"
										defaultFontSize: 26
										defaultFixedFontSize: 26
										minimumFontSize: 26
										minimumLogicalFontSize: 26
										autoLoadImages: acsettings.articleLoadImage;
									}
									html: model.text;
									onLinkClicked: signalCenter.view_link(link);
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
					ScrollDecorator { flickableItem: parent; }
				}
			}

		}
		// end(11 c)

	}
