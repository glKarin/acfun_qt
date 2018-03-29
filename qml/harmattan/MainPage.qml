import QtQuick 1.1
import com.nokia.meego 1.1
import "Component"
import "MainPageCom"
import "../js/main.js" as Script

MyPage {
    id: page;

		tools: ToolBarLayout {
			ToolIcon {
				platformIconId: "toolbar-clock";
				onClicked: pageStack.push(Qt.resolvedUrl("SeriesPage.qml"));
			}
			ToolIcon {
				platformIconId: "toolbar-favorite-mark";
				onClicked: pageStack.push(Qt.resolvedUrl("RankingPage.qml"));
			}
			ToolIcon {
				platformIconId: "toolbar-search";
				onClicked: pageStack.push(Qt.resolvedUrl("SearchPage.qml"));
			}
			ToolIcon {
				platformIconId: "toolbar-view-menu";
				onClicked: mainMenu.open();
			}
		}

		Connections {
			target: signalCenter;
			// begin(11 c)
			onInitialized: {
				if(utility.is_update())
				{
					signalCenter.open_info_dialog("更新", signalCenter.c_KARIN_UPDATE, undefined, function(){
						internal.refresh();
					});
				}
				else
				{
					internal.refresh();
				}
			}
			// end(11 c)
		}

		QtObject {
			id: internal;

			function refresh(){
				Script.getVideoCategories();
				// begin(11 c)
				//getHeader();
				//getCategory();
				get_home();
				// end(11 c)
			}

			// begin(11 a)
			function get_home()
			{
				headerView.loading = true;
				headerView.error = false;
				placeHolder.loading = true;
				placeHolder.error = false;
				var opt = {
					"header_model": headerView.model,
					"category_model": homeModel 
				};
				function s(){ 
					headerView.loading = false;
					placeHolder.loading = false; 
				}
				function f(err){
					headerView.loading = false;
					placeHolder.loading = false;
					signalCenter.showMessage(err);
					headerView.error = true;
					placeHolder.error = true;
				}
				Script.make_home(opt, s, f);
			}
			// end(11 a)

			// begin(11 c)
			function enterClass(action_name, href){
				Script.handle_home_action(action_name, href);
			}
			// end(11 c)
		}

		Menu {
			id: mainMenu;
			MenuLayout {
				// begin(11 a)
				MenuItem {
					text: "分区";
					onClicked: pageStack.push(Qt.resolvedUrl("ExtensionPage.qml"));
				}
				MenuItem {
					text: "设置";
					onClicked: pageStack.push(Qt.resolvedUrl("SettingPage.qml"));
				}
			// end(11 a)
				MenuItem {
					text: "关于";
					onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"));
				}
				MenuItem {
					text: "个人中心";
					onClicked: {
						if (Script.checkAuthData()){
							var prop = { uid: acsettings.userId }
							pageStack.push(Qt.resolvedUrl("UserPage.qml"), prop);
						}
					}
				}
				MenuItem {
					text: "里区入口~";
					onClicked: {
						var p = pageStack.push(Qt.resolvedUrl("SeriesPageCom/WikiPage.qml"));
						p.load();
					}
				}
			}
		}

		ViewHeader {
			id: viewHeader;
			Image {
				anchors.centerIn: parent;
				sourceSize.height: parent.height - constant.paddingMedium*2;
				source: "../gfx/image_logo.png";
			}
		}

		Flickable {
			id: view;
			anchors { fill: parent; topMargin: viewHeader.height; }
			contentWidth: view.width;
			contentHeight: contentCol.height;
			Column {
				id: contentCol;
				anchors { left: parent.left; right: parent.right; }
				PullToActivate {
					myView: view;
					enabled: !busyInd.visible;
					onRefresh: internal.refresh();
				}
				HeaderView {
					id: headerView;
					onRefresh: {
						Script.getVideoCategories();
						// begin(11 c)
						internal.get_home();
						// end(11 c)
					}
				}
				Repeater {
					model: ListModel { id: homeModel; }
					HomeRow {}
				}
				Item {
					id: placeHolder;
					property bool loading: false;
					property bool error: false;
					anchors { left: parent.left; right: parent.right; }
					height: view.height - headerView.height;
					visible: homeModel.count === 0;
					Button {
						visible: placeHolder.error;
						anchors.centerIn: parent;
						platformStyle: ButtonStyle { buttonWidth: buttonHeight; }
						iconSource: "image://theme/icon-m-toolbar-refresh";
						onClicked: {
							Script.getVideoCategories();
							// begin(11 c)
							internal.get_home();
							// end(11 c)
						}
					}
				}
			}
		}

		BusyIndicator {
			id: busyInd;
			anchors.centerIn: parent;
			running: true;
			visible: placeHolder.loading || headerView.loading;
			platformStyle: BusyIndicatorStyle {
				size: "large";
			}
		}

		ScrollDecorator { flickableItem: view; }
	}
