import QtQuick 1.1
import com.nokia.meego 1.1
import "../Component"
import "../../js/main.js" as Script

MyPage {
	id: page;

	property int talkwith;
	// begin(11 c)
	onP2pChanged: internal.getlist();
	// end(11 c)
	property string username;
	// begin(11 a)
	property string p2p;
	// end(11 a)

	title: "与%1对话中".arg(username);

	tools: ToolBarLayout {
		ToolIcon {
			platformIconId: "toolbar-back";
			onClicked: pageStack.pop();
		}
		ToolIcon {
			platformIconId: "toolbar-refresh";
			onClicked: internal.getlist();
		}
	}

	QtObject {
		id: internal;

		// begin(11 c)
		property int nextPage: 1;
		property int pageSize: 20;
		property int pageCount: 0;
		property int count: 0;
		property bool hasNext: false;
		property bool created: false;

		function getlist(option){
			if(Script.checkAuthData())
			{
				loading = true;
				var opt = { name: "getMails", model: view.model, p2p: p2p()};
				if (nextPage === 1) option = "renew";
				option = option || "renew";
				if (option === "renew"){
					opt.renew = true;
					nextPage = 1;
				} else {
					opt.page = nextPage;
				}
				function s(obj){
					loading = false;
					if(view.model.count > 0 && option  === "renew")
					{
						view.positionViewAtEnd();
						created = true;
						timer.start();
					}
					if (obj.page <= obj.totalPage){
						pageCount = obj.totalPage;
						count = obj.totalCount;
						if (obj.page === obj.totalPage){
							hasNext = false;
						} else {
							hasNext = true;
							nextPage = obj.nextPage;
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

		function send(){
			if(Script.checkAuthData())
			{
				loading = true;
				var opt = { content: textField.text, userId: talkwith };
				function s(){
					loading = false;
					//signalCenter.showMessage("发送成功");
					textField.text = "";
					getlist();
					if(created)
					{
						timer.restart();
					}
				}
				function f(err){ loading = false; signalCenter.showMessage(err); }
				Script.sendPrivteMsg(opt, s, f);
			}
		}

		function p2p()
		{
			var p2p_tmp;
			if(page.p2p.length === 0)
			{
				p2p_tmp = acsettings.userId + "-" + page.talkwith
			}
			else
			{
				p2p_tmp = page.p2p;
			}
			return p2p_tmp;
		}
		function has_unread(if_has, if_not, if_err){
			if(Script.checkAuthData())
			{
				var opt = { name: "getUnreadMailsCount", p2p: internal.p2p()};
				function s(obj){
					if(obj.hasOwnProperty("result"))
					{
						if(obj.result > 0)
						{
							if(if_has && typeof(if_has) === "function")
							{
								if_has();
							}
						}
						else
						{
							if(if_not && typeof(if_not) === "function")
							{
								if_not();
							}
						}
						//console.log("___" + obj.result);
					}
					else
					{
						if(if_err && typeof(if_err) === "function")
						{
							if_err();
						}
					}
				}
				function f(err){
					if(if_err && typeof(if_err) === "function")
					{
						if_err();
					}
				}
				Script.getPrivateMsgs(opt, s, f);
			}
		}

		// end(11 c)
	}

	ViewHeader {
		id: viewHeader;
		title: page.title;
	}

	ListView {
		id: view;
		anchors { fill: parent; topMargin: viewHeader.height; bottomMargin: editArea.height; }
		clip: true;
		model: ListModel {}
		delegate: convDelegate;
		Component {
			id: convDelegate;
			Item {
				id: root;
				anchors.left: model.isMine ? undefined : parent.left;
				anchors.right: model.isMine ? parent.right : undefined;
				implicitWidth: ListView.view.width-constant.graphicSizeSmall;
				implicitHeight: contentCol.height+contentCol.anchors.topMargin*2;
				// begin(11 a)
				MouseArea{
					anchors.fill: parent;
					onPressAndHold: {
						utility.copy_to_clipboard(model.text);
						signalCenter.showMessage("已复制信息到粘贴板");
					}
				}
				// end(11 a)
				BorderImage {
					id: bgImg;
					source: model.isMine ? "../../gfx/msg_out.png" : "../../gfx/msg_in.png";
					anchors { fill: parent; margins: constant.paddingMedium; }
					border { left: 10; top: 10; right: 10; bottom: 15; }
					mirror: true;
				}
				Column {
					id: contentCol;
					anchors {
						left: parent.left; leftMargin: constant.paddingMedium+10;
						right: parent.right; rightMargin: constant.paddingMedium+10;
						top: parent.top; topMargin: constant.paddingLarge*2;
					}
					Text {
						width: parent.width;
						wrapMode: Text.Wrap;
						font: constant.labelFont;
						color: "white";
						// begin(11 c)
						text: Script.format_comment(model.text, "../../gfx/assets", true);
						onLinkActivated:{
							Script.handle_link(link);
						}
						// end(11 c)
					}
					Text {
						width: parent.width;
						horizontalAlignment: model.isMine ? Text.AlignRight : Text.AlignLeft;
						font: constant.subTitleFont;
						color: "white";
						text: utility.easyDate(model.postTime);
					}
				}
			}
		}
		// begin(11 c)
		onFlickEnded: {
			if(internal.hasNext)
			{
				if (atYBeginning){
					if ( contentY < 180 )
					{
						internal.getlist("next");
					}
				}
			}
		}
		ScrollDecorator { flickableItem: parent; }
		// end(11 c)
	}

	Item {
		id: editArea;
		anchors {
			left: parent.left; right: parent.right;
			bottom: parent.bottom;
		}
		height: Math.max(textField.height, sendBtn.height)+constant.paddingMedium;
		TextField {
			id: textField;
			anchors {
				left: parent.left; right: sendBtn.left;
				margins: constant.paddingSmall;
				verticalCenter: parent.verticalCenter;
			}
		}
		Button {
			id: sendBtn;
			anchors { right: parent.right; verticalCenter: parent.verticalCenter; }
			platformStyle: ButtonStyle {
				buttonWidth: buttonHeight * 2;
				inverted: true;
			}
			text: "发送"
			enabled: !loading && textField.text.length > 0;
			onClicked: internal.send();
		}
	}

	// begin(11 a)
	Timer{
		id: timer;
		repeat: true;
		interval: 5000;
		onTriggered: {
			internal.has_unread(internal.getlist);
		}
	}

	Connections {
		target: Qt.application;
		onActiveChanged: {
			if(internal.created)
			{
				if (!Qt.application.active){
					timer.stop();
				}
				else
				{
					timer.restart();
				}
			}
		}
	}

	// end(11 a)
}
