import QtQuick 1.1
import com.nokia.meego 1.1
import "Component"
import "../js/main.js" as Script

MyPage {
	id: page;

	// begin(11 c)
	property string term;

	function getlist(type, option)
	{
		if(!type)
		{
			search();
			return;
		}
		if(type === "video" && tabGroup.currentTab === video_view)
		{
			getlist_search_video(option);
		}
		else if(type === "bangumi" && tabGroup.currentTab === bangumi_view)
		{
			search_bangumi(option);
		}
		else if(type === "article" && tabGroup.currentTab === article_view)
		{
			search_article(option);
		}
		else if(type === "album" && tabGroup.currentTab === album_view)
		{
			search_album(option);
		}
		else if(type === "user" && tabGroup.currentTab === up_view)
		{
			search_user(option);
		}
	}

	function search()
	{
		loading = true;
		var opt = { sortField: "score", q: term, aiCount: 1, spCount: 1, greenCount: 0, listCount: 20, userCount: 0/*, type: 2*/};
		video_view.count = 0;
		bangumi_view.count = 0;
		article_view.count = 0;
		album_view.count = 0;
		up_view.count = 0;
		video_view.pageCount = 0;
		bangumi_view.pageCount = 0;
		article_view.pageCount = 0;
		album_view.pageCount = 0;
		up_view.pageCount = 0;
		video_view.hasNext = false;
		bangumi_view.hasNext = false;
		article_view.hasNext = false;
		album_view.hasNext = false;
		up_view.hasNext = false;
		video_view.nextPage = 1;
		bangumi_view.nextPage = 1;
		article_view.nextPage = 1;
		album_view.nextPage = 1;
		up_view.nextPage = 1;

		tabGroup.currentTab = video_view;
		tabRow.checkedButton = video_btn;

		video_sort_field_row.reset();
		bangumi_sort_field_row.reset();
		article_sort_field_row.reset();
		album_sort_field_row.reset();

		function s(obj){
			loading = false;
			if(!obj || !obj.data)
			{
				signalCenter.showMessage(err);
				return;
			}
			if(obj.data.page)
			{
				video_view.count = obj.data.page.videoCount;
				bangumi_view.count = obj.data.page.aiCount;
				article_view.count = obj.data.page.greenCount;
				album_view.count = obj.data.page.spCount;
				up_view.count = obj.data.page.userCount;

				getlist_search_video();
				search_bangumi();
				search_article();
				search_album();
				search_user();
			}
		}
		function f(err){
			loading = false;
			signalCenter.showMessage(err);
		}
		Script.search_keyword(opt, s, f);
	}

	function getlist_search_video(option){
		loading = true;
		var opt = { sortField: video_view.orderName, term: term, model: video_view.model, "pageSize": video_view.pageSize }
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
			var totalCount = obj.data.page.totalCount === -1 ? 0 : obj.data.page.totalCount;
			video_view.pageCount = parseInt(totalCount / video_view.pageSize) + (totalCount % video_view.pageSize ? 1 : 0);
			if (video_view.nextPage >= video_view.pageCount){
				video_view.hasNext = false;
			} else {
				video_view.hasNext = true;
				video_view.nextPage = obj.data.page.pageNo + 1;
			}
		}
		function f(err){
			loading = false;
			signalCenter.showMessage(err);
		}
		Script.getSearch(opt, s, f);
	}

	function search_bangumi(option)
	{
		loading = true;
		var opt = { sort: bangumi_view.orderId, q: term, model: bangumi_view.model, "pageSize": bangumi_view.pageSize }
		if (bangumi_view.count === 0||bangumi_view.nextPage === 1) option = "renew";
		option = option || "renew";
		if (option === "renew"){
			opt.renew = true;
			bangumi_view.nextPage = 1;
		} else {
			opt.pageNo = bangumi_view.nextPage;
		}
		function s(obj){
			loading = false;
			var totalCount = obj.data.page.totalCount === -1 ? 0 : obj.data.page.totalCount;
			bangumi_view.pageCount = parseInt(totalCount / bangumi_view.pageSize) + (totalCount % bangumi_view.pageSize ? 1 : 0);
			if (bangumi_view.nextPage >= bangumi_view.pageCount){
				bangumi_view.hasNext = false;
			} else {
				bangumi_view.hasNext = true;
				bangumi_view.nextPage = obj.data.page.pageNo + 1;
			}
		}
		function f(err){
			loading = false;
			signalCenter.showMessage(err);
		}
		Script.getSearch_bangumi(opt, s, f);
	}

	function search_article(option)
	{
		loading = true;
		var opt = { sortField: article_view.orderName, q: term, model: article_view.model, "pageSize": article_view.pageSize }
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
			var totalCount = obj.data.page.totalCount === -1 ? 0 : obj.data.page.totalCount;
			article_view.pageCount = parseInt(totalCount / article_view.pageSize) + (totalCount % article_view.pageSize ? 1 : 0);
			if (article_view.nextPage >= article_view.pageCount){
				article_view.hasNext = false;
			} else {
				article_view.hasNext = true;
				article_view.nextPage = obj.data.page.pageNo + 1;
			}
		}
		function f(err){
			loading = false;
			signalCenter.showMessage(err);
		}
		Script.getSearch_article(opt, s, f);
	}

	function search_album(option)
	{
		loading = true;
		var opt = { sortField: album_view.orderName, q: term, model: album_view.model, "pageSize": album_view.pageSize }
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
			var totalCount = obj.data.page.totalCount === -1 ? 0 : obj.data.page.totalCount;
			album_view.pageCount = parseInt(totalCount / album_view.pageSize) + (totalCount % album_view.pageSize ? 1 : 0);
			if (album_view.nextPage >= album_view.pageCount){
				album_view.hasNext = false;
			} else {
				album_view.hasNext = true;
				album_view.nextPage = obj.data.page.pageNo + 1;
			}
		}
		function f(err){
			loading = false;
			signalCenter.showMessage(err);
		}
		Script.getSearch_album(opt, s, f);
	}

	function search_user(option)
	{
		loading = true;
		var opt = { sortField: "score", q: term, model: up_view.model, "pageSize": up_view.pageSize }
		if (up_view.count === 0||up_view.nextPage === 1) option = "renew";
		option = option || "renew";
		if (option === "renew"){
			opt.renew = true;
			up_view.nextPage = 1;
		} else {
			opt.pageNo = up_view.nextPage;
		}
		function s(obj){
			loading = false;
			var userCount = obj.data.page.userCount === -1 ? 0 : obj.data.page.userCount;
			up_view.pageCount = parseInt(userCount / up_view.pageSize) + (userCount % up_view.pageSize ? 1 : 0);
			if (up_view.nextPage >= up_view.pageCount){
				up_view.hasNext = false;
			} else {
				up_view.hasNext = true;
				up_view.nextPage = obj.data.page.pageNo + 1;
			}
		}
		function f(err){
			loading = false;
			signalCenter.showMessage(err);
		}
		Script.getSearch_user(opt, s, f);
	}

	// end(11 c)

	tools: ToolBarLayout {
		ToolIcon {
			platformIconId: "toolbar-back";
			onClicked: pageStack.pop();
		}
		ToolIcon {
			platformIconId: "toolbar-refresh";
			onClicked: getlist();
		}
	}

	ViewHeader {
		id: viewheader;
		title: "搜索结果";
	}

	// begin(11 c)
	ButtonRow {
		id: tabRow;
		anchors {
			left: parent.left; top: viewheader.bottom; right: parent.right;
		}
		TabButton {
			id: video_btn;
			text: "视频\n[" + video_view.count + "]";
			tab: video_view;
		}
		TabButton {
			text: "番剧\n[" + bangumi_view.count + "]";
			tab: bangumi_view;
		}
		TabButton {
			text: "文章\n[" + article_view.count + "]";
			tab: article_view;
		}
		TabButton {
			text: "合辑\n[" + album_view.count + "]";
			tab: album_view;
		}
		TabButton {
			text: "UP主\n[" + up_view.count + "]";
			tab: up_view;
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
			property string orderName: "score";
			property variant model: ListModel{}

			anchors.fill: parent;

			Text {
				anchors.centerIn: parent;
				elide: Text.ElideRight;
				font: constant.titleFont;
				color: constant.colorLight;
				text: "<b>无相关视频</b>";
				visible: !loading && parent.count <= 0;
				z: 2;
				clip: true;
			}

			SortFieldButtonRow{
				id: video_sort_field_row;
				anchors.left: parent.left;
				anchors.top: parent.top;
				anchors.right: parent.right;
				enabled: !loading;
				visible: parent.count > 0;
				onSortClicked: {
					video_view.orderId = orderId;
					video_view.orderName = orderName;
					getlist("video");
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
				delegate: CommonDelegate {}
				footer: FooterItem {
					visible: video_view.hasNext;
					enabled: !loading;
					onClicked: getlist("video", "next");
				}
				header: PullToActivate {
					myView: video_list;
					enabled: !loading;
					onRefresh: getlist("video");
				}
				ScrollDecorator { flickableItem: parent; }
			}
		}

		Item{
			id: bangumi_view;
			property int count: 0;
			property int orderId: 0;
			property int nextPage: 1;
			property int pageSize: 20;
			property int pageCount: 0;
			property bool hasNext: false;
			property string orderName: "score";
			property variant model: ListModel{}

			anchors.fill: parent;

			Text {
				anchors.centerIn: parent;
				elide: Text.ElideRight;
				font: constant.titleFont;
				color: constant.colorLight;
				text: "<b>无相关番剧</b>";
				visible: !loading && parent.count <= 0;
				z: 2;
				clip: true;
			}

			SortFieldButtonRow{
				id: bangumi_sort_field_row;
				anchors.left: parent.left;
				anchors.top: parent.top;
				anchors.right: parent.right;
				enabled: !loading;
				visible: parent.count > 0;
				onSortClicked: {
					bangumi_view.orderId = orderId;
					bangumi_view.orderName = orderName;
					getlist("bangumi");
				}
			}

			ListView {
				id: bangumi_list;
				anchors.left: parent.left;
				anchors.top: bangumi_sort_field_row.bottom;
				anchors.bottom: parent.bottom;
				anchors.right: parent.right;
				clip: true;
				visible: parent.count > 0;
				model: parent.model;
				delegate: BangumiDelegate {}
				footer: FooterItem {
					visible: bangumi_view.hasNext;
					enabled: !loading;
					onClicked: getlist("bangumi", "next");
				}
				header: PullToActivate {
					myView: bangumi_list;
					enabled: !loading;
					onRefresh: getlist("bangumi");
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
			property string orderName: "score";
			property variant model: ListModel{}

			anchors.fill: parent;

			Text {
				anchors.centerIn: parent;
				elide: Text.ElideRight;
				font: constant.titleFont;
				color: constant.colorLight;
				text: "<b>无相关文章</b>";
				visible: !loading && parent.count <= 0;
				z: 2;
				clip: true;
			}

			SortFieldButtonRow{
				id: article_sort_field_row;
				anchors.left: parent.left;
				anchors.top: parent.top;
				anchors.right: parent.right;
				enabled: !loading;
				visible: parent.count > 0;
				onSortClicked: {
					article_view.orderId = orderId;
					article_view.orderName = orderName;
					getlist("article");
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
				delegate: CommonDelegate {}
				footer: FooterItem {
					visible: article_view.hasNext;
					enabled: !loading;
					onClicked: getlist("article", "next");
				}
				header: PullToActivate {
					myView: article_list;
					enabled: !loading;
					onRefresh: getlist("article");
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
			property string orderName: "score";
			property variant model: ListModel{}

			anchors.fill: parent;

			Text {
				anchors.centerIn: parent;
				elide: Text.ElideRight;
				font: constant.titleFont;
				color: constant.colorLight;
				text: "<b>无相关合辑</b>";
				visible: !loading && parent.count <= 0;
				z: 2;
				clip: true;
			}

			SortFieldButtonRow{
				id: album_sort_field_row;
				anchors.left: parent.left;
				anchors.top: parent.top;
				anchors.right: parent.right;
				enabled: !loading;
				visible: parent.count > 0;
				onSortClicked: {
					album_view.orderId = orderId;
					album_view.orderName = orderName;
					getlist("album");
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
				delegate: AlbumDelegate {}
				footer: FooterItem {
					visible: album_view.hasNext;
					enabled: !loading;
					onClicked: getlist("album", "next");
				}
				header: PullToActivate {
					myView: album_list;
					enabled: !loading;
					onRefresh: getlist("album");
				}
				ScrollDecorator { flickableItem: parent; }
			}
		}

		Item{
			id: up_view;
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
				text: "<b>无相关UP主</b>";
				visible: !loading && parent.count <= 0;
				z: 2;
				clip: true;
			}

			ListView {
				id: up_list;
				anchors.fill: parent;
				clip: true;
				visible: parent.count > 0;
				model: parent.model;
				delegate: UserDelegate {}
				footer: FooterItem {
					visible: up_view.hasNext;
					enabled: !loading;
					onClicked: getlist("user", "next");
				}
				header: PullToActivate {
					myView: up_list;
					enabled: !loading;
					onRefresh: getlist("user");
				}
				ScrollDecorator { flickableItem: parent; }
			}
		}

	}
	// end(11 c)
}
