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
			platformIconId: internal.is_fav ? "toolbar-favorite-mark" : "toolbar-favorite-unmark";
			onClicked: internal.toggle_favorite();
		}
		ToolIcon {
			platformIconId: "toolbar-share";
			onClicked: internal.share();
		}
	}

	property string albumId;
	onAlbumIdChanged: internal.getDetail();

	QtObject {
		id: internal;

		property variant detail: ({});

		property int pageNumber: 1;
		property int totalNumber: 0;
		property int pageSize: 50;
		property bool is_fav: false;

		property Text textHelper: Text {
			font: constant.subTitleFont;
			text: " ";
			visible: false;
		}

		property string c_SHOW_DETAIL_STATE: "show";
		property string c_HIDE_DETAIL_STATE: "hide";
		property string detail_state: c_SHOW_DETAIL_STATE;

		function is_favorite()
		{
			if (Script.is_signin()){
				loading = true;
				function s(obj){ 
					loading = false;
					is_fav = obj.vdata !== null ? obj.vdata : false;
				}
				function f(err){ loading = false; signalCenter.showMessage(err); }
				Script.favorite_album(albumId, s, f);
			}
		}

		function unfav(){
			if (Script.checkAuthData()){
				var url = Script.AcApi.FAVORITE_ALBUM.arg(page.albumId);
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

		function destroy_all_tab()
		{
			var i;
			for(i = 0; i < tabGroup.children.length; i++)
			{
				if(tabGroup.children[i].hasOwnProperty("groupId"))
				{
					tabGroup.children[i].destroy();
				}
			}
		}

		function change_current_tab(groupId, index)
		{
			var has_tab = false;
			var i;
			for(i = 0; i < tabGroup.children.length; i++)
			{
				if(tabGroup.children[i].hasOwnProperty("groupId"))
				{
					if(tabGroup.children[i].groupId == groupId)
					{
						has_tab = true;
						break;
					}
				}
			}
			if(has_tab)
			{
				tabGroup.currentTab = tabGroup.children[i];
			}
			else
			{
				var component = Qt.createComponent(Qt.resolvedUrl("Component/AlbumGroupListView.qml"));
				if(component.status === Component.Ready){
					var prop = {
						"groupId": groupId,
						albumId: page.albumId
					};
					var obj = component.createObject(tabGroup, prop);
					obj.get_group_list();
					/*
					 obj.clicked.connect(function(contentId, type){
					 });
					 */
					tabGroup.currentTab = obj;
				}else{
					console.log(component.errorString());
				}
			}
		}

		function toggle_detail_state()
		{
			if(detail_state === c_SHOW_DETAIL_STATE)
			{
				detail_state = c_HIDE_DETAIL_STATE;
			}
			else
			{
				detail_state = c_SHOW_DETAIL_STATE;
			}
		}

		function getDetail(){
			titleBanner.error = false;
			titleBanner.loading = true;
			group_model.clear();
			destroy_all_tab();
			var opt = {
				albumId: page.albumId,
				model: group_model
			};
			function s(obj){
				titleBanner.loading = false;
				detail = obj.vdata;
				if(group_model.count > 0)
				{
					group_view.currentIndex = 0;
					change_current_tab(group_model.get(0).groupId, 0);
				}
				is_favorite();
			}
			function f(err){
				titleBanner.loading = false;
				titleBanner.error = true;
				signalCenter.showMessage(err);
			}
			Script.get_album_detail(opt, s, f);
		}

		function addToFav(){
			if (Script.checkAuthData()){
				loading = true;
				function s(){ loading = false; is_fav = true; signalCenter.showMessage("收藏合辑成功!") }
				function f(err, e){ loading = false; if(e) { if(e.eid === 610003) internal.is_fav = true; } signalCenter.showMessage(err); }
				Script.favorite_album(page.albumId, s, f, "add");
			}
		}
		function share(){
			if(detail.shareUrl)
			{
				var link = detail.shareUrl;
				var title = detail.title||"";
				utility.share(title, link)
			};
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
					if(Script.check_error(Script.AcApi.FAVORITE_ALBUM, obj, function(err){
						signalCenter.showMessage(err);
					}))
					{
						return;
					}
					internal.is_fav = false;
					signalCenter.showMessage("已取消收藏合辑");
				}
				catch(e)
				{
					signalCenter.showMessage("取消收藏合辑出现错误");
				}
			}
		}
		onRequestFailed: {
			if (url.toString() === helperListener.reqUrl){
				loading = false;
				signalCenter.showMessage("取消收藏合辑失败");
			}
		}
	}
	ViewHeader {
		id: viewHeader;
		title: "合辑详细";
	}

	SectionHeader {
		id: detail_header;
		anchors.top: viewHeader.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		title: internal.detail.title || "";
		MouseArea{
			anchors.fill: parent;
			onClicked: {
				internal.toggle_detail_state();
			}
		}
		ToolIcon {
			id: detail_btn;
			anchors.right: parent.right;
			anchors.verticalCenter: parent.verticalCenter;
			transform: Rotation {
				id: rotation;
				origin: Qt.vector3d(detail_btn.width / 2, detail_btn.height / 2, 0);
				axis: Qt.vector3d(1, 0, 0);
				angle: 0;
			}
			states: [
				State{
					name: internal.c_SHOW_DETAIL_STATE;
					PropertyChanges {
						target: rotation;
						angle: 0;
					}
				}
				,
				State{
					name: internal.c_HIDE_DETAIL_STATE;
					PropertyChanges {
						target: rotation;
						angle: -180;
					}
				}
			]
			transitions: [
				Transition {
					from: internal.c_HIDE_DETAIL_STATE;
					to: internal.c_SHOW_DETAIL_STATE;
					RotationAnimation {
						direction: RotationAnimation.Clockwise;
						easing.type: Easing.OutExpo;
						duration: 400;
					}
				}
				,
				Transition {
					from: internal.c_SHOW_DETAIL_STATE;
					to: internal.c_HIDE_DETAIL_STATE;
					RotationAnimation {
						direction: RotationAnimation.Clockwise;
						easing.type: Easing.InExpo;
						duration: 400;
					}
				}
			]
			state: internal.detail_state;
			platformIconId: "toolbar-down";
			onClicked: {
				internal.toggle_detail_state();
			}
		}
	}

	Item {
		id: titleBanner;

		property bool loading: false;
		property bool error: false;
		property real theight: 260 + constant.paddingMedium;

		visible: height === theight;

		anchors { left: parent.left; right: parent.right; top: detail_header.bottom; }

		z: 10;

		states: [
			State{
				name: internal.c_SHOW_DETAIL_STATE;
				PropertyChanges {
					target: titleBanner;
					height: theight;
				}
			}
			,
			State{
				name: internal.c_HIDE_DETAIL_STATE;
				PropertyChanges {
					target: titleBanner;
					height: 0;
				}
			}
		]
		transitions: [
			Transition {
				from: internal.c_HIDE_DETAIL_STATE;
				to: internal.c_SHOW_DETAIL_STATE;
				NumberAnimation{
					target: titleBanner;
					property: "height";
					easing.type: Easing.OutExpo;
					duration: 400;
				}
			}
			,
			Transition {
				from: internal.c_SHOW_DETAIL_STATE;
				to: internal.c_HIDE_DETAIL_STATE;
				NumberAnimation{
					target: titleBanner;
					property: "height";
					easing.type: Easing.InExpo;
					duration: 400;
				}
			}
		]
		state: internal.detail_state;
		// Background

		// Preview

		Column{
			anchors.fill: parent;
			spacing: constant.paddingMedium;
			Item{
				anchors.horizontalCenter: parent.horizontalCenter;
				width: parent.width;
				height: 200;
				Image {
					id: preview;
					anchors {
						left: parent.left; top: parent.top;
						margins: constant.paddingMedium;
						bottom: parent.bottom;
					}
					width: 150;
					//height: 200;
					sourceSize: Qt.size(150, 200);
					smooth: true;
					source: internal.detail.cover||"";
				}
				Image {
					anchors.centerIn: preview;
					source: visible ? "image://theme/icon-m-toolbar-gallery" : "";
					visible: preview.status != Image.Ready && !titleBanner.error && !titleBanner.loading;
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
					maximumLineCount: 3;
					text: internal.detail.intro||"";
				}

				Column {
					visible: !titleBanner.error && !titleBanner.loading;
					anchors {
						left: preview.right; leftMargin: constant.paddingLarge;
						bottom: parent.bottom; bottomMargin: constant.paddingSmall;
					}
					spacing: constant.paddingSmall;
					Repeater {
						model: [
							{name: "稿件数量", value: internal.detail.contentSize || "0"},
							{name: "最近更新", value: Qt.formatDate(new Date(internal.detail.lastUpdateTime), "yyyy-MM-dd")},
							{name: "总播放量", value: internal.detail.visit ? internal.detail.visit.views : "0"}
						]
						Text {
							font: constant.subTitleFont;
							color: constant.colorMid;
							text: "<b>" + modelData.name + ": </b>" + modelData.value;
						}
					}
				}
			}

			AbstractItem{
				anchors.horizontalCenter: parent.horizontalCenter;
				width: parent.width;
				height: 60;
				Image {
					id: preview2;
					anchors {
						left: parent.left; top: parent.top;
						leftMargin: constant.paddingMedium;
						rightMargin: constant.paddingMedium;
						bottom: parent.bottom;
					}
					width: 60;
					//height: 240;
					sourceSize: Qt.size(60, 60);
					smooth: true;
					source: internal.detail.owner ? internal.detail.owner.avatar : "";
				}
				Image {
					anchors.centerIn: preview2;
					source: visible ? "image://theme/icon-m-toolbar-gallery" : "";
					visible: preview2.status != Image.Ready && !titleBanner.error && !titleBanner.loading;
				}

				// Infomation
				Column {
					visible: !titleBanner.error;
					anchors {
						left: preview2.right; leftMargin: constant.paddingLarge;
						bottom: parent.bottom; bottomMargin: constant.paddingSmall;
						top: preview2.top;
						right: parent.right; rightMargin: constant.paddingMedium;
					}
					spacing: constant.paddingSmall;
					Text {
						width: parent.width;
						elide: Text.ElideRight;
						font: constant.labelFont;
						color: constant.colorLight;
						text: internal.detail.owner ? "<b>" + internal.detail.owner.name + "</b>" : "";
					}
					Text {
						width: parent.width;
						font: constant.subTitleFont;
						color: constant.colorMid;
						//wrapMode: Text.Wrap;
						elide: Text.ElideRight;
						//maximumLineCount: 2;
						text: internal.detail.owner ? internal.detail.owner.signature : "";
					}

				}
				onClicked: {
					if(internal.detail.owner)
					{
						signalCenter.view_user_detail_by_id(internal.detail.owner["id"]);
					}
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

	Rectangle{
		id: tabRow;
		anchors {
			left: parent.left; top: titleBanner.bottom; right: parent.right;
			topMargin: constant.paddingSmall;
			bottomMargin: constant.paddingSmall;
		}
		height: 60;
		ListView {
			id: group_view;
			anchors {
				fill: parent;
				leftMargin: constant.paddingMedium;
				rightMargin: constant.paddingMedium;
			}
			clip: true;
			orientation: ListView.Horizontal;
			model: ListModel {id: group_model}
			spacing: constant.paddingMedium;
			delegate: Component {
				AbstractItem{
					width: 100;
					height: group_view.height;
					Text{
						anchors.verticalCenter: parent.verticalCenter;
						width: parent.width;
						horizontalAlignment: Text.AlignHCenter;
						elide: Text.ElideRight;
						text: model.groupName;
						color: parent.ListView.isCurrentItem ? "skyblue" : constant.colorLight;
						font.family: constant.titleFont.family;
						font.pixelSize: constant.titleFont.pixelSize;
						font.bold: parent.ListView.isCurrentItem;
					}
					Rectangle{
						anchors.bottom: parent.bottom;
						anchors.left: parent.left;
						anchors.right: parent.right;
						height: 6;
						radius: 4;
						smooth: true;
						color: "red";
						visible: parent.ListView.isCurrentItem;
					}
					MouseArea{
						anchors.fill: parent;
						onClicked: {
							parent.ListView.view.currentIndex = index;
							internal.change_current_tab(model.groupId, index);
						}
					}
				}
			}
		}
	}

	TabGroup {
		id: tabGroup;
		anchors {
			left: parent.left; right: parent.right;
			top: tabRow.bottom; bottom: parent.bottom;
		}
		clip: true;
	}

	Component.onDestruction: {
		internal.destroy_all_tab();
	}
}

