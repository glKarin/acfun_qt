import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"
import "../js/main.js" as Script

MyPage {
	id: page;

    title: "粉丝/关注";
	property string username;
	property string type;

	onTypeChanged: {
		tabRow.checkedButton = (type === "followed" ? followed_btn : following_btn);
		tabGroup.currentTab = (type === "followed" ? followed_view : following_view);

		qobj.get_follow();
	}

	QtObject{
		id: qobj;

		function get_follow(t, opt)
		{
			if (Script.checkAuthData()){
				if(!t)
				{
					following_view.pageCount = 0;
					following_view.nextPage = 1;
					following_view.hasNext = false;
					following_view.count = 0;
					followed_view.pageCount = 0;
					followed_view.nextPage = 1;
					followed_view.hasNext = false;
					followed_view.count = 0;
				}
				if(!t || t === "following")
				{
					get_following(opt);
				}
				if(!t || t === "followed")
				{
					get_followed(opt);
				}
			}
		}

		function get_following(option)
		{
			loading = true;
			var opt = { 
				name: "getFollowingList",
				pageSize: following_view.pageSize,
				groupId: -1,
				model: following_view.model
			};
			if (following_view.count === 0||following_view.nextPage === 1) option = "renew";
			option = option || "renew";
			if (option === "renew"){
				opt.renew = true;
				following_view.nextPage = 1;
			} else {
				opt.pageNo = following_view.nextPage;
			}
			function s(obj){
				loading = false;
				following_view.pageCount = obj.totalPage;
				following_view.nextPage = obj.nextPage;
				following_view.hasNext = obj.page < obj.totalPage;
				following_view.count = obj.totalCount;
			}
			function f(err){
				loading = false;
				signalCenter.showMessage(err);
			}
			Script.get_user_follow(opt, s, f);
		}

		function get_followed(option)
		{
			loading = true;
			var opt = { 
				name: "getFollowedList",
				pageSize: followed_view.pageSize,
				model: followed_view.model
			};
			if (followed_view.count === 0||followed_view.nextPage === 1) option = "renew";
			option = option || "renew";
			if (option === "renew"){
				opt.renew = true;
				followed_view.nextPage = 1;
			} else {
				opt.pageNo = followed_view.nextPage;
			}
			function s(obj){
				loading = false;
				followed_view.pageCount = obj.totalPage;
				followed_view.nextPage = obj.nextPage;
				followed_view.hasNext = obj.page < obj.totalPage;
				followed_view.count = obj.totalCount;
			}
			function f(err){
				loading = false;
				signalCenter.showMessage(err);
			}
			Script.get_user_follow(opt, s, f);
		}
	}

	tools: ToolBarLayout {
		ToolIcon {
			platformIconId: "toolbar-back";
			onClicked: pageStack.pop();
		}
		ToolIcon {
			platformIconId: "toolbar-refresh";
			onClicked: qobj.get_follow();
		}
	}

	ViewHeader {
		id: viewheader;
		title: username;
	}

	ButtonRow {
		id: tabRow;
		anchors {
			left: parent.left; top: viewheader.bottom; right: parent.right;
		}
		TabButton {
			id: following_btn;
			text: "关注\n[" + following_view.count + "]";
			tab: following_view;
		}
		TabButton {
			id: followed_btn;
			text: "粉丝\n[" + followed_view.count + "]";
			tab: followed_view;
		}
	}

	TabGroup {
		id: tabGroup;
		anchors {
			left: parent.left; right: parent.right;
			top: tabRow.bottom; bottom: parent.bottom;
		}
		currentTab: following_view;
		clip: true;

		Item{
			id: following_view;
			property int count: 0;
			property int nextPage: 1;
			property int pageSize: 20;
			property int pageCount: 0;
			property bool hasNext: false;
			property variant model: ListModel{}

			anchors.fill: parent;

			Text {
				anchors.centerIn: parent;
				elide: Text.ElideRight;
				font: constant.titleFont;
				color: constant.colorLight;
				text: "<b>无关注</b>";
				visible: !loading && parent.count === 0;
				z: 2;
				clip: true;
			}

			ListView {
				id: following_list;
				anchors.fill: parent;
				clip: true;
				visible: parent.count !== 0;
				model: parent.model;
				delegate: UserDelegate {}
				footer: FooterItem {
					visible: following_view.hasNext;
					enabled: !loading;
					onClicked: qobj.get_follow("following", "next");
				}
				header: PullToActivate {
					myView: following_list;
					enabled: !loading;
					onRefresh: qobj.get_follow("following");
				}
				ScrollDecorator { flickableItem: parent; }
			}
		}

		Item{
			id: followed_view;
			property int count: 0;
			property int nextPage: 1;
			property int pageSize: 20;
			property int pageCount: 0;
			property bool hasNext: false;
			property variant model: ListModel{}

			anchors.fill: parent;

			Text {
				anchors.centerIn: parent;
				elide: Text.ElideRight;
				font: constant.titleFont;
				color: constant.colorLight;
				text: "<b>无粉丝</b>";
				visible: !loading && parent.count === 0;
				z: 2;
				clip: true;
			}

			ListView {
				id: followed_list;
				anchors.fill: parent;
				clip: true;
				visible: parent.count !== 0;
				model: parent.model;
				delegate: UserDelegate {}
				footer: FooterItem {
					visible: followed_view.hasNext;
					enabled: !loading;
					onClicked: qobj.get_follow("followed", "next");
				}
				header: PullToActivate {
					myView: followed_list;
					enabled: !loading;
					onRefresh: qobj.get_follow("followed");
				}
				ScrollDecorator { flickableItem: parent; }
			}
		}

	}
	// end(11 c)
}

