import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"
import "../js/main.js" as Script
import "../js/database.js" as Database

MyPage {
	id: page;

    title: "分页";
	tools: ToolBarLayout {
		ToolIcon {
			platformIconId: "toolbar-back";
			onClicked: pageStack.pop();
		}
		ToolIcon {
			platformIconId: "toolbar-refresh";
			onClicked: {
				internal.make_category_list();
				internal.get_channel_operate();
			}
		}
	}

	QtObject {
		id: internal;

		property int c_CATEGORY_CELL_WIDTH: 120;

		property Text textHelper: Text {
			font: constant.subTitleFont;
			text: " ";
			visible: false;
		}

		function get_channel_operate(){
			titleBanner.error = false;
			titleBanner.loading = true;
			page.loading = true;
			var opt = {
				pos: 0,
				model: headerView.model
			};
			function s(obj){
				titleBanner.loading = false;
				page.loading = false;
			}
			function f(err){
				titleBanner.loading = false;
				titleBanner.error = true;
				page.loading = false;
			}
			Script.get_channel_operate(opt, s, f);
		}

	 function make_category_list(force)
	 {
		 var b = false;
		 if(force !== undefined)
		 {
			 b = force;
		 }
		 videoCategoryListView.model.clear();
		 articleCategoryListView.model.clear();
		 if(!b && signalCenter.videocategories)
		 {
			 Script.make_category_model(signalCenter.videocategories, videoCategoryListView.model, articleCategoryListView.model);
		 }
		 else
		 {
			 loading = true;
			 function s()
			 {
				 loading = false;
				 if(!signalCenter.videocategories)
				 {
					 return;
				 }
				 Script.make_category_model(signalCenter.videocategories, videoCategoryListView.model, articleCategoryListView.model);
			 }
			 function f(err)
			 {
				 loading = false;
				 signalCenter.showMessage(err);
			 }
			 Script.get_categories(s, f);
		 }
	 }

 }

 Component {
	 id: categoryDelegate;
	 AbstractItem {
		 id: root;
		 implicitWidth: GridView.view.cellWidth;
		 implicitHeight: implicitWidth;
		 Column {
			 id: contentCol;
			 anchors.fill: parent;
			 Image {
				 id: img;
				 anchors.horizontalCenter: parent.horizontalCenter;
				 width: constant.graphicSizeLarge;
				 height: constant.graphicSizeLarge;
				 sourceSize: Qt.size(width, height);
				 source: model.img;
			 }
			 Item {
				 anchors.horizontalCenter: parent.horizontalCenter;
				 width: parent.width;
				 height: childrenRect.height;
				 Text {
					 anchors.horizontalCenter: parent.horizontalCenter;
					 font: constant.labelFont;
					 color: constant.colorMid;
					 text: model.name;
				 }
			 }
		 }
		 MouseArea{
			 anchors.fill: parent;
			 onClicked: {
				 var prop = { cid: model.channel_id, pid: model.pid};
				 var p = pageStack.push(Qt.resolvedUrl("ClassPage.qml"), prop);
				 p.getlist();
			 }
		 }
	 }
 }

 ViewHeader {
	 id: viewHeader;
	 title: "分区";
 }

 Item {
	 id: titleBanner;

	 property bool loading: false;
	 property bool error: false;

	 anchors { left: parent.left; right: parent.right; top: viewHeader.bottom; }
	 height: 180 + constant.paddingMedium*2;

	 z: 10;

	 // Background

    clip: true;

    PathView {
        id: headerView;
        anchors.fill: parent;
        model: ListModel {}
        preferredHighlightBegin: 0.5;
        preferredHighlightEnd: 0.5;
        path: Path {
            startX: -headerView.width*headerView.count/2+headerView.width/2;
            startY: headerView.height/2;
            PathLine {
                x: headerView.width*headerView.count/2+headerView.width/2;
                y: headerView.height/2;
            }
        }
        delegate: Item {
            implicitWidth: PathView.view.width;
            implicitHeight: PathView.view.height;
						Text {
							z: 2;
							anchors.horizontalCenter: parent.horizontalCenter;
							anchors.top: parent.top;
							anchors.topMargin: 5;
							elide: Text.ElideRight;
							font: constant.titleFont;
							color: constant.colorLight;
							text: model.title;
						}
            Image {
                id: previewImg;
                anchors.fill: parent;
                smooth: true;
                source: model.img;
            }
            Image {
                anchors.centerIn: parent;
                source: previewImg.status === Image.Ready ? "" : "../gfx/photos.svg";
            }
            Rectangle {
                anchors.fill: parent;
                color: "black";
                opacity: mouseArea.pressed ? 0.3 : 0;
            }
            MouseArea {
                id: mouseArea;
                anchors.fill: parent;
								onClicked: {
									if(model.href)
									{
										signalCenter.view_link(model.href);
									}
								}
            }
        }
        Timer {
            running: headerView.visible && headerView.count > 0 && !headerView.moving;
            interval: 3000;
            repeat: true;
            onTriggered: headerView.incrementCurrentIndex();
        }
    }

    Row {
        anchors { right: parent.right; bottom: parent.bottom; margins: constant.paddingMedium; }
        spacing: constant.paddingSmall;
        Repeater {
            model: headerView.count;
            Rectangle {
                width: constant.paddingMedium;
                height: constant.paddingMedium;
                border { width: 1; color: "white"; }
                radius: width /2;
								smooth: true;
                color: index === headerView.currentIndex ? "red" : "transparent";
            }
        }
    }

    Button {
        visible: parent.error;
        anchors.centerIn: parent;
        width: height;
        iconSource: privateStyle.toolBarIconPath("toolbar-refresh");
        onClicked: internal.get_channel_operate();
    }
 }

 ButtonRow {
	 id: tabRow;
	 anchors {
		 left: parent.left; top: titleBanner.bottom; right: parent.right;
	 }
	 TabButton {
		 text: "视频分类";
		 tab: videoCategoryView;
	 }
	 TabButton {
		 text: "文章分类";
		 tab: articleCategoryView;
	 }
 }

 TabGroup {
	 id: tabGroup;
	 anchors {
		 left: parent.left; right: parent.right;
		 top: tabRow.bottom; bottom: parent.bottom;
	 }
	 currentTab: videoCategoryView;
	 clip: true;
	 Item {
		 id: videoCategoryView;
		 anchors.fill: parent;
		 GridView {
			 id: videoCategoryListView;
			 anchors.fill: parent;
			 model: ListModel {}
			 header: PullToActivate {
				 myView: videoCategoryListView;
				 enabled: !loading;
				 onRefresh: internal.make_category_list(true);
			 }
			 delegate: categoryDelegate;
			 clip: true;
			 cellWidth: internal.c_CATEGORY_CELL_WIDTH;
			 cellHeight: cellWidth;
		 }
		 ScrollDecorator { flickableItem: videoCategoryListView; }
	 }
	 Item {
		 id: articleCategoryView;
		 anchors.fill: parent;
		 GridView {
			 id: articleCategoryListView;
			 anchors.fill: parent;
			 model: ListModel {}
			 header: PullToActivate {
				 myView: articleCategoryListView;
				 enabled: !loading;
				 onRefresh: internal.make_category_list(true);
			 }
			 delegate: categoryDelegate;
			 clip: true;
			 cellWidth: internal.c_CATEGORY_CELL_WIDTH;
			 cellHeight: cellWidth;
		 }
		 ScrollDecorator { flickableItem: articleCategoryListView; }
	 }
 }

 Component.onCompleted: {
	 internal.get_channel_operate();
	 internal.make_category_list();
 }
}

