import QtQuick 1.1

Item {
    id: root;

    // 视频源地址
    property url source;
    onSourceChanged: if (videoPlayer) videoPlayer.source = source;
    // 弹幕池ID
    property string commentId;
    // 播放器层接口
    property alias videoPlayer: videoPlayerLoader.item;

    signal playStarted;
    signal exit;

		// begin(11 a)
		property variant streams: null;
		property int played_seconds: 0;
		property int current_type: 0;
		property int current_part: 0;
		property bool exit_on_back: true;

		// start
		onStreamsChanged: {
			if(!streams)
			{
				return;
			}
			var def = streams.data[streams.def];
			messageModel.append({"text": "程序将首选播放清晰度: %1".arg(def.value)});
			controlLayer.set_streams(streams.title, streams.data, streams.def, 0);
			current_type = streams.def;
			current_part = 0;
			controlLayer.has_prev = (current_part > 0);
			controlLayer.has_next = (current_part < def.urls.length - 1)
			played_seconds = 0;
			controlLayer.total_seconds = def.total_msec;
			root.source = def.urls[current_part].url;
		}

		function check_type_or_part(t, p, d)
		{
			if(!streams)
			{
				return null;
			}
			var r = {
				type_valid: false,
				part_valid: false
			};
			var def = d === undefined ? false : d;
			var type = t === undefined ? current_type : t;
			if((t === undefined && def) || t !== undefined)
			{
				if(type < 0)
				{
					return r;
				}
				if(type > streams.data.length - 1)
				{
					return r;
				}
			}
			r.type_valid = true;

			var part = p === undefined ? current_part : p;
			if((p === undefined && def) || p !== undefined)
			{
				if(part < 0)
				{
					return r;
				}
				if(part > streams.data[type].urls.length - 1)
				{
					return r;
				}
			}
			r.part_valid = true;
			return r;
		}

		function get_part_by_milliseconds(t, ms)
		{
			if(!streams)
			{
				return null;
			}
			var r = check_type_or_part(t);
			if(!r || !r.type_valid)
			{
				return null;
			}
			var d = streams.data[current_type];
			if(ms > d.length)
			{
				return null;
			}
			var cms = 0;
			var lms = 0;
			var i;
			for(i = 0; i < d.urls.length; i++)
			{
				cms += d.urls[i].msec;
				if(ms <= cms)
				{
					return({part: i, millisecond: ms - lms});
				}
				lms = cms;
			}
			return null;
		}

		// get total played milliseconds for all part of video.
		function get_milliseconds(t, p)
		{
			if(!streams)
			{
				return;
			}
			var s = 0;
			var i;
			for(i = 0; i < p + 1; i++)
			{
				s += streams.data[t].urls[i].msec;
			}
			return Math.min(s, streams.data[t].total_msec);
		}

		function get_url(t, p)
		{
			var type = t === undefined  ? current_type : t;
			var part = p === undefined  ? current_part : p;
			var url = null;
			if(t === undefined && p === undefined)
			{
				if(videoPlayer)
				{
					url = videoPlayer.source;
				}
				else if(streams)
				{
					url = streams.data[current_type].urls[current_part].url;
				}
			}
			else
			{
				if(streams)
				{
					url = streams.data[type].urls[part].url;
				}
			}
			if(!url || url.toString().length === 0)
			{
				return null;
			}
			else
			{
				return url;
			}
		}

		// for prev button clicked
		function __play_prev()
		{
			if(!streams)
			{
				return;
			}
			if(!videoPlayer)
			{
				return;
			}
			var d = streams.data[current_type];
			if(current_part > 0)
			{
				current_part -= 1;
				played_seconds = get_milliseconds(current_type, current_part - 1);
				videoPlayer.source = d.urls[current_part].url;
				if(!videoPlayer.isPlaying)
				{
					videoPlayer.play();
				}
			}
			controlLayer.set_type_and_part(current_type, current_part);
			controlLayer.has_prev = (current_part > 0);
			controlLayer.has_next = (current_part < streams.data[current_type].urls.length - 1)

			//__dbg();
		}

		// for next button clicked, and video is end of media signal.
		function __play_next()
		{
			if(!streams)
			{
				return;
			}
			if(!videoPlayer)
			{
				return;
			}
			var d = streams.data[current_type];
			if(current_part >= d.urls.length - 1)
			{
				current_part = 0;
				played_seconds = get_milliseconds(current_type, current_part);
				videoPlayer.source = d.urls[current_part].url;
				videoPlayer.pause();
			}
			else
			{
				current_part += 1;
				played_seconds = get_milliseconds(current_type, current_part - 1);
				videoPlayer.source = d.urls[current_part].url;
				if(!videoPlayer.isPlaying)
				{
					videoPlayer.play();
				}
			}
			controlLayer.set_type_and_part(current_type, current_part);
			controlLayer.has_prev = (current_part > 0);
			controlLayer.has_next = (current_part < streams.data[current_type].urls.length - 1)

			//__dbg();
		}

		// for streamtype item request
		function __play(type, part)
		{
			if(!streams)
			{
				return;
			}
			if(!videoPlayer)
			{
				return;
			}
			console.log(type, part);
			var r = check_type_or_part(type, part);
			if(!r || !r.type_valid || !r.part_valid)
			{
				return;
			}
			current_type = type;
			current_part = part;
			controlLayer.has_prev = (current_part > 0);
			controlLayer.has_next = (current_part < streams.data[current_type].urls.length - 1)
			played_seconds = get_milliseconds(current_type, current_part - 1);
			controlLayer.total_seconds = streams.data[current_type].total_msec;
			videoPlayer.source = streams.data[current_type].urls[current_part].url;
			controlLayer.set_type_and_part(current_type, current_part);
			if(!videoPlayer.isPlaying)
			{
				videoPlayer.play();
			}

			//__dbg();
		}

		function __dbg()
		{
			console.log("T -> %1[%2](0 - %3) : %4(0 - %5) -> url(%6)".arg(current_type).arg(streams.data[current_type].type).arg(streams.data.length).arg(current_part).arg(streams.data[current_type].urls.length).arg(streams.data[current_type].urls[current_part].url));
		}

		// end(11 a)

		function __slotLoadStarted(){
			//开始加载视频，同时加载评论
			commentLayerLoader.sourceComponent = commentLayerComp;
		}
		function __handleExit(){
			// begin(11 c)
			if(exit_on_back)
			{
				if (videoPlayer) videoPlayer.stop();
			}
			// end(11 c)
			root.exit();
		}

		anchors.fill: parent;

		// 播放器层加载器
		Loader {
			id: videoPlayerLoader;
			anchors.fill: parent;
		}

		// 延时加载播放器层，防止页面切换时出现卡顿
		Timer {
			id: playerLoadTimer;
			running: true;
			interval: visual.animationDurationPrettyLong;
			onTriggered: {
				stop();
				videoPlayerLoader.sourceComponent =
				Qt.createComponent("VideoLayer.qml");
				if (videoPlayerLoader.status === Loader.Ready){
					videoPlayer.loadStarted.connect(__slotLoadStarted);
					videoPlayer.playbackStarted.connect(playStarted);
					videoPlayer.source = root.source;
					// begin(11 a)
					videoPlayer.playFinished.connect(__play_next);
					// end(11 a)
				}
			}
		}

		// 评论层加载器
		Loader {
			id: commentLayerLoader;
			anchors.fill: parent;
		}
		// 评论层组件
		Component {
			id: commentLayerComp;
			CommentLayer {
				id: commentLayer;
				// begin(11 c)
				timePlayed: played_seconds + videoPlayer.timePlayed;
				// end(11 c)
				commentId: root.commentId;
			}
		}

		// 控制器层
		ControlLayer {
			id: controlLayer;
			autoHide: videoPlayer !== null && videoPlayer.isPlaying;
			timePlayed: videoPlayer ? videoPlayer.timePlayed : 0;
			timeDuration: videoPlayer ? videoPlayer.duration : 0;
			isPlaying: videoPlayer ? videoPlayer.isPlaying : false;
			backFreezed: videoPlayer ? videoPlayer.freezing : false;
			onBackPressed: __handleExit();
			onPausePressed: if(videoPlayer)videoPlayer.pause();
			onPlayPressed: if(videoPlayer)videoPlayer.play();
			// begin(11 a)
			played_seconds: videoPlayer ? root.played_seconds + videoPlayer.timePlayed : 0;
			seekable: videoPlayer ? videoPlayer.seekable : false;
			onSeek: {
				if(videoPlayer)
				{
					videoPlayer.timePlayed = videoPlayer.duration * per;
				}
			}
			onPlay: {
				root.__play(type, part);
			}
			onNext: {
				root.__play_next();
			}
			onPrev: {
				root.__play_prev();
			}
			onPlayWithExternally: {
				var url = get_url();
				if(url)
				{
					signalCenter.showMessage("正在准备外部播放器打开 %1第%2分段".arg(root.streams.data[root.current_type].value).arg(root.current_part));
					utility.launchPlayer(url);
				}
				else
				{
					signalCenter.showMessage("%1第%2分段 地址无效".arg(root.streams.data[root.current_type].value).arg(root.current_part));
				}
			}
			onCopyUrl: {
				var url = get_url();
				if(url)
				{
					utility.copy_to_clipboard(url.toString());
					signalCenter.showMessage("已复制 %1第%2分段 地址到粘贴板".arg(root.streams.data[root.current_type].value).arg(root.current_part));
				}
				else
				{
					signalCenter.showMessage("%1第%2分段 地址无效".arg(root.streams.data[root.current_type].value).arg(root.current_part));
				}
			}
			onSeekForAll: {
				if(videoPlayer && root.streams)
				{
					var ms = root.streams.data[current_type].total_msec * per;
					var r = get_part_by_milliseconds(current_type, ms);
					if(r)
					{
						if(r.part !== current_part)
						{
							__play(current_type, r.part);
						}
						videoPlayer.timePlayed = r.millisecond;
					}
				}
			}
			// end(11 a)
		}
	}
