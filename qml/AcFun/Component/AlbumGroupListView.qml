import QtQuick 1.1
import com.nokia.symbian 1.1
import "../../js/main.js" as Script

Item {
	id: root;
	property string groupId; 
	property string albumId; 
	property bool loading: false;
	property int count: 0;
	property int nextPage: 1;
	property int pageSize: 20;
	property int pageCount: 0;
	property bool hasNext: false;
	property alias model: view.model;

	// UNUSED
	signal requestGroup(string groupId);
	signal clicked(string contentId, bool article);

	anchors.fill: parent;

	function get_group_list(option){
		loading = true;
		var opt = { 
			"albumId": root.albumId, 
			"groupId": root.groupId,
			"pageSize": root.pageSize,
			model: view.model
		};
		if (root.count === 0||root.nextPage === 1) option = "renew";
		option = option || "renew";
		if (option === "renew"){
			opt.renew = true;
			root.nextPage = 1;
		} else {
			opt.pageNo = root.nextPage;
		}
		function s(obj){
			loading = false;
			root.count = obj.vdata.count === -1 ? 0 : obj.vdata.count;
			root.pageCount = parseInt(root.count / root.pageSize) + (root.count % root.pageSize ? 1 : 0);
			if (root.nextPage >= root.pageCount){
				root.hasNext = false;
			} else {
				root.hasNext = true;
				root.nextPage = obj.vdata.num + 1;
			}
		}
		function f(err){
			loading = false;
			signalCenter.showMessage(err);
		}
		Script.get_album_group_episode(opt, s, f);
	}

	ListView {
		id: view;
		anchors.fill: parent;
		clip: true;
		model: ListModel{
		}
		header: PullToActivate {
			myView: view;
			enabled: !root.loading;
			onRefresh: root.get_group_list();
		}
		footer: FooterItem {
			visible: root.hasNext;
			enabled: !root.loading;
			onClicked: root.get_group_list("next");
		}
		delegate: AbstractItem {
			Text {
				anchors.left: parent.paddingItem.left;
				anchors.verticalCenter: parent.verticalCenter;
				font: constant.labelFont;
				color: constant.colorLight;
				text: (index + 1) + ". " + model.subtitle || "未命名视频";
			}
			onClicked: {
				//root.clicked(model.contentId);
				signalCenter.viewDetail(model.contentId, model.article ? "article" : "video");
			}
		}
	}

	ScrollDecorator { flickableItem: view; }

	BusyIndicator {
		anchors.centerIn: parent;
		z: 2;
		running: true;
        visible: root.loading;
        width: constant.graphicSizeLarge;
        height: constant.graphicSizeLarge;
	}

	Text {
		anchors.centerIn: parent;
		//horizontalAlignment: Text.AlignHCenter;
		elide: Text.ElideRight;
		font: constant.titleFont;
		color: constant.colorLight;
		text: "<b>无内容</b>";
		visible: !root.loading && root.count <= 0;
		z: 1
		clip: true;
	}
}
