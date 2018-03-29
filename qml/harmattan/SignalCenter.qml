import QtQuick 1.1
import "../js/main.js" as Script

QtObject {
    id: signalCenter;

    signal userChanged;
    signal initialized;

		// begin(11 c)
    property variant videocategories: null;
    property variant infoDialogComp: null;
		property variant streamtype_dialog: null;
		property variant player_loader: null;
		// end(11 c)
    property variant queryDialogComp: null;

    function showMessage(msg){
        if (msg||false){
					// begin(11 c)
					//console.log(msg);
					// end(11 c)
            infoBanner.text = msg;
            infoBanner.show();
        }
    }

		// begin(11 c)
		function create_player_window(aid, type, sid, cid)
		{
			if(!player_loader)
			{
				var player_loader_component = Qt.createComponent("Component/PlayerWindowLoader.qml"); 
				player_loader = player_loader_component.createObject(pageStack);
			}
			if(player_loader.item === null)
			{
				player_loader.sourceComponent = Qt.createComponent("Component/VideoPlayerWindow.qml");
				if (player_loader.status === Loader.Ready){
					var player = player_loader.item;
					player.visualParent = pageStack;
					player.realParent = player_loader;
					player.minSize.connect(function(){
						if(player_loader)
						{
							player_loader.state = player_loader.__MIN;
						}
					});
					player.maxSize.connect(function(){
						if(player_loader)
						{
							player_loader.state = player_loader.__MAX;
						}
					});
					player.norSize.connect(function(){
						if(player_loader)
						{
							player_loader.state = player_loader.__NOR;
						}
					});
					player.exited.connect(function(){
						if(player_loader)
						{
							player_loader.sourceComponent = undefined;
							player_loader.state = player_loader.__MIN;
						}
					});
					player.back.connect(function(){
						if(player_loader)
						{
							if(player_loader.state === player_loader.__NOR)
							{
								player.min();
							}
							else if(player_loader.state === player_loader.__MAX)
							{
								player.nor();
							}
						}
					});
					player.create_player_component();
				}
			}
			if(player_loader && player_loader.item)
			{
				var player = player_loader.item;
				if(player.acId != aid || player.cid != cid || player.sid != sid || player.type != type || !player.loaded)
				{
					player.acId = aid;
					player.type = type;
					player.sid = sid;
					player.cid = cid;
					player.load();
				}
				player.nor();
			}
		}

		function destory_player_window()
		{
			if(player_loader)
			{
				if(player_loader.item)
				{
					player_loader.item.ready_exit();
					player_loader.sourceComponent = undefined;
				}
				player_loader.destroy();
			}
			player_loader = null;
		}

		function create_streamtype_dialog(aid, type, sid, cid)
		{
			if(!streamtype_dialog)
			{
				try
				{
					var streamtype_dialog_component = Qt.createComponent("StreamtypeDialog.qml"); 
					streamtype_dialog = streamtype_dialog_component.createObject(pageStack);
				}
				catch(e)
				{
					console.log(e);
					return;
				}
			}
			if(streamtype_dialog)
			{
				if(streamtype_dialog.acId != aid || streamtype_dialog.cid != cid || streamtype_dialog.sid != sid || streamtype_dialog.type != type || !streamtype_dialog.streams)
				{
					streamtype_dialog.reset();
					streamtype_dialog.acId = aid;
					streamtype_dialog.type = type
					streamtype_dialog.sid = sid
					streamtype_dialog.cid = cid;
					streamtype_dialog.titleText = "正在解析视频地址...";
					streamtype_dialog.load();
				}
				streamtype_dialog.open();
			}
		}

		function destory_streamtype_dialog()
		{
			if(streamtype_dialog)
			{
				streamtype_dialog.destroy();
			}
			streamtype_dialog = null;
		}

    function open_info_dialog(title, message, link_handler, reject_func){
        if (!infoDialogComp){ infoDialogComp = Qt.createComponent("Component/DynamicInfoDialog.qml"); }
        var prop = { titleText: title, message: message.concat("\n")};
        var diag = infoDialogComp.createObject(pageStack.currentPage, prop);
				diag.linkActivated.connect(function(link){
				if(link_handler && typeof(link_handler) === "function")
				{
					var r = link_handler(link);
					if(r !== undefined)
					{
						if(r)
						{
							diag.close();
						}
						else
						{
							diag.reject();
						}
					}
				}
			});
				if(reject_func && typeof(reject_func) === "function")
				{
					diag.rejected.connect(reject_func);
				}
    }

		function view_rank(target)
		{
			pageStack.push(Qt.resolvedUrl("RankingPage.qml"));
		}

		function view_channel(cid, sub_cid)
		{
			if(cid === undefined)
			{
				return;
			}
			var prop = { cid: sub_cid, pid: cid};
			var p = pageStack.push(Qt.resolvedUrl("ClassPage.qml"), prop);
			p.getlist();
		}

		function follow_user_by_id(uid)
		{
			if(uid === undefined)
			{
				return;
			}
			if (Script.checkAuthData()){
				var option = {
					userId: uid.toString(),
					groupId: 0,
					name: "follow"
				};
				function s(obj){
					signalCenter.showMessage("关注成功!");
				}
				function f(err){ 
					signalCenter.showMessage(err);
				}
				Script.follow_user(option, s, f);
			}
		}

		function follow_user_by_name(name)
		{
			if(name === undefined)
			{
				return;
			}
			if (Script.checkAuthData()){
				Script.find_user_by_name(name, function(uid){
					var option = {
						userId: uid.toString(),
						groupId: 0,
						name: "follow"
					};
					function s(obj){
						signalCenter.showMessage("关注成功!");
					}
					function f(err){ 
						signalCenter.showMessage(err);
					}
					Script.follow_user(option, s, f);
				}, function(){
					signalCenter.showMessage("未找到用户: " + name);
				});
			}
		}

		function follow_user(name_or_id)
		{
			if(name_or_id === undefined)
			{
				return;
			}
			/*
			if (acsettings.accessToken === "")
			{
				return;
			}
			*/
			if(typeof("name_or_id") === "number")
			{
				follow_user_by_id(name_or_id);
			}
			else
			{
				follow_user_by_name(name_or_id.toString());
			}
		}

		function chat_with_by_id(uid)
		{
			if(uid === undefined)
			{
				return;
			}
			if (Script.checkAuthData()){
				function s(obj){
					var prop = { username: obj.vdata.username, talkwith: uid.toString(), p2p: acsettings.userId + "-" + uid.toString()};
					pageStack.push(Qt.resolvedUrl("UserPageCom/ConverPage.qml"), prop);
				}
				function f(err){ signalCenter.showMessage("无法获取该用户信息"); }
				Script.getUserDetail(uid, s, f);
			}
		}

		function chat_with_by_name(name)
		{
			if(name === undefined)
			{
				return;
			}
			if (Script.checkAuthData()){
				Script.find_user_by_name(name, function(uid){
					var prop = { username: name, talkwith: uid.toString(), p2p: acsettings.userId + "-" + uid.toString()};
					pageStack.push(Qt.resolvedUrl("UserPageCom/ConverPage.qml"), prop);
				}, function(){
					signalCenter.showMessage("未找到用户: " + name);
				});
			}
		}

		function chat_with(name_or_id)
		{
			if(name_or_id === undefined)
			{
				return;
			}
			/*
			if (acsettings.accessToken === "")
			{
				return;
			}
			*/
			if(typeof("name_or_id") === "number")
			{
				chat_with_by_id(name_or_id);
			}
			else
			{
				chat_with_by_name(name_or_id.toString());
			}
		}

		function view_user_detail_by_id(uid)
		{
			if(uid === undefined)
			{
				return;
			}
			pageStack.push(Qt.resolvedUrl("UserDetailPage.qml"), {uid: uid.toString()});
		}

		function view_user_detail_by_name(name)
		{
			if(name === undefined)
			{
				return;
			}
			Script.find_user_by_name(name, function(uid){
				pageStack.push(Qt.resolvedUrl("UserDetailPage.qml"), {uid: uid.toString()});
			}, function(){
				signalCenter.showMessage("未找到用户: " + name);
			});
		}

		function view_user_detail(name_or_id)
		{
			if(name_or_id === undefined)
			{
				return;
			}
			if(typeof("name_or_id") === "number")
			{
				view_user_detail_by_id(name_or_id);
			}
			else
			{
				view_user_detail_by_name(name_or_id.toString());
			}
		}

		function view_album_detail(aid)
		{
			if(aid === undefined)
			{
				return;
			}
			var id;
			if (typeof(aid) === "number"){
				id = aid;
			} else if (typeof(aid) === "string"){
				var tmp2 = aid.match(/^aa(\d+)$/);
				if(tmp2)
				{
					id = tmp2[1];
				}
				else
				{
					id = aid;
				}
			}
			pageStack.push(Qt.resolvedUrl("AlbumDetailPage.qml"), {albumId: id});
		}

		function view_bangumi_detail(bid)
		{
			if(bid === undefined)
			{
				return;
			}
			pageStack.push(Qt.resolvedUrl("SeriesPageCom/SeriesDetailPage.qml"), {acId: bid});
		}

    function view_link(link, _with){
			if(link === undefined)
			{
				return;
			}
			var w;
			if(!_with)
			{
				w = acsettings.useExternallyBrowser ? "externally" : "internally";
			}
			else
			{
				w = _with;;
			}
			if(w === "internally")
			{
				var page = pageStack.push(Qt.resolvedUrl("SeriesPageCom/WikiPage.qml"), {location_to: link});
				page.load();
			}
			else
			{
				Qt.openUrlExternally(link);
			}
		}

    function viewDetail(vid, type){
        var id;
        if (typeof(vid) === "number"){
            id = vid;
        } else if (typeof(vid) === "string"){
            var tmp = vid.match(/(videoinfo\?id=ac|\b)(\d+)\b/);
						// begin(11 c)
						if (tmp) id = tmp[2];
						else 
						{
							var tmp2 = vid.match(/^ac(\d+)$/);
							if(tmp2)
							{
								id = tmp2[1];
							}
							else
							return;
						}
						// end(11 c)
        }
				if(type && type === "article")
				{
					pageStack.push(Qt.resolvedUrl("VideoDetailCom/ArticlePage.qml"), {"acId": id});
				}
				else // video
				{
					pageStack.push(Qt.resolvedUrl("VideoDetailPage.qml"), {"acId": id});
				}
    }
		// end(11 c)

    function playVideo(acId, type, sid, cid){
        console.log("play video==============\n", acId, type, sid, cid);
				// begin(11 c)
				if(acsettings.usePlatformPlayer)
				{
					create_streamtype_dialog(acId, type, sid, cid);
				}
				else
				{
					var prop = { acId: acId, type: type, sid: sid, cid: cid };
					var p = pageStack.push(Qt.resolvedUrl("VideoPage.qml"), prop, true);
					p.load();
				}
				// end(11 c)
    }

    function login(){
			// begin(11 c)
        pageStack.push(Qt.resolvedUrl("SimpleLoginPage.qml"));
				// end(11 c)
    }

    function createQueryDialog(title, message, acceptText, rejectText, acceptCallback, rejectCallback){
        if (!queryDialogComp){ queryDialogComp = Qt.createComponent("Component/DynamicQueryDialog.qml"); }
        var prop = { titleText: title, message: message.concat("\n"), acceptButtonText: acceptText, rejectButtonText: rejectText };
        var diag = queryDialogComp.createObject(pageStack.currentPage, prop);
        if (acceptCallback) diag.accepted.connect(acceptCallback);
        if (rejectCallback) diag.rejected.connect(rejectCallback);
    }


		// begin(11 a)
		property string c_KARIN_UPDATE: "
		2018-03-23 update:<br/>
		<br/>
		已更新: <br/>
		1，修复所有基本功能。<br/>
		2，增加上一次修复版本的功能，如下: 搜索关键词记录功能， 分类视频页面增加切换频道功能， 评论和私信格式化显示（新增点击@用户进入用户详情）。<br/>
		3，增加搜索文章，番剧，合辑，UP主功能。<br/>
		4，增加分区页面。<br/>
		5，增加设置页面。<br/>
		6，视频播放器播放全部分段。<br/>
		7，查看用户详情， 查看用户投稿视频，文章，合辑。<br/>
		8，收藏和查看合辑，番剧。<br/>
		9，增加合辑详情查看。<br/>
		10，在私信中增加用户被回复提醒列表。<br/>
		11，评论列表中，点击用户头像进入详情，点击评论可回复该条评论。<br/>
		12，视频，文章详情页面点击UP主名字进入UP主详情页面。<br/>
		13，小窗口播放视频。<br/>
		14，查看我的粉丝和关注， 关注用户功能。<br/>
		15，弹幕播放设置。<br/>
		<br/>
		已知问题: <br/>
		1，无法签到。<br/>
		2，优酷，优酷云，腾讯源用内置播放器有网络错误。<br/>
		<br/>
		视频源支持情况：<br/>
		zhuzhan：优酷云，支持。<br/>
		youku：优酷，支持。<br/>
		youku2：优酷，同Youku。<br/>
		sina：新浪，支持，但分辨率过高。<br/>
		qq：腾讯，支持。<br/>
		sohu：搜狐，不支持。<br/>
		letv2：乐视云，不支持。<br/>
		iqiyi：爱奇异，不支持。<br/>
		pptv：PPTV，不支持。<br/>
		tudou：土豆，不支持（没有遇到过）。
		<br/>
		";
		property string c_KARIN_ABOUT: "更新日期：%1<br/>版本：%2<br/>修复：%3<br/>使用安卓手机客户端接口<br/>与我反馈：<a href=\"chat_with_by_name %4\">%4</a><br/>我的<a href=\"at_user_by_name %4\">AC主页</a><br/>百度贴吧：<a href=\"externally_link http://tieba.baidu.com/home/main?un=BEYONDK2000\">BEYONDK2000</a><br/>项目分支主页：<a href=\"externally_link https://github.com/glKarin/acfun_qt\">glKarin/acfun_qt</a><br/><b><font color=\"#9E1B29\">%5 @ <a href=\"to_mail mailto:beyondk2000@163.com\">2015</a></font></b><br/>".arg(acsettings.appRC.r_released).arg(acsettings.appRC.r_version).arg(acsettings.appRC.r_rp).arg(acsettings.appRC.r_ac).arg(acsettings.appRC.r_developer);
		// end(11 a)
}
