import QtQuick 1.1
import com.nokia.meego 1.1
import "../Component"
import "../../js/main.js" as Script

MyPage {
    id: page;

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back";
            onClicked: pageStack.pop();
        }
        ToolIcon {
            platformIconId: "toolbar-refresh";
            onClicked: internal.getlist();
        }
        ToolIcon {
            platformIconId: internal.deleteMode ? "toolbar-done"
                                                : "toolbar-delete";
					// begin(11 c)
					visible: tabGroup.currentTab === msg_view;
					enabled: visible;
					// end(11 c)
            onClicked: internal.deleteMode = !internal.deleteMode;
        }
    }

    QtObject {
        id: internal;

				// begin(11 c)
        property bool deleteMode: false;
				// end(11 c)

				// begin(11 c)
				function getlist(type, option)
				{
					internal.deleteMode = false;
					if(!type)
					{
						msg_view.count = 0;
						msg_view.pageCount = 0;
						msg_view.hasNext = false;
						alert_view.hasNext = false;
						alert_view.count = 0;
						alert_view.pageCount = 0;
						msg_view.nextPage = 1;
						alert_view.nextPage = 1;

						option = undefined;
					}

					if(!type || type === "msg")
					{
						get_message(option);
					}
					if(!type || type === "alert")
					{
						get_alert(option);
					}
				}

				function get_message(option){
					if(Script.checkAuthData())
					{
						loading = true;
						var opt = { name: "getGroups", model: msg_view.model }
						if (msg_view.nextPage === 1) option = "renew";
						option = option || "renew";
						if (option === "renew"){
							opt.renew = true;
							msg_view.nextPage = 1;
						} else {
							opt.page = msg_view.nextPage;
						}
						function s(obj){
							loading = false;
							if (obj.page <= obj.totalPage){
								msg_view.pageCount = obj.totalPage
								msg_view.count = obj.totalCount;
								if (obj.page === obj.totalPage){
									msg_view.hasNext = false;
								} else {
									msg_view.hasNext = true;
									msg_view.nextPage = obj.nextPage;
								}
							}
						}
						function f(err){
							loading = false;
							signalCenter.showMessage(err);
						}
            Script.getPrivateMsgs(opt, s, f);
					}
				}

				function get_alert(option){
					if(Script.checkAuthData())
					{
						loading = true;
						var opt = { pageSize: alert_view.pageSize, model: alert_view.model }
						if (alert_view.nextPage === 1) option = "renew";
						option = option || "renew";
						if (option === "renew"){
							opt.renew = true;
							alert_view.nextPage = 1;
						} else {
							opt.pageNo = alert_view.nextPage;
						}
						function s(obj){
							loading = false;
							if (obj.data.page.totalCount > 0){
								alert_view.count = obj.data.page.totalCount;
								alert_view.pageCount = parseInt(alert_view.count / alert_view.pageSize) + (alert_view.count % alert_view.pageSize ? 1 : 0);
								if (alert_view.nextPage >= alert_view.pageCount){
									alert_view.hasNext = false;
								} else {
									alert_view.hasNext = true;
									alert_view.nextPage = alert_view.nextPage + 1;
								}
							}
							else
							{
								alert_view.hasNext = false;
								signalCenter.showMessage("已经没有更多了");
							}
						}
						function f(err){
							loading = false;
							signalCenter.showMessage(err);
						}
            Script.get_user_alert(opt, s, f);
					}
				}

        function deleteMsg(idx, mgid, p2p){
					if(Script.checkAuthData())
					{
						loading = true;
						var opt = { mailGroupId: mgid, "p2p": p2p, name: "deleteGroup" }
						function s(obj){
							loading = false;
							msg_view.model.remove(idx);
						}
						function f(err){
							loading = false;
							signalCenter.showMessage(err);
						}
            Script.delete_msg_group(opt, s, f);
					}
        }
				// end(11 c)
    }

		// begin(11 r)
		/*
    Connections {
        id: helperListener;
        property string reqUrl;
        property int index;
        target: networkHelper;
        onRequestFinished: {
            if (url.toString() === helperListener.reqUrl){
                loading = false;
                view.model.remove(helperListener.index);
            }
        }
        onRequestFailed: {
            if (url.toString() === helperListener.reqUrl){
                loading = false;
            }
        }
			}
			*/
		// end(11 r)

    ViewHeader {
        id: viewHeader;
        title: page.title;
    }

		// begin(11 c)
		ButtonRow {
			id: tabRow;
			anchors {
				left: parent.left; top: viewHeader.bottom; right: parent.right;
			}
			TabButton {
				id: msg_btn;
				text: "私信\n[" + msg_view.count + "]";
				tab: msg_view;
			}
			TabButton {
				text: "提醒\n[" + alert_view.count + "]";
				tab: alert_view;
			}
		}


		TabGroup {
			id: tabGroup;
			anchors {
				left: parent.left; right: parent.right;
				top: tabRow.bottom; bottom: parent.bottom;
			}
			currentTab: msg_view;
			onCurrentTabChanged: {
				internal.deleteMode = false;
			}
			clip: true;

			Item{
				id: msg_view;
				property int nextPage: 1;
				property int pageCount: 0;
				property int count: 0;
				property bool hasNext: false;
				property variant model: ListModel{}

				anchors.fill: parent;

				Text {
					anchors.centerIn: parent;
					elide: Text.ElideRight;
					font: constant.titleFont;
					color: constant.colorLight;
					text: "<b>无私信</b>";
					visible: !loading && parent.model.count === 0;
					z: 2;
					clip: true;
				}

				ListView {
					id: msg_list;
					anchors.fill: parent;
					clip: true;
					visible: parent.model.count > 0;
					model: parent.model
					delegate: pmDelegate
					footer: FooterItem {
						visible: msg_view.hasNext;
						enabled: !loading;
						onClicked: internal.getlist("msg", "next");
					}
					header: PullToActivate {
						myView: msg_list;
						enabled: !loading;
						onRefresh: internal.getlist("msg");
					}
					Component {
						id: pmDelegate;
						AbstractItem {
							id: root;
							onClicked: {
								var prop = { p2p: model.p2p, username: model.fromusername, talkwith: model.fromuId};
								pageStack.push(Qt.resolvedUrl("ConverPage.qml"), prop);
							}
							implicitHeight: contentCol.height + constant.paddingLarge*2;
							Image {
								id: avatar;
								anchors {
									left: root.paddingItem.left;
									top: root.paddingItem.top;
								}
								width: constant.graphicSizeSmall;
								height: constant.graphicSizeSmall;
								source: model.user_img;
								// begin(11 a)
								MouseArea{
									anchors.fill: parent;
									onClicked: {
										signalCenter.view_user_detail_by_id(model.fromuId);
									}
								}
								// end(11 a)
							}
							Column {
								id: contentCol;
								anchors {
									left: avatar.right;
									leftMargin: constant.paddingMedium;
									right: root.paddingItem.right;
									top: root.paddingItem.top;
								}
								Text {
									width: parent.width;
									font: constant.labelFont;
									color: constant.colorMid;
									elide: Text.ElideRight;
									text: model.fromusername
								}
								Text {
									width: parent.width;
									font: constant.labelFont;
									color: constant.colorLight;
									elide: Text.ElideRight;
									wrapMode: Text.Wrap;
									maximumLineCount: 2;
									// begin(11 c)
									text: Script.format_comment(model.lastMessage, "../../gfx/assets");
									onLinkActivated: root.clicked();
									// end(11 c)
								}
								Text {
									font: constant.subTitleFont;
									color: constant.colorMid;
									text: utility.easyDate(model.postTime);
								}
							}
							Button {
								anchors {
									right: parent.right;
									verticalCenter: parent.verticalCenter;
								}
								enabled: !loading;
								platformStyle: ButtonStyle {
									buttonWidth: buttonHeight;
								}
								iconSource: "image://theme/icon-m-toolbar-delete"
								visible: tabGroup.currentTab === msg_view && internal.deleteMode;
								onClicked: internal.deleteMsg(index, mailGroupId, p2p);
							}
						}
					}
				}
				ScrollDecorator { flickableItem: msg_list; }

			}

			Item{
				id: alert_view;
				property int nextPage: 1;
				property int pageSize: 10;
				property int pageCount: 0;
				property int count: 0;
				property bool hasNext: false;
				property variant model: ListModel{}

				anchors.fill: parent;

				Text {
					anchors.centerIn: parent;
					elide: Text.ElideRight;
					font: constant.titleFont;
					color: constant.colorLight;
					text: "<b>无提醒</b>";
					visible: !loading && parent.model.count === 0;
					z: 2;
					clip: true;
				}

				ListView {
					id: alert_list;
					anchors.fill: parent;
					clip: true;
					visible: parent.model.count > 0;
					model: parent.model
					delegate: Component {
						AbstractItem {
							id: root;
							onClicked: {
								signalCenter.viewDetail(model.contentId, model.type);
							}
							implicitHeight: bg.height + constant.paddingLarge * 2;
							Rectangle{
								id: bg;
								width: parent.width;
								height: main_col.height;
								Column{
									id: main_col;
									anchors.top: parent.top;
									anchors.right: parent.right;
									anchors.left: parent.left;
									anchors.margins: constant.paddingMedium;
									spacing: constant.paddingMedium;
									// title bar
									Rectangle{
										anchors.horizontalCenter: parent.horizontalCenter;
										width: parent.width;
										border.width: 2;
										border.color: "lightgrey";
										height: 60;
										radius: 4;
										smooth: true;
										Row{
											anchors.fill: parent;
											anchors.leftMargin: constant.paddingMedium;
											spacing: constant.paddingSmall;
											Text {
												anchors.verticalCenter: parent.verticalCenter;
												width: parent.width - 2 * parent.spacing - right_line.width - type_text.width;
												font: constant.labelFont;
												color: constant.colorLight;
												elide: Text.ElideRight;
												text: model.title;
											}
											Text {
												id: type_text;
												anchors.verticalCenter: parent.verticalCenter;
												width: 48;
												font: constant.subTitleFont;
												color: model.type === "article" ? "mediumpurple" : "orange";
												elide: Text.ElideRight;
												text: model.type === "article" ? "文章" : "视频";
											}
											Rectangle{
												id: right_line;
												anchors.verticalCenter: parent.verticalCenter;
												color: model.type === "article" ? "mediumpurple" : "orange";
												width: 3;
												height: parent.height;
											}
										}
									}
									// quote bar
									Rectangle{
										anchors.horizontalCenter: parent.horizontalCenter;
										color: "lightyellow";
										width: parent.width;
										border.width: 1;
										border.color: "lightgrey";
										height: quote_comment_col.height;
										radius: 4;
										smooth: true;
										Column{
											id: quote_comment_col;
											anchors.left: parent.left;
											anchors.right: parent.right;
											anchors.top: parent.top;
											anchors.leftMargin: constant.paddingMedium;
											anchors.rightMargin: constant.paddingMedium;
											spacing: constant.paddingMedium;
											Item{
												anchors.left: parent.left;
												anchors.right: parent.right;
												height: 40;
												Text {
													id: quote_floor_text;
													anchors.left: parent.left;
													anchors.verticalCenter: parent.verticalCenter;
													font: constant.titleFont;
													color: "tomato";
													elide: Text.ElideRight;
													text: "#" + model.quote_floor;
												}
												Text {
													anchors.left: quote_floor_text.right;
													anchors.right: parent.right;
													anchors.leftMargin: constant.paddingLarge;
													anchors.verticalCenter: parent.verticalCenter;
													font: constant.titleFont;
													color: constant.colorMid;
													elide: Text.ElideRight;
													text: model.quote_username;
												}
											}
											Text {
												anchors.left: parent.left;
												anchors.right: parent.right;
												font: constant.subTitleFont;
												wrapMode: Text.WrapAnywhere;
												color: constant.colorMid;
												text: Script.format_comment(model.quote_content, "../../gfx/assets");
											}
										}
									}
									// comment
									Item{
										anchors.horizontalCenter: parent.horizontalCenter;
										width: parent.width;
										height: Math.max(avatar.height + constant.paddingMedium * 2, comment_col.height + constant.paddingMedium * 2);
										Image {
											id: avatar;
											anchors {
												left: parent.left;
												top: parent.top;
												topMargin: constant.paddingMedium;
												leftMargin: constant.paddingMedium;
											}
											width: constant.graphicSizeLarge;
											height: constant.graphicSizeLarge;
											source: model.avatar;
											MouseArea{
												anchors.fill: parent;
												onClicked: {
													signalCenter.view_user_detail_by_id(model.userId);
												}
											}
										}
										Column{
											id: comment_col;
											anchors.left: avatar.right;
											anchors.leftMargin: constant.paddingLarge;
											anchors.right: parent.right;
											anchors.rightMargin: constant.paddingMedium;
											anchors.top: parent.top;
											spacing: constant.paddingMedium;
											Item{
												anchors.left: parent.left;
												anchors.right: parent.right;
												height: 40;
												Text {
													id: floor_text;
													anchors.left: parent.left;
													anchors.verticalCenter: parent.verticalCenter;
													font: constant.titleFont;
													color: "tomato";
													elide: Text.ElideRight;
													text: "#" + model.floor;
												}
												Text {
													anchors.left: floor_text.right;
													anchors.right: parent.right;
													anchors.leftMargin: constant.paddingLarge;
													anchors.verticalCenter: parent.verticalCenter;
													font: constant.titleFont;
													color: constant.colorMid;
													elide: Text.ElideRight;
													text: model.username;
												}
												Text {
													id: date_text;
													anchors.right: parent.right;
													anchors.verticalCenter: parent.verticalCenter;
													font: constant.subTitleFont;
													color: constant.colorMid;
													elide: Text.ElideRight;
													text: utility.easyDate(new Date(model.time));
												}
											}
											Text {
												anchors.left: parent.left;
												anchors.right: parent.right;
												font: constant.subTitleFont;
												wrapMode: Text.WrapAnywhere;
												color: constant.colorMid;
												text: Script.format_comment(model.content, "../../gfx/assets");
											}
										}
									}
								}
							}
						}
					}
					footer: FooterItem {
						visible: alert_view.hasNext;
						enabled: !loading;
						onClicked: internal.getlist("alert", "next");
					}
					header: PullToActivate {
						myView: alert_list;
						enabled: !loading;
						onRefresh: internal.getlist("alert");
					}
				}
				ScrollDecorator { flickableItem: alert_list; }

			}

		}

		// begin(11 a)
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
		// end(11 a)

		Component.onCompleted: internal.getlist();
	}
