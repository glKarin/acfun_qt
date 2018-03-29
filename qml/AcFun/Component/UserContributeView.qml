import QtQuick 1.1
import com.nokia.symbian 1.1
import "../../js/main.js" as Script

Item{
	id: root;

	property string userId;

	function getlist()
	{
		qobj.get_contributes();
	}

	QtObject {
		id: qobj;

		function get_contributes(type, option)
		{
			if(!type)
			{
				video_view.count = 0;
				article_view.count = 0;
				album_view.count = 0;
				video_view.pageCount = 0;
				article_view.pageCount = 0;
				album_view.pageCount = 0;
				video_view.hasNext = false;
				article_view.hasNext = false;
				album_view.hasNext = false;
				video_view.nextPage = 1;
				article_view.nextPage = 1;
				album_view.nextPage = 1;

				tabGroup.currentTab = video_view;
				tabRow.checkedButton = video_btn;

				video_sort_field_row.reset();
				article_sort_field_row.reset();
				album_sort_field_row.reset();
			}
			if(!type || type === "video")
			{
				get_contributes_video(option);
			}
			if(!type || type === "article")
			{
				get_contributes_article(option);
			}
			if(!type || type === "album")
			{
				get_contributes_album(option);
			}
		}

		function get_contributes_video(option){
			loading = true;
			var opt = { 
				userId: root.userId,
				sort: video_view.orderId,
				"status": 2,
				type: 0,
				model: video_view.model, 
				"pageSize": video_view.pageSize 
			};
			if (video_view.count === 0||video_view.nextPage === 1) option = "renew";
			option = option || "renew";
			if (option === "renew"){
				opt.renew = true;
				video_view.nextPage = 1;
			} else {
				opt.pageNo = video_view.nextPage;
			}
			function s(obj){
				loading = false;
				video_view.count = obj.vdata.totalCount === -1 ? 0 : obj.vdata.totalCount;
				video_view.pageCount = parseInt(video_view.count / video_view.pageSize) + (video_view.count % video_view.pageSize ? 1 : 0);
				if (video_view.nextPage >= video_view.pageCount){
					video_view.hasNext = false;
				} else {
					video_view.hasNext = true;
					video_view.nextPage = obj.vdata.pageNo + 1;
				}
			}
			function f(err){
				loading = false;
				signalCenter.showMessage(err);
			}
			Script.getUserVideos(opt, s, f);
		}

		function get_contributes_article(option)
		{
			loading = true;
			var opt = { 
				userId: root.userId,
				sort: article_view.orderId,
				"status": 2,
				type: 1,
				model: article_view.model, 
				"pageSize": article_view.pageSize 
			};
			if (article_view.count === 0||article_view.nextPage === 1) option = "renew";
			option = option || "renew";
			if (option === "renew"){
				opt.renew = true;
				article_view.nextPage = 1;
			} else {
				opt.pageNo = article_view.nextPage;
			}
			function s(obj){
				loading = false;
				article_view.count = obj.vdata.totalCount === -1 ? 0 : obj.vdata.totalCount;
				article_view.pageCount = parseInt(article_view.count / article_view.pageSize) + (article_view.count % article_view.pageSize ? 1 : 0);
				if (article_view.nextPage >= article_view.pageCount){
					article_view.hasNext = false;
				} else {
					article_view.hasNext = true;
					article_view.nextPage = obj.vdata.pageNo + 1;
				}
			}
			function f(err){
				loading = false;
				signalCenter.showMessage(err);
			}
			Script.getUserVideos(opt, s, f);
		}

		function get_contributes_album(option)
		{
			loading = true;
			var opt = { 
				userId: root.userId,
				sort: album_view.orderId,
				model: album_view.model, 
				"pageSize": album_view.pageSize 
			};
			if (album_view.count === 0||album_view.nextPage === 1) option = "renew";
			option = option || "renew";
			if (option === "renew"){
				opt.renew = true;
				album_view.nextPage = 1;
			} else {
				opt.pageNo = album_view.nextPage;
			}
			function s(obj){
				loading = false;
				album_view.count = obj.vdata.totalCount === -1 ? 0 : obj.vdata.totalCount;
				album_view.pageCount = parseInt(album_view.count / album_view.pageSize) + (album_view.count % album_view.pageSize ? 1 : 0);
				if (album_view.nextPage >= album_view.pageCount){
					album_view.hasNext = false;
				} else {
					album_view.hasNext = true;
					album_view.nextPage = obj.vdata.pageNo + 1;
				}
			}
			function f(err){
				loading = false;
				signalCenter.showMessage(err);
			}
			Script.get_user_album(opt, s, f);
		}
	}

	ButtonRow {
		id: tabRow;
		anchors {
			left: parent.left; top: parent.top; right: parent.right;
		}
		TabButton {
			id: video_btn;
			text: "视频\n[" + video_view.count + "]";
			tab: video_view;
		}
		TabButton {
			text: "文章\n[" + article_view.count + "]";
			tab: article_view;
		}
		TabButton {
			text: "合辑\n[" + album_view.count + "]";
			tab: album_view;
		}
	}

	TabGroup {
		id: tabGroup;
		anchors {
			left: parent.left; right: parent.right;
			top: tabRow.bottom; bottom: parent.bottom;
		}
		currentTab: video_view;
		clip: true;

		Item{
			id: video_view;
			property int count: 0;
			property int orderId: 0;
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
				text: "<b>无视频</b>";
				visible: !loading && parent.count <= 0;
				z: 2;
				clip: true;
			}

			ButtonRow {
				id: video_sort_field_row;
				anchors.left: parent.left;
				anchors.top: parent.top;
				anchors.right: parent.right;
				enabled: !loading;
				visible: parent.count > 0;
				function set_video_sort(orderId)
				{
					video_view.orderId = orderId;
					qobj.get_contributes("video");
				}

				function reset()
				{
					checkedButton = video_release;
					video_view.orderId = 1;
				}

				Button {
					id: video_release;
					text: "最新投稿"
					onClicked: { video_sort_field_row.set_video_sort(1); }
				}
				Button {
					text: "最多播放";
					onClicked: { video_sort_field_row.set_video_sort(2); }
				}
				Button {
					text: "最多香蕉";
					onClicked: { video_sort_field_row.set_video_sort(3); }
				}
			}

			ListView {
				id: video_list;
				anchors.left: parent.left;
				anchors.top: video_sort_field_row.bottom;
				anchors.bottom: parent.bottom;
				anchors.right: parent.right;
				clip: true;
				model: parent.model;
				visible: parent.count > 0;
				delegate: UserCommonDelegate {}
				footer: FooterItem {
					visible: video_view.hasNext;
					enabled: !loading;
					onClicked: qobj.get_contributes("video", "next");
				}
				header: PullToActivate {
					myView: video_list;
					enabled: !loading;
					onRefresh: qobj.get_contributes("video");
				}
				ScrollDecorator { flickableItem: parent; }
			}
		}

		Item{
			id: article_view;
			property int count: 0;
			property int orderId: 0;
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
				text: "<b>无文章</b>";
				visible: !loading && parent.count <= 0;
				z: 2;
				clip: true;
			}

			ButtonRow {
				id: article_sort_field_row;
				anchors.left: parent.left;
				anchors.top: parent.top;
				anchors.right: parent.right;
				enabled: !loading;
				visible: parent.count > 0;
				function set_article_sort(orderId)
				{
					article_view.orderId = orderId;
					qobj.get_contributes("article");
				}
				function reset()
				{
					checkedButton = article_release;
					article_view.orderId = 1;
				}

				Button {
					id: article_release;
					text: "最新投稿"
					onClicked: { article_sort_field_row.set_article_sort(1); }
				}
				Button {
					text: "最多播放";
					onClicked: { article_sort_field_row.set_article_sort(2); }
				}
				Button {
					text: "最多香蕉";
					onClicked: { article_sort_field_row.set_article_sort(3); }
				}
			}

			ListView {
				id: article_list;
				anchors.left: parent.left;
				anchors.top: article_sort_field_row.bottom;
				anchors.bottom: parent.bottom;
				anchors.right: parent.right;
				clip: true;
				model: parent.model;
				visible: parent.count > 0;
				delegate: UserCommonDelegate {}
				footer: FooterItem {
					visible: article_view.hasNext;
					enabled: !loading;
					onClicked: qobj.get_contributes("article", "next");
				}
				header: PullToActivate {
					myView: article_list;
					enabled: !loading;
					onRefresh: qobj.get_contributes("article");
				}
				ScrollDecorator { flickableItem: parent; }
			}
		}

		Item{
			id: album_view;
			property int count: 0;
			property int orderId: 0;
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
				text: "<b>无合辑</b>";
				visible: !loading && parent.count <= 0;
				z: 2;
				clip: true;
			}

			ButtonRow {
				id: album_sort_field_row;
				anchors.left: parent.left;
				anchors.top: parent.top;
				anchors.right: parent.right;
				enabled: !loading;
				visible: parent.count > 0;
				function set_album_sort(orderId)
				{
					album_view.orderId = orderId;
					qobj.get_contributes("album");
				}
				function reset()
				{
					checkedButton = album_release;
					album_view.orderId = 5;
				}

				Button {
					id: album_release;
					text: "最新更新"
					onClicked: { album_sort_field_row.set_album_sort(5); }
				}
				Button {
					text: "最多收藏";
					onClicked: { album_sort_field_row.set_album_sort(4); }
				}
			}

			ListView {
				id: album_list;
				anchors.left: parent.left;
				anchors.top: album_sort_field_row.bottom;
				anchors.bottom: parent.bottom;
				anchors.right: parent.right;
				clip: true;
				model: parent.model;
				visible: parent.count > 0;
				delegate: UserAlbumDelegate {}
				footer: FooterItem {
					visible: album_view.hasNext;
					enabled: !loading;
					onClicked: qobj.get_contributes("album", "next");
				}
				header: PullToActivate {
					myView: album_list;
					enabled: !loading;
					onRefresh: qobj.get_contributes("album");
				}
				ScrollDecorator { flickableItem: parent; }
			}
		}

	}
}
