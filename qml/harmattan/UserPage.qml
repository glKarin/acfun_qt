import QtQuick 1.1
import com.nokia.meego 1.1
import "Component"
import "../js/main.js" as Script

MyPage {
    id: page;

    property string uid;
    onUidChanged: internal.getDetail();

    title: "个人中心";

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back";
            onClicked: pageStack.pop();
        }
				// begin(11 a)
        ToolIcon {
            platformIconId: "toolbar-refresh";
            onClicked: internal.getDetail();
        }
				// end(11 a)
    }

    QtObject {
        id: internal;

        property variant userData: ({});
        property int has_sign_in: 0;
				property variant unread: ({});

				// begin(11 a)
				function view_follow(f)
				{
					var t = f;
					if(!t)
					{
						t = "following";
					}
					t = (t === "followed") ? "followed" : "following";
					pageStack.push(Qt.resolvedUrl("UserFollowPage.qml"), {username: userData.username || "", type: t});
				}
				// end(11 a)

        function getDetail(){
            loading = true;
						// begin(11 c)
            function s(obj){ loading = false; userData = obj.vdata; is_sign_in(); get_unread(); }
            function f(err){ loading = false; signalCenter.showMessage(err); }
						// end(11 c)
            Script.getUserDetail(uid, s, f);
        }

						// begin(11 c)
        function record_sign_in(){
					if(Script.checkAuthData())
					{
            loading = true;
						function s(obj){ loading = false; has_sign_in = 2; signalCenter.showMessage("签到成功"/* data: {"count": 3, "msg": "3"} */); }
            function f(err){ loading = false; signalCenter.showMessage(err); }
						Script.record_sign_in(undefined, s, f);
					}
        }

				function is_sign_in()
				{
					if(Script.checkAuthData())
					{
            loading = true;
						has_sign_in = 0;
						var opt = {
							channel: 1
						};
            function s(obj){ loading = false; has_sign_in = (obj.data === true ? 2 : (obj.data === false ? 1 : 0)); }
            function f(err){ loading = false; signalCenter.showMessage(err); }
						Script.record_sign_in(opt, s, f);
					}
				}

				function get_unread()
				{
					if(Script.checkAuthData())
					{
            loading = true;
						unread = {};
						function s(obj){ 
							loading = false; 
							unread = obj;
							page_model.setProperty(0, "has_new", unread.bangumi.length > 0);
							//page_model.setProperty(2, "has_new", unread.newPush > 0); // 新推送
							page_model.setProperty(3, "has_new", unread.unReadMail > 0 || unread.mention > 0);
						}
            function f(err){ loading = false; signalCenter.showMessage(err); }
						Script.user_unread(page.uid, s, f);
					}
				}
				// end(11 c)
    }

    ViewHeader {
        id: viewHeader;
        title: page.title;
    }

    Flickable {
        id: view;
        anchors { fill: parent; topMargin: viewHeader.height; }
        contentWidth: parent.width;
        contentHeight: contentCol.height;

        Column {
            id: contentCol;
            anchors { left: parent.left; right: parent.right; }
						spacing: constant.paddingSmall;
            SectionHeader {
                title: "我的资料";
            }
						// begin(11 c)
						Column{
							width: parent.width;
							spacing: constant.paddingSmall;
							AbstractItem {
								id: profileItem;
								Image {
									id: avatar;
									anchors {
										left: profileItem.paddingItem.left;
										top: profileItem.paddingItem.top;
										bottom: profileItem.paddingItem.bottom;
									}
									width: height;
									sourceSize: Qt.size(width, height);
									// begin(11 c)
									source: internal.userData.userImg||"../gfx/avatar.jpg";
									// end(11 c)
								}
								Column {
									anchors {
										left: avatar.right; leftMargin: constant.paddingSmall;
										right: profileItem.paddingItem.right;
										top: profileItem.paddingItem.top;
									}
									Text {
										font: constant.labelFont;
										color: constant.colorLight;
										// begin(11 c)
										text: internal.userData.username||"";
										// end(11 c)
									}
									Text {
										width: parent.width;
										font: constant.subTitleFont;
										color: constant.colorMid;
										elide: Text.ElideRight;
										// begin(11 c)
										text: internal.userData.signature||"";
										// end(11 c)
									}
								}
							}
							AbstractItem {
								Row{
									anchors {
										left: parent.left; leftMargin: constant.paddingSmall;
										right: parent.paddingItem.right;
										top: parent.paddingItem.top;
									}
									Text {
										width: parent.width / 4;
										font: constant.labelFont;
										color: constant.colorLight;
										text: "等级\n" + (internal.userData.level || 0);
										horizontalAlignment: Text.AlignHCenter;
									}
									Text {
										width: parent.width / 4;
										font: constant.labelFont;
										color: constant.colorLight;
										text: "投稿\n(" + (internal.userData.contributes || 0) + ")";
										horizontalAlignment: Text.AlignHCenter;
										MouseArea{
											anchors.fill: parent;
											onClicked: {
                        if (Script.checkAuthData()){
                            var prop = { title: "我的稿件" };
                            pageStack.push(Qt.resolvedUrl("UserPageCom/UserVideoPage.qml"), prop);
                        }
											}
										}
									}
									Text {
										width: parent.width / 4;
										font: constant.labelFont;
										color: constant.colorLight;
										text: "关注\n(" + (internal.userData.following || 0) + ")";
										horizontalAlignment: Text.AlignHCenter;
										MouseArea{
											anchors.fill: parent;
											onClicked: {
												internal.view_follow("following");
											}
										}
									}
									Text {
										width: parent.width / 4;
										font: constant.labelFont;
										color: constant.colorLight;
										text: "粉丝\n(" + (internal.userData.followed || 0)+ ")";
										horizontalAlignment: Text.AlignHCenter;
										MouseArea{
											anchors.fill: parent;
											onClicked: {
												internal.view_follow("followed");
											}
										}
										Rectangle{
											anchors.right: parent.right;
											anchors.verticalCenter: parent.verticalCenter;
											anchors.rightMargin: constant.paddingLarge;
											width: 12;
											height: width;
											smooth: true;
											radius: width / 2;
											visible: internal.unread.hasOwnProperty("newFollowed") && internal.unread.newFollowed > 0;
											color: "red";
										}
									}
								}
							}
						}
						Button {
							anchors.horizontalCenter: parent.horizontalCenter;
							platformStyle: ButtonStyle {
								buttonWidth: 200;
							}
							text: internal.has_sign_in === 2 ? "已签到" : (internal.has_sign_in === 1 ? "签到" : "未签到");
							enabled: internal.has_sign_in === 1;
							onClicked: {
								internal.record_sign_in();
							}
						}
						// end(11 c)
            SectionHeader {
                title: "我在AC";
            }
            Repeater {
                model: ListModel {
									// begin(11 c)
									id: page_model;
                    ListElement { name: "我的收藏"; file: "UserPageCom/FavPage.qml"; has_new: false; }
                    ListElement { name: "播放历史"; file: "UserPageCom/HistoryPage.qml"; has_new: false; }
                    ListElement { name: "我的稿件"; file: "UserPageCom/UserVideoPage.qml"; has_new: false; }
                    ListElement { name: "我的私信"; file: "UserPageCom/PrivateMsgPage.qml"; has_new: false; }
										// end(11 c)
                }
                AbstractItem {
                    Text {
                        anchors.left: parent.paddingItem.left;
                        anchors.verticalCenter: parent.verticalCenter;
                        font: constant.titleFont;
                        color: constant.colorLight;
                        text: model.name;
                    }
										// begin(11 a)
										Rectangle{
											anchors.right: parent.right;
											anchors.verticalCenter: parent.verticalCenter;
											anchors.rightMargin: constant.paddingLarge;
											width: 12;
											height: width;
											smooth: true;
											radius: width / 2;
											visible: model.has_new;
											color: "red";
										}
										// end(11 a)
                    onClicked: {
                        if (Script.checkAuthData()){
                            var prop = { title: model.name };
                            pageStack.push(Qt.resolvedUrl(model.file), prop);
                        }
                    }
                }
            }
            FooterItem {
                listView: view;
                text: "退出登录";
                onClicked: {
                    acsettings.accessToken = "";
										// begin(11 c)
                    //utility.clearCookies();
										utility.sign_out();
										// end(11 c)
                    pageStack.pop();
                }
            }
        }
    }
		ScrollDecorator { flickableItem: view; }
}
