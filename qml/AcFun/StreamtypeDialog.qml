import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"
import "ACPlayer"
import "../js/videoSourceLoader.js" as VL

HarmattanCommonDialog {
	id: root;

	property string acId;    //ac id;
	property string type;   //source type;
	property string sid;    //source id;
	property string cid;    //comment id;
	property variant streams: null;

	function reset()
	{
		msg_timer.stop();
		hideMessage();
		streamtype_tab.init();
		streams = null;
	}

	function load(){
		if(!cid || cid.length === 0)
		{
			console.log("Content ID is null.");
			return;
		}
		busyIndicator.running = true;
		reset();
		VL.loadSource(type, cid, messageModel, createPlayer);
	}

	function createPlayer(obj){
		//item.source = url;
		busyIndicator.running = false;
		msg_timer.restart();
		if(obj)
		{
			if(typeof(obj) === "object")
			{
				streams = obj;
				titleText = obj.title;
				streamtype_tab.init(obj.data, 0, 0);
			}
			else
			{
				messageModel.append({text: obj});
				signalCenter.showMessage(obj);
			}
		}
	}

	function check_type_and_part(type, part)
	{
		if(!streamtype_tab.stream_types)
		{
			return null;
		}
		if(type === undefined || part === undefined)
		{
			return null;
		}
		var r = {
			type_valid: false,
			part_valid: false
		};
		if(type < 0)
		{
			return r;
		}
		if(type > streamtype_tab.stream_types.length - 1)
		{
			return r;
		}
		r.type_valid = true;

		if(part < 0)
		{
			return r;
		}
		if(part > streamtype_tab.stream_types[type].urls.length - 1)
		{
			return r;
		}
		r.part_valid = true;
		return r;
	}

	function play(type, part)
	{
		var r = check_type_and_part(type, part);
		console.log(r, r.type_valid, r.part_valid);
		if(r && r.type_valid && r.part_valid)
		{
			signalCenter.showMessage("正在准备外部播放器打开 %1第%2分段".arg(streamtype_tab.stream_types[type].value).arg(part));
			utility.launchPlayer(streamtype_tab.stream_types[type].urls[part].url);
		}
		else
		{
			signalCenter.showMessage("视频地址数据/流类型/分段无效");
		}
	}

	function hideMessage(){
		if(messageModel.count > 0)
		{
			messageModel.clear();
		}
	}

	__platformModal: true;
	// the content field which contains the message text
	content: Item{
        height: visualParent ? visualParent.height * 0.87 - h_platformStyle.titleBarHeight - h_platformStyle.contentSpacing - 50 : root.parent ? root.parent.height * 0.87 - h_platformStyle.titleBarHeight - h_platformStyle.contentSpacing - 50 : 350;
        width: parent.width;
		StreamtypeItem{
			id: streamtype_tab;
			anchors.fill: parent;
			inverted: true;
			onClicked: {
				root.play(type, part);
			}
		}
	}
	
	Column {
        id: contentCol;
		anchors {
			left: parent.left; bottom: parent.bottom;
			right: parent.right;
			margins: constant.paddingSmall;
		}
		spacing: constant.paddingSmall;
		Repeater {
			model: ListModel { id: messageModel; }
			Text {
				font: constant.labelFont;
				color: "white";
				text: model.text;
			}
		}
	}

	MouseArea{
		enabled: messageModel.count > 0;
		anchors.fill: contentCol;
		onClicked: {
			msg_timer.stop();
			hideMessage();
		}
	}

	Timer{
		id: msg_timer;
		running: false;
		repeat: false;
		interval: 5000;
		onTriggered: {
			stop();
			hideMessage();
		}
	}

	BusyIndicator {
		id: busyIndicator;
		anchors.centerIn: root;
        z: 2;
		running: false;
        visible: running;
        width: constant.graphicSizeLarge;
        height: constant.graphicSizeLarge;
	}
}


