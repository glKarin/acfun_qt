import QtQuick 1.1
import com.nokia.symbian 1.1
import ".."
import "../../js/videoSourceLoader.js" as VL

Item {
	id: root;

    objectName: "k_VideoPlayerWindow";
	property string acId;    //ac id;
	property string type;   //source type;
	property string sid;    //source id;
	property string cid;    //comment id;

	property bool loaded: false;
	property alias video_player: playerLoader.item;

	// drag
	property real min_move_x: 0;
	property real max_move_x: visualParent ? visualParent.width - width : 0;
	property real min_move_y: 0;
	property real max_move_y: visualParent ? visualParent.height - height : 0;
	// resize
	property real min_resize_x: x + min_w;
	property real max_resize_x: max_w;
	property real min_resize_y: y + min_h;
	property real max_resize_y: max_h;

	// size
	property real min_w: 180;
	property real max_w: visualParent ? visualParent.width : min_w * 2;
	property real min_h: 150;
	property real max_h: visualParent ? visualParent.height : min_h * 2;

	property bool resize_mode: false;
	property Item visualParent: null;
	property Item realParent: null;

	property variant resize_button: null;
	property variant menu_bar: null;

	property string __HIDE: "hide";
	property string __SHOW: "show";

	signal minSize;
	signal maxSize;
	signal norSize;
	signal exiting;
	signal exited;
	signal back;

	anchors.fill: parent;

	function create_player_component()
	{
		create_resize_button(visualParent);
		resize_button.player = realParent;
		if(realParent)
		{
			resize_button.x = realParent.x + realParent.width - resize_button.width;
			resize_button.y = realParent.y + realParent.height - resize_button.height;
		}

		create_menu_bar(visualParent);
		menu_bar.player = realParent;
	}

	function create_resize_button(p)
	{
		if(resize_button)
		{
			return;
		}
		resize_button = resize_button_comp.createObject(p ? p : root);
	}

	function create_menu_bar(p)
	{
		if(menu_bar)
		{
			return;
		}
		menu_bar = menu_bar_comp.createObject(p ? p : root);
	}

	function reset()
	{
		loaded = false;
		messageModel.clear();
		if(playerLoader.item && playerLoader.item.videoPlayer)
		{
			playerLoader.item.videoPlayer.stop();
		}
	}

	function load(){
		reset();
		VL.loadSource(type, cid, messageModel, createPlayer);
	}

	function ready_exit()
	{
		visible = false;
		if(playerLoader.item)
		{
			if(playerLoader.item.videoPlayer)
			{
				playerLoader.item.videoPlayer.stop();
			}
			playerLoader.sourceComponent = undefined;
		}
		if(resize_button)
		{
			resize_button.visible = false;
			resize_button.destroy();
			resize_button = null;
		}
		if(menu_bar)
		{
			menu_bar.visible = false;
			menu_bar.destroy();
			menu_bar = null;
		}
		resize_mode = false;
	}

	function exit(){
		root.exiting();
		//app.platformStyle.cornersVisible = true;
		ready_exit();
		root.exited();
	}

	function min()
	{
		if(playerLoader.item)
		{
			if(playerLoader.item.videoPlayer)
			{
                if(playerLoader.item.videoPlayer.isPlaying)
                {
                    playerLoader.item.videoPlayer.pause();
                }
			}
		}
		resize_mode = false;
		if(menu_bar)
		{
			menu_bar.state = __HIDE;
		}
		root.minSize();
	}

	function nor()
	{
		resize_mode = false;
		if(menu_bar)
		{
			menu_bar.state = "";
		}
		root.norSize();
	}

	function max()
	{
		resize_mode = false;
		if(menu_bar)
		{
			menu_bar.state = __HIDE;
		}
		root.maxSize();
	}

	function createPlayer(obj){
		if(typeof(obj) !== "object")
		{
			messageModel.append({text: obj});
			return;
		}
		messageModel.append({text: "正在打开播放器..."});
		playerLoader.sourceComponent = Qt.createComponent("../ACPlayer/ACPlayer.qml");
		if (playerLoader.status === Loader.Ready){
			var item = playerLoader.item;
			//item.source = url;
			item.streams = obj;
			item.commentId = cid;
			item.exit_on_back = false;
			item.playStarted.connect(hideMessage);
			item.exit.connect(back);

		} else {
			console.log("Error: player is not ready");
		}
	}

	function hideMessage(){
		loaded = true;
		//exitBtn.visible = false;
		messageModel.clear();
	}

	Rectangle {
		id: bg;
		anchors.fill: parent;
		color: "black";
	}

	Loader{
		id: playerLoader;
		anchors.fill: parent;
	}

	// messages
	Column {
		id: contentCol;
		clip: true;
		anchors {
			left: parent.left; bottom: parent.bottom;
			margins: constant.paddingSmall;
		}
		spacing: constant.paddingSmall;
		Repeater {
			model: ListModel { id: messageModel; }
			Text {
				font.family: constant.labelFont.family;
				font.pixelSize: constant.labelFont.pixelSize * Math.min(root.width / max_h, root.height / max_w);
				color: "white";
				text: model.text;
			}
		}
	}

	Component{
		id: resize_button_comp;
		MovableToolIcon{
			property Item player: null;
			z: 20;
			visible: root.resize_mode;
			enabled: visible;
			width: 45;
            platformIconId: "toolbar-next";
            icon_rotation: 45;
			minimumX: min_resize_x;
			maximumX: max_resize_x - width;
			minimumY: min_resize_y;
			maximumY: max_resize_y - height;
			onXChanged: {
				if(pressed && player)
				{
					player.width = x - player.x + width;
				}
			}
			onYChanged: {
				if(pressed && player)
				{
					player.height = y - player.y + height;
				}
			}
		}
	}

	Component{
		id: menu_bar_comp;
		Rectangle{
			id: menu_bar_root;
			property Item player: null;
			x: player ? player.x : 0;
			y: (player ? player.y : 0) - height;
			z: 20;
			width: player ? player.width : 0;
			height: 60;
			onXChanged: {
				if(resize_button && !resize_button.pressed && player)
				{
					resize_button.x = player.x + player.width - resize_button.width;
				}
			}
			onYChanged: {
				if(resize_button && !resize_button.pressed && player)
				{
					resize_button.y = player.y + player.height - resize_button.height;
				}
			}
			onWidthChanged: {
				if(resize_button && !resize_button.pressed && player)
				{
					resize_button.x = player.x + player.width - resize_button.width;
				}
			}
			onHeightChanged: {
				if(resize_button && !resize_button.pressed && player)
				{
					resize_button.y = player.y + player.height - resize_button.height;
				}
			}


			/*
			 transform: [
				 Scale{
					 id: scl;
					 origin.x: width / 2;
					 origin.y: height / 2;
					 xScale: 1.0;
					 yScale: 1.0;
				 }
			 ]
			 */

			states: [
				State{
					name: root.__HIDE;
					PropertyChanges{
						target: menu_bar_root;
						opacity: 0.0;
					}
				}
			]

			transitions: [
				Transition{
					NumberAnimation{
						target: menu_bar_root;
						property: "opqcity";
						duration: 400;
					}
				}
			]

			/*
			 LayoutMirroring.enabled: true;
			 LayoutMirroring.childrenInherit: true;
			 */
			MouseArea{
				id: mouse_area;
				anchors.fill: parent;
				enabled: player !== null;
				drag.target: player;
				drag.minimumX: root.min_move_x
				drag.maximumX: root.max_move_x;
				drag.minimumY: root.min_move_y + height;
				drag.maximumY: root.max_move_y;
			}
			Flow{
				anchors.fill: parent;
				anchors.margins: constant.paddingSmall;
				z: 1;
				layoutDirection: Qt.RightToLeft;
				spacing: constant.paddingSmall;
				ToolIcon{
					width: 50;
					height: width;
                    platformIconId: "toolbar-back";
                    platformInverted: true;
					onClicked: {
						root.exit();
					}
				}
				ToolIcon{
					width: 50;
					height: width;
					platformIconId: "toolbar-add";
                    platformInverted: true;
					onClicked: {
						root.max();
					}
				}
				ToolIcon{
					width: 50;
					height: width;
                    platformIconId: "toolbar-next";
                    platformInverted: true;
                    rotation: 90;
					onClicked: {
						root.min();
					}
				}
				ToolIcon{
					width: 50;
					height: width;
                    platformInverted: true;
                    platformIconId: root.resize_mode ? "../../gfx/ok.svg" : "../../gfx/edit.svg";
					onClicked: {
						root.resize_mode ^= 1;
					}
				}
			}
		}
	}

	Component.onDestruction: {
		exit();
	}
}
