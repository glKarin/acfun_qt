import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"
import "../js/main.js" as Script

MyPage {
	id: page;

	property string uid;
	onUidChanged: internal.getDetail();

	title: "用户信息";

	tools: ToolBarLayout {
		ToolIcon {
			platformIconId: "toolbar-back";
			onClicked: pageStack.pop();
		}
        ToolIcon {
            platformIconId: "../gfx/favourite.svg";
            opacity: internal.is_fav ? 1.0 : 0.5;
			onClicked: internal.toggle_favorite();
		}
		ToolIcon {
            platformIconId: "toolbar-share";
			onClicked: signalCenter.chat_with_by_id(page.uid);
		}
		ToolIcon {
			platformIconId: "toolbar-refresh";
			onClicked: internal.getDetail();
		}
	}

	QtObject {
		id: internal;

		property variant userData: ({});
		property bool is_fav: false;

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

		function addToFav(){
			if (Script.checkAuthData()){
				loading = true;
				var option = {
					userId: page.uid,
					groupId: 0,
					name: "follow"
				};
				function s(obj){
					loading = false; 
					is_fav = true;
					var n = userData;
					userData = {};
					n.followed = obj.followedCount;
					userData = n;
					signalCenter.showMessage("关注用户成功!");
				}
				function f(err){ 
					loading = false; 
					signalCenter.showMessage(err);
				}
				Script.follow_user(option, s, f);
			}
		}

		function unfav(){
			if (Script.checkAuthData()){
				loading = true;
				var option = {
					userId: page.uid,
					name: "unfollow"
				};
				function s(obj){
					loading = false; 
					is_fav = false;;
					var n = userData;
					userData = {};
					n.followed = obj.followedCount;
					userData = n;
					signalCenter.showMessage("取消关注用户成功!");
				}
				function f(err){ 
					loading = false; 
					signalCenter.showMessage(err);
				}
				Script.follow_user(option, s, f);
			}
		}
		function is_favorite()
		{
			if (Script.is_signin()){
				loading = true;
				var option = {
					userId: page.uid,
					name: "checkFollow"
				};
				function s(obj){ 
					loading = false;
					is_fav = obj.isFollowing !== null ? obj.isFollowing : false;
				}
				function f(err){ loading = false; signalCenter.showMessage(err); }
				Script.follow_user(option, s, f);
			}
		}

		function getDetail(){
			loading = true;
			is_fav = false;
			userData = {};
			function s(obj){ loading = false; userData = obj.vdata; user_view.getlist(); is_favorite(); }
			function f(err){ loading = false; signalCenter.showMessage(err); }
			Script.getUserDetail(uid, s, f);
		}
	}

	ViewHeader {
		id: viewHeader;
		title: page.title;
	}

	Column{
		id: contentCol;
		anchors { 
			top: viewHeader.bottom; 
			left: parent.left;
			right: parent.right;
		}
        spacing: constant.paddingSmall;
		Image {
			id: avatar;
			anchors.horizontalCenter: parent.horizontalCenter;
			height: 64;
			width: height;
			sourceSize: Qt.size(width, height);
			source: internal.userData.userImg||"../gfx/avatar.jpg";
		}
		Text {
			anchors.horizontalCenter: parent.horizontalCenter;
			font: constant.titleFont;
			color: constant.colorLight;
			text: internal.userData.username||"";
		}
		Text {
			anchors.horizontalCenter: parent.horizontalCenter;
			width: parent.width;
			font: constant.subTitleFont;
			color: constant.colorMid;
			elide: Text.ElideRight;
			maximumLineCount: 2;
			wrapMode: Text.WrapAnywhere;
			text: internal.userData.signature||"";
		}
		AbstractItem {
			Row{
				anchors {
					left: parent.left; leftMargin: constant.paddingSmall;
					right: parent.paddingItem.right;
					top: parent.paddingItem.top;
				}
				Text {
					width: parent.width / 5;
					font: constant.labelFont;
					color: constant.colorLight;
					text: "等级\n" + (internal.userData.level || 0);
					horizontalAlignment: Text.AlignHCenter;
				}
				Text {
					width: parent.width / 5;
					font: constant.labelFont;
					color: constant.colorLight;
					text: "香蕉\n(" + (internal.userData.banana || 0) + ")";
					horizontalAlignment: Text.AlignHCenter;
				}
				Text {
					width: parent.width / 5;
					font: constant.labelFont;
					color: constant.colorLight;
					text: "金香蕉\n(" + (internal.userData.bananaGold || 0) + ")";
					horizontalAlignment: Text.AlignHCenter;
				}
				Text {
					width: parent.width / 5;
					font: constant.labelFont;
					color: constant.colorLight;
					text: "关注\n(" + (internal.userData.following || 0) + ")";
					horizontalAlignment: Text.AlignHCenter;
				}
				Text {
					width: parent.width / 5;
					font: constant.labelFont;
					color: constant.colorLight;
					text: "粉丝\n(" + (internal.userData.followed || 0) + ")";
					horizontalAlignment: Text.AlignHCenter;
				}
			}
		}

	}
	UserContributeView{
		id: user_view;
		anchors { 
			top: contentCol.bottom; 
			bottom: parent.bottom;
			left: parent.left;
			right: parent.right;
			topMargin: 5;
		}
		userId: page.uid;
	}
}
