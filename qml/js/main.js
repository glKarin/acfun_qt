.pragma library

Qt.include("acapi.js");

var signalCenter, acsettings, utility;

function initialize(sc, ac, ut){
    signalCenter = sc;
    acsettings = ac;
    utility = ut;
    signalCenter.initialized();
}

function checkAuthData(){
    var expiresBy = acsettings.expiresBy;
    var token = acsettings.accessToken;
    var userId = acsettings.userId;
    var timeDiff = expiresBy - Date.now()/1000;
    if (timeDiff > 60 && token !== "" && userId !== ""){
        return true;
    } else {
        acsettings.accessToken = "";
        signalCenter.login();
        return false;
    }
}

// begin (2018 unused) end
function getAuthUrl(){
    var url = AcApi.authorize;
    url += "?state=xyz";
    url += "&response_type=token";
    url += "&client_id="+AcApi.clientId;
    url += "&redirect_uri="+AcApi.redirectUri;
    return url;
}

// begin (2018 unused) end
function authUrlChanged(url){
    url = url.toString().replace("#","");
    if (url.indexOf(AcApi.redirectUri) === 0){
        acsettings.expiresBy = utility.urlQueryItemValue(url, "expires_in");
        acsettings.accessToken = utility.urlQueryItemValue(url, "access_token");
        acsettings.userId = utility.urlQueryItemValue(url, "user_id");
        signalCenter.userChanged();
        return true;
    } else {
        return false;
    }
}

// begin (2018 unused) end
function loadVideoModel(model, list){
    if (Array.isArray(list)){
        list.forEach(function(value){
                         var prop = {
                             acId: value.acId,
                             channelId: value.channelId,
                             name: value.name,
                             previewurl: value.previewurl,
                             viewernum: value.viewernum,
                             creatorName: value.creator.name
                         }
                         model.append(prop)
                     });
    }
}

function getVideoCategories(){
	// begin(11 c)
	signalCenter.videocategories = null;
    var req = new WebRequest("GET", AcApi.VIDEO_CATEGORY);
    function f(err){ signalCenter.showMessage(err); }
    function s(obj){ 
			if(check_error(AcApi.VIDEO_CATEGORY, obj, f))
			{
				return;
			}
			signalCenter.videocategories = obj.vdata; 
		}
		// end(11 c)
    req.sendRequest(s, f);
}

// begin (2018 unused) end
function getHomeThumbnails(option, onSuccess, onFailed){
    var req = new WebRequest("GET", AcApi.home_thumbnails);
    function s(obj){
        var model = option.model;
        model.clear();
        obj.forEach(function(value){
                        var prop = {
                            previewurl: value.previewurl,
                            jumpurl: value.jumpurl
                        }
                        model.append(prop);
                    })
        onSuccess();
    }
    req.sendRequest(s, onFailed);
}

// begin (2018 unused) end
function getHomeCategroies(option, onSuccess, onFailed){
    var req = new WebRequest("GET", AcApi.home_categories);
    function s(obj){
        var model = option.model;
        model.clear();
        obj.forEach(function(value){
                        var videos = [];
                        value.videos.forEach(function(video){
                                                 var v = {
                                                     acId: video.acId,
                                                     channelId: video.channelId,
                                                     name: video.name,
                                                     desc: video.desc,
                                                     previewurl: video.previewurl,
                                                     viewernum: video.viewernum,
                                                     commentnum: video.commentnum
                                                 }
                                                 videos.push(v);
                                             })
                        var prop = {
                            id: value.id,
                            name: value.name,
                            videos: videos
                        };
                        model.append(prop);
                    })
        onSuccess();
    }
    req.sendRequest(s, onFailed);
}

function getVideoDetail(acId, onSuccess, onFailed){
	// begin(11 c)
    var req = new WebRequest("GET", AcApi.VIDEO_DETAIL.arg(acId));
		function f(str, err)
		{
			if(err.eid == 110001)
			{
				onFailed(110001)
			}
			else
			{
				onFailed(str);
			}
		}
		function s(obj)
		{
			if(check_error(AcApi.VIDEO_DETAIL, obj, f))
			{
				return;
			}
			if(obj.hasOwnProperty("vdata"))
				onSuccess(obj);
			else
				onFailed("视频详情信息缺失");
		}
    req.sendRequest(s, onFailed);
	// end(11 c)
}

function getVideoComments(option, onSuccess, onFailed){
	// begin(11 c)
    var req = new WebRequest("GET", AcApi.COMMENT);
		var opt = {
			contentId: option.acId,
			version: 4,
			pageSize: option.pageSize
		};
    if (option.cursor)
		{
			opt.pageNo = option.cursor;
		}
		req.setParameters(opt);
    function s(obj){
        var model = option.model;
        if (obj.pageNo === 1||option.renew){
            model.clear();
        }
				if(check_error(AcApi.COMMENT, obj, onFailed))
				{
					return;
				}
				if(obj.data && obj.data.page && Array.isArray(obj.data.page.list))
				{
					obj.data.page.list.forEach(function(value){
						var item = obj.data.page.map["c" + value];
						var prop = {
							content: item ? item.content : "",
							userName: item ? item.username : "",
							userAvatar: item && item.avatar ? item.avatar : "",
							floorindex: item ? item.floor : -1,
							userId: item ? item.userId : undefined,
							quoteId: item ? item.quoteId : 0,
							commentId: item ? item["id"] : undefined
						}
						model.append(prop);
					});
					onSuccess(obj);
				}
				else
					onFailed("评论信息缺失");
    }
		// end(11 c)
    req.sendRequest(s, onFailed);
}

// todo
function getSeries(option, onSuccess, onFailed){
    var req = new WebRequest("GET", AcApi.series);
    var opt = { type: option.type };
    if (option.cursor) opt.cursor = option.cursor;
    req.setParameters(opt);
    function s(obj){
        var model = option.model;
        if (option.renew) model.clear();
        var list = obj.list;
        if(Array.isArray(list)){
            list.forEach(function(value){
                             var prop = {
                                 acId: value.acId,
                                 name: value.name,
                                 previewurl: value.previewurl,
                                 subhead: value.subhead
                             }
                             model.append(prop);
                         })
        }
        onSuccess(obj);
    }
    req.sendRequest(s, onFailed);
}

function getSeriesEpisodes(option, onSuccess, onFailed){
	// begin(11 c)
    var req = new WebRequest("GET", AcApi.BANGUMI_EPISODE);
		var opt = {
			albumId: option.albumId,
			pageSize: option.pageSize
		};
		if (option.pageNo) opt.pageNo = option.pageNo;
    req.setParameters(opt);
    function s(obj){
        var model = option.model;
        if (option.renew) model.clear();
				if(check_error(AcApi.BANGUMI_EPISODE, obj, onFailed))
				{
					return;
				}
				if(obj.vdata && Array.isArray(obj.vdata.list))
				{
					obj.vdata.list.forEach(function(value){
						var prop = {
							subhead: value.title,
							videoId: value.videoId,
							contentId: -1,
							//previewurl: value.urlWeb,
							type: "video",
							urlMobile: value.urlMobile
						}
						model.append(prop);
					});
					onSuccess(obj);
				}
				else
					onFailed("番剧视频信息缺失");
				// end(11 c)
    }
    req.sendRequest(s, onFailed);
}

function getPlaybill(option, onSuccess, onFailed){
	// begin(11 c)
    var req = new WebRequest("GET", AcApi.BANGUMI_LIST);
		var opt = {
			size: option.size,
			num: option.num,
			sorter: option.sorter,
			asc: option.asc,
			isNew: option.isNew === undefined ? "" : "1"
		};
		if(option.isNew !== undefined)
			opt.week = option.week;
		req.setParameters(opt);
		function s(obj){
			var model = option.model;
			if (option.renew) model.clear();
			if(check_error(AcApi.BANGUMI_LIST, obj, onFailed))
			{
				return;
			}
			if(obj.hasOwnProperty("data") && Array.isArray(obj.data.content))
			{
				var weekdays = [ "周日", "周一", "周二", "周三", "周四", "周五", "周六"];
				obj.data.content.forEach(function(value){
					var tags = [];
					value.tags.forEach(function(e){
						tags.push(e);
					});
					tags.sort(function(a, b){
						return a.sort - b.sort;
					});
					var tag_names = [];
					tags.forEach(function(e){
						tag_names.push(e.name);
					});
					var prop = {
						id: value.id,
						title: value.title,
						subhead: tag_names.join(" "),
						intro: value.intro.substring(0,20),
						cover: value.coverImageV || value.coverImageH,
						cover_h: value.coverImageH || value.coverImageV,
						day: weekdays[value.week]
					}
					model.append(prop);
				});
				onSuccess(obj);
			}
			else
				onFailed("番剧列表信息缺失");
		}
		// end(11 c)
    req.sendRequest(s, onFailed);
}

function getHotkeys(model, onSuccess, onFailed){
	// begin(11 c)
    var req = new WebRequest("GET", AcApi.HOT_KEYWORD);
    function s(obj){
        model.clear();
				if(check_error(AcApi.HOT_KEYWORD, obj, onFailed))
				{
					return;
				}
				if(Array.isArray(obj.vdata))
				{
					obj.vdata.forEach(function(value){ 
						model.append({name: value.value}); 
					});
					onSuccess();
				}
				else
					onFailed("热门关键词信息缺失");
				// end(11 c)
    }
    req.sendRequest(s, onFailed);
}

function getSearch(option, onSuccess, onFailed){
	// begin(11 c)
    var req = new WebRequest("GET", AcApi.SEARCH_GENERAL);
    var opt = {
				q: option.term,
				sortField: option.sortField,
				type: 2,
				pageSize: option.pageSize,
				aiCount: 0,
				spCount: 0,
				//greenCount: 0,
				userCount: 0,
        fqChannelId: "63",
    }
    if (option.pageNo) opt.pageNo = option.pageNo;
    req.setParameters(opt);
    function s(obj){
        var model = option.model;
        if (option.renew) model.clear();
				if(check_error(AcApi.SEARCH_GENERAL, obj, onFailed))
				{
					return;
				}
				if(obj.data && obj.data.page && load_video_model_by_search_keyword(model, obj.data.page.list))
					onSuccess(obj);
				else
					onFailed("视频搜索结果信息缺失");
    }
		// end(11 c)
    req.sendRequest(s, onFailed);
}

function getClass(option, onSuccess, onFailed){
	// begin(11 c)
    var req = new WebRequest("GET", AcApi.VIDEO_BY_CATEGORY);
    var opt = {
			"channelId": option["class"],
			day: -1,
			sort: 5,
			pageSize: option.pageSize
		};
    if (option.cursor) opt.pageNo = option.cursor;
    req.setParameters(opt);
    function s(obj){
        var model = option.model;
        if (option.renew) model.clear();
				if(check_error(AcApi.VIDEO_BY_CATEGORY, obj, onFailed))
				{
					return;
				}
        if(obj.vdata && load_video_model_by_category(model, obj.vdata.list))
					onSuccess(obj);
				else
					onFailed("分类视频信息缺失");
    }
    req.sendRequest(s, onFailed);
		// end(11 c)
}

function getSyncComments(option, onSuccess, onFailed){
	// begin(11 c)
    var req = new WebRequest("GET", AcApi.DANMU_V2.arg(option.cid));
    function s(obj){
			if(Array.isArray(obj) && Array.isArray(obj[2]))
			{
        var pool = option.pool;
        var decodeDanmaku = function(value){
            var c = value.c;
            var clist = c.split(",");
            var mode = Number(clist[2]);
            if (mode === 1){
                var prop = new Object();
                prop.time = Number(clist[0]);
                prop.mode = mode;
                prop.color = Number(clist[1]);
                prop.fontSize = Number(clist[3]);
                prop.text = value.m;
                pool.push(prop);
            }
        }
        var sortPool = function(a, b){
            return a.time - b.time;
        }
        for (var i in obj){
            obj[i].forEach(decodeDanmaku);
        }
        pool.sort(sortPool);
        onSuccess();
			}
			else
				onFailed("弹幕信息缺失");
    }
		// end(11 c)
    req.sendRequest(s, onFailed);
}

function getUserDetail(uid, onSuccess, onFailed){
	// begin(11 c)
    var req = new WebRequest("GET", AcApi.USER_PROFILE);
    var opt = {userId: uid}
    req.setParameters(opt);
		function s(obj)
		{
			if(check_error(AcApi.USER_PROFILE, obj, onFailed))
			{
				return;
			}
			if(obj.hasOwnProperty("vdata"))
				onSuccess(obj);
			else
				onFailed("用户详情信息缺失");
		}
    req.sendRequest(s, onFailed);
		// end(11 c)
}

function addToFav(acId, onSuccess, onFailed){
	// begin(11 c)
    var req = new WebRequest("POST", AcApi.FAVORITE.arg(acId));
		var opt = {
			access_token: acsettings.accessToken
		};
		function s(obj)
		{
			if(check_error(AcApi.FAVORITE, obj, onFailed))
			{
				return;
			}
			//if(obj.hasOwnProperty("vdata"))
				onSuccess();
			//else
				//onFailed("稿件是否收藏信息缺失");
		}
    req.sendRequest(s, onFailed);
		// end(11 c)
}

function getFavVideos(option, onSuccess, onFailed){
	// begin(11 c)
    var req = new WebRequest("GET", AcApi.MY_FAVORITE);
    var opt = {
			type: option.type,
				pageSize: option.pageSize,
			access_token: acsettings.accessToken
    }
    if (option.pageNo) opt.pageNo = option.pageNo;
    req.setParameters(opt);
    function s(obj){
        var model = option.model;
        if (option.renew) model.clear();
				if(check_error(AcApi.MY_FAVORITE, obj, onFailed))
				{
					return;
				}
				if(obj.vdata && load_video_model_by_user_contribute(model, obj.vdata.list))
					onSuccess(obj);
				else
					onFailed("收藏稿件信息缺失");
		}
		req.sendRequest(s, onFailed);
		// end(11 c)
}

function getUserVideos(option, onSuccess, onFailed){
	// begin(11 c)
    var req = new WebRequest("GET", AcApi.USER_UPLOAD);
    var opt = {
				userId: option.userId,
				sort: option.sort,
				type: option.type,
				pageSize: option.pageSize,
				"status": option["status"]
    }
    if (option.pageNo) opt.pageNo = option.pageNo;
    req.setParameters(opt);
    function s(obj){
        var model = option.model;
        if (option.renew) model.clear();
				if(check_error(AcApi.USER_UPLOAD, obj, onFailed))
				{
					return;
				}
				if(obj.vdata && load_video_model_by_user_contribute(model, obj.vdata.list))
					onSuccess(obj);
				else
					onFailed("用户稿件信息缺失");
		}
		req.sendRequest(s, onFailed);
		// end(11 c)
}

function getPrivateMsgs(option, onSuccess, onFailed){
	// begin(11 c)
    var req = new WebRequest("GET", AcApi.USER_MESSAGE);
    var opt = { access_token: acsettings.accessToken, name: option.name};
    if (option.p2p) opt.p2p = option.p2p;
    if (option.page) opt.page = option.page;
    req.setParameters(opt);
    function s(obj){
			if(check_error(AcApi.USER_MESSAGE, obj, onFailed))
			{
				return;
			}
			var model = option.model, list = obj.mailList;
			if (option.renew) model.clear();
        if (Array.isArray(list)){
            var decode;
            if (option.p2p){
                decode = function(mail){
                            var mailObj = JSON.parse(mail);
                            if (!mailObj) return;
                            var isMine = acsettings.userId === mailObj.fromuId.toString();
                            var prop = {
                                isMine: isMine,
                                text: mailObj.text,
                                postTime: new Date(Number(mailObj.postTime))
                            }
														if(model.count === 0)
															model.append(prop);
														else
															model.insert(0, prop);
                        }
            } else {
                decode = function(mail){
                            var mailObj = JSON.parse(mail);
                            if (!mailObj) return;
                            var mailGroupId = mailObj.mailGroupId
                            var prop = {
                                mailGroupId: mailGroupId,
                                fromuId: mailObj.fromuId,
                                fromusername: mailObj.fromusername,
                                postTime: new Date(Number(mailObj.postTime)),
                                user_img: mailObj.user_img,
                                lastMessage: mailObj.lastMessage,
                                p2p: mailObj.p2p,
                                unread: false
                            }
                            var isUnread = function(mgid){
                                return mailGroupId === mgid;
                            }
                            prop.unread = obj.unReadList.some(isUnread);
                            model.append(prop);
                        }
            }
            list.forEach(decode);
        }
        onSuccess(obj);
    }
    req.sendRequest(s, onFailed);
		// end(11 c)
}

function sendPrivteMsg(option, onSuccess, onFailed){
	// begin(11 c)
    var req = new WebRequest("POST", AcApi.USER_MESSAGE);
    var opt = {
				name: "newMail",
        access_token: acsettings.accessToken,
        content: option.content,
        userId: option.userId
    }
		function s(obj)
		{
			if(check_error(AcApi.USER_MESSAGE, obj, onFailed))
			{
				return;
			}
			if(obj.success)
			{
				onSuccess();
			}
			else
				onFailed("发送消息信息缺失");
		}
    req.setParameters(opt);
    req.sendRequest(s, onFailed);
		// end(11 c)
}

function sendComment(option, onSuccess, onFailed){
	// begin(11 c)
    var req = new WebRequest("POST", AcApi.POST_COMMENT);
    var opt = {
			userId: acsettings.userId,
			contentId: option.acId,
			access_token: acsettings.accessToken,
			source: "mobile",
					/*
						 quoteId: "",
					captcha: "验证码",
						*/
        text: option.content
    }
		if(option.quoteId)
			opt.quoteId = option.quoteId;
    req.setParameters(opt);
		function s(obj){
			if(check_error(AcApi.POST_COMMENT, obj, onFailed))
			{
				return;
			}
			if(obj.success)
			{
				onSuccess();
			}
			else
				onFailed("发送评论信息缺失");
		}
    req.sendRequest(s, onFailed);
		// end(11 c)
}

// begin(11 a)
function get_type_by_channel_id(cid)
{
	if(!cid)
		return "video";
	if(!signalCenter.videocategories)
	{
		var h = [63, 184, 110, 73, 74, 75, 164].some(function(value){return value == cid;});
		if(h)
			return "article";
		else
			return "video";
	}
	else
	{
		var check_contains = function(id, arr)
		{
			if(!id || !arr || !Array.isArray(arr))
			{
				return false;
			}
			var i;
			for(i = 0; i < arr.length; i++)
			{
				if(id == arr[i].id)
				{
					return true;
				}
				if(arr.children && Array.isArray(arr.children))
				{
					if(check_contains(id, arr.children))
					{
						return true;
					}
				}
			}
			return false;
		}

		var i;
		if(signalCenter.videocategories.article)
		{
			if(check_contains(cid, signalCenter.videocategories.article))
			{
					return "article";
			}
			return "video";
		}
		else if(signalCenter.videocategories.video)
		{
			if(check_contains(cid, signalCenter.videocategories.video))
			{
					return "video";
			}
			return "article";
		}
		return "video";
	}
}

function make_home(option, onSuccess, onFailed){
	var req = new WebRequest("GET", AcApi.VIDEO_CATEGORY_HOT_AND_NEW);
	req.setParameters({channelId: 0});
	function s(obj){
		option.header_model.clear();
		option.category_model.clear();
		if(check_error(AcApi.VIDEO_CATEGORY_HOT_AND_NEW, obj, onFailed))
		{
			return;
		}
		// header
		var model = option.header_model;
		if(Array.isArray(obj.vdata) && obj.vdata.length > 0)
		{
			var thumbnails = obj.vdata[0].bodyContents;
			thumbnails.forEach(function(value){
				var prop = {
					title: value.title,
					previewurl: value.img[0],
					jumpurl: value.href,
					action_name: value.action,
				}
				model.append(prop);
			});

			// body
			model = option.category_model;
			var categories = obj.vdata;
			categories.forEach(function(value, index){
				if(index === 0)
					return;
				var videos = [];
				value.bodyContents.forEach(function(video){
					var v = {
						acId: video.href,
						channelId: video.channel ? video.channel.id : undefined,
						name: video.title,
						desc: "",
						previewurl: video.img[0],
						viewernum: video.visit ? video.visit.views : 0,
						action_name: video.action,
						commentnum: video.visit ? video.visit.comments : 0,
					}
					videos.push(v);
				})
				var prop = {
					id: value.bottomText ? value.bottomText.href : undefined, // NOT value.id
					action_name: value.bottomText ? value.bottomText.action : undefined, // NOT value.id
					name: value.title,
					videos: videos
				};
				model.append(prop);
			});
			onSuccess();
		}
		else
			onFailed("主页信息缺失");
	}
	req.sendRequest(s, onFailed);
}

function load_video_model_by_user_contribute(model, list)
{
	if(!model || !list)
		return false;

	if (Array.isArray(list)){
		list.forEach(function(value){
			var prop = {
				acId: value["id"],
				channelId: value.channelId,
				name: value.title,
				previewurl: value.cover,
				desc: value.description,
				releaseDate: value.releaseDate,
					//state: value.state
				type: get_type_by_channel_id(value.channelId),

					// for fav video
				creatorName: value.user ? value.user.username : "",
				viewernum: value.views
			}
			model.append(prop)
		});
		return true;
	}
	return false;
}

function load_bangumi_model_by_search_keyword(model, list){
	if(!model || !list)
		return false;

	var weekdays = [ "周日", "周一", "周二", "周三", "周四", "周五", "周六"];
	if (Array.isArray(list)){
		list.forEach(function(value){
			var prop = {
				"id": value["id"],
				title: value.title,
				subhead: value.tagNames ? value.tagNames.join(" ") : "最近更新：" + value.lastVideoName,
				intro: value.intro/*.substring(0,20)*/,
				cover: value.cover,
				lastUpdateTime: value.lastUpdateTime,
				day: weekdays[value.days]
			}
			model.append(prop)
		});
		return true;
	}
	return false;
}

function load_album_model_by_user(model, list)
{
	if(!model || !list)
		return false;

	if (Array.isArray(list)){
		list.forEach(function(value){
			var d = new Date(value.lastUpdateTime);
			var prop = {
				albumId: value["id"],
				channelId: value.channelId,
				title: value.title,
				cover: value.cover,
				intro: value.intro,
				//subhead: "最后更新：%1-%2-%3".arg(d.getFullYear()).arg(d.getMonth() + 1).arg(d.getDate()),
				contentSize: value.contentSize,
				creatorName: value.user ? value.user.username : "",
				lastUpdateTime: value.lastUpdateTime
			}
			model.append(prop)
		});
		return true;
	}
	return false;
}

function load_video_model_by_search_keyword(model, list){
	if(!model || !list)
		return false;

	if (Array.isArray(list)){
		list.forEach(function(value){
			var prop = {
				acId: value.contentId, // format is ^ac\[1-9]{7}$
				channelId: value.channelId,
				name: value.title,
				previewurl: value.titleImg,
				viewernum: value.views,
				creatorName: value.username,
				type: get_type_by_channel_id(value.channelId)
			}
			model.append(prop)
		});
		return true;
	}
	return false;
}

function get_categories(suc, fail){
	signalCenter.videocategories = null;
	var req = new WebRequest("GET", AcApi.VIDEO_CATEGORY);
	function s(obj){ 
		if(check_error(AcApi.VIDEO_CATEGORY, obj, fail))
		{
			return;
		}
		if(obj.hasOwnProperty("vdata"))
		{
			signalCenter.videocategories = obj.vdata; 
			suc();
		}
		else
			fail("频道分类信息缺失");
	}
	req.sendRequest(s, fail);
}

function make_category_model(vdata, video_model, article_model)
{
	if(!vdata || (!video_model && !article_model))
		return;
	var get_data = function(value)
	{
		var item = {
			channel_id: value.id,
			img: value.img,
			name: value.name,
			pid: value.pid,
			children: []
		};
		if(Array.isArray(value.children))
		{
			var i;
			for(i = 0; i < value.children.length; i++)
			{
				var p = get_data(value.children[i]);
				item.children.push(p);
			}
		}
		return item;
	}

	if(Array.isArray(vdata.article) && article_model)
	{
		vdata.article.forEach(function(e){
			var item = get_data(e);
			if(!item.img)
				item.img = Qt.resolvedUrl("../gfx/article.jpg");
			article_model.append(item);
		});
	}
	if(Array.isArray(vdata.video) && video_model)
	{
		vdata.video.forEach(function(e){
			video_model.append(get_data(e));
		});
	}
}

function make_one_category_model(vdata, model)
{
	if(!vdata || !model)
		return;
	var get_data = function(value)
	{
		var item = {
			channel_id: value.id,
			value: value.name,
			pid: value.pid,
			children: []
		};
		item.children.push({
			channel_id: value.id,
			pid: value.id, // TEST
			value: "推荐",
			children: []
		});
		if(Array.isArray(value.children))
		{
			var i;
			for(i = 0; i < value.children.length; i++)
			{
				var p = get_data(value.children[i]);
				item.children.push(p);
			}
		}
		return item;
	}

	if(Array.isArray(vdata.video))
	{
		vdata.video.forEach(function(e){
			model.append(get_data(e));
		});
	}
	if(Array.isArray(vdata.article))
	{
		var aitem = {
			channel_id: 63,
			value: "文章",
			pid: 0,
			children: []
		}
		vdata.article.forEach(function(e){
			aitem.children.push(get_data(e));
		});
		model.append(aitem);
	}
}

function load_video_model_by_category(model, list){
	if(!model || !list)
		return false;
	if (Array.isArray(list)){
		list.forEach(function(value){
			var prop = {
				acId: value.href,
				channelId: value.channel.id,
				name: value.title,
				previewurl: value.img[0] || "",
				viewernum: value.visit.views,
				creatorName: value.user.name,
				type: get_type_by_channel_id(value.channel.id)
			}
			model.append(prop)
		});
		return true;
	}
	return false;
}

function get_article_detail(acid, suc, fail)
{
	var req = new WebRequest("GET", AcApi.ARTICLE_DETAIL.arg(acid));
	function s(obj)
	{
		if(check_error(AcApi.ARTICLE_DETAIL, obj, fail))
		{
			return;
		}
		if(obj.hasOwnProperty("vdata"))
			suc(obj);
		else
			fail("文章详情信息缺失");
	}
	req.sendRequest(s, fail);
}

function make_ranking_model(vdata, model)
{
	if(!vdata || !model)
		return;
	model.append({
		channel_id: 0,
		name: "香蕉榜",
		is_banana: true});
	model.append({
		channel_id: 0,
		name: "综合",
		is_banana: false});
	if(vdata.video && Array.isArray(vdata.video) && model)
	{
		vdata.video.forEach(function(e){
			model.append({
				channel_id: e.id,
				name: e.name,
				is_banana: false});
		});
	}
	model.append({
		channel_id: 63,
		name: "文章",
		is_banana: false});
}

function get_rank(option, onSuccess, onFailed){
	// begin(11 c)
	var req = new WebRequest("GET", option.isoriginal ? AcApi.BANANA : AcApi.VIDEO_BY_CATEGORY);
	var opt = {
		day: option.day
	};
	if(!option.isoriginal)
	{
		opt.channelId = option["class"];
		opt.sort = 1;
		opt.pageSize = option.pageSize;
		if (option.cursor) opt.pageNo = option.cursor;
	}
	req.setParameters(opt);
	function s(obj){
		var model = option.model;
		if (option.renew) model.clear();
		if(check_error(option.isoriginal ? AcApi.BANANA : AcApi.VIDEO_BY_CATEGORY, obj, onFailed))
		{
			return;
		}
		if(load_video_model_by_category(model, option.isoriginal ? obj.vdata : obj.vdata.list))
			onSuccess(obj);
		else
			onFailed("排行信息缺失");
	}
	req.sendRequest(s, onFailed);
	// end(11 c)
}

function check_error(api, obj, f)
{
	if(!api || !obj)
		return false;
	var e = get_response_error(api, obj);
	if(e)
	{
		//console.log(e.etype, e.eid, e.edesc);
		var str = "%1 -> {%2 - %3}".arg(e.etype).arg(e.eid).arg(e.edesc);
		//console.log(str);
		if(f)
		{
			f(str, e);
		}
		return true;
	}
	return false;
}

function search_keyword(option, onSuccess, onFailed){
	var req = new WebRequest("GET", AcApi.SEARCH_KEYWORD);
	req.setParameters(option);
	function s(obj){
		if(check_error(AcApi.SEARCH_KEYWORD, obj, onFailed))
		{
			return;
		}
		onSuccess(obj);
	}
	req.sendRequest(s, onFailed);
}

function getSearch_bangumi(option, onSuccess, onFailed){
	var req = new WebRequest("GET", AcApi.SEARCH_BANGUMI);
	var opt = {
		q: option.q,
		sort: option.sort,
		pageSize: option.pageSize,
		"status": 3
	}
	if (option.pageNo) opt.pageNo = option.pageNo;
	req.setParameters(opt);
	function s(obj){
		var model = option.model;
		if (option.renew) model.clear();
		if(check_error(AcApi.SEARCH_BANGUMI, obj, onFailed))
		{
			return;
		}
		if(obj.data && obj.data.page && load_bangumi_model_by_search_keyword(model, obj.data.page.list))
			onSuccess(obj);
		else
			onFailed("搜索番剧信息缺失");
	}
	req.sendRequest(s, onFailed);
}

function getSearch_album(option, onSuccess, onFailed){
	var req = new WebRequest("GET", AcApi.SEARCH_GENERAL);
	var opt = {
		q: option.q,
		sortField: option.sortField,
		type: 1,
		pageSize: option.pageSize,
			//aiCount: 0,
			//spCount: 0,
			//greenCount: 0,
		userCount: 0,
	}
	if (option.pageNo) opt.pageNo = option.pageNo;
	req.setParameters(opt);
	function s(obj){
		var model = option.model;
		if (option.renew) model.clear();
		if(check_error(AcApi.SEARCH_GENERAL, obj, onFailed))
		{
			return;
		}
		if(obj.data && obj.data.page && Array.isArray(obj.data.page.list))
		{
			obj.data.page.list.forEach(function(value){
				var prop = {
					albumId: value.contentId, // format is ^aa\[1-9]{7}$
					channelId: value.channelId,
					title: value.title,
					cover: value.titleImg,
					intro: value.description,
					subhead: value.tags.join(" "),
					contentSize: value.contentSize,
					creatorName: value.username
				}
				model.append(prop)
			});
			onSuccess(obj);
		}
		else
			onFailed("搜索番剧信息缺失");
	}
	req.sendRequest(s, onFailed);
}

function getSearch_user(option, onSuccess, onFailed){
	var req = new WebRequest("GET", AcApi.SEARCH_GENERAL);
	var opt = {
		q: option.q,
		sortField: option.sortField,
		type: 2,
		pageSize: option.pageSize,
			//aiCount: 0,
			//spCount: 0,
			//greenCount: 0,
		userCount: 20
	}
	if (option.pageNo) opt.pageNo = option.pageNo;
	req.setParameters(opt);
	function s(obj){
		var model = option.model;
		if (option.renew) model.clear();
		if(check_error(AcApi.SEARCH_GENERAL, obj, onFailed))
		{
			return;
		}
		if(obj.data && obj.data.page && Array.isArray(obj.data.page.user))
		{
			obj.data.page.user.forEach(function(value){
				var prop = {
					userId: value.userId,
					avatar: value.avatar,
					username: value.username,
					signature: value.signature || "",
					followedCount: value.followedCount,
					contributes: value.contributes
				}
				model.append(prop)
			});
			onSuccess(obj);
		}
		else
			onFailed("搜索用户信息缺失");
	}
	req.sendRequest(s, onFailed);
}

function getSearch_article(option, onSuccess, onFailed){
	var req = new WebRequest("GET", AcApi.SEARCH_GENERAL);
	var opt = {
		q: option.q,
		sortField: option.sortField,
		type: 2,
		pageSize: option.pageSize,
		aiCount: 0,
		spCount: 0,
			//greenCount: 0,
		userCount: 0,
		channelIds: "63",
	}
	if (option.pageNo) opt.pageNo = option.pageNo;
	req.setParameters(opt);
	function s(obj){
		var model = option.model;
		if (option.renew) model.clear();
		if(check_error(AcApi.SEARCH_GENERAL, obj, onFailed))
		{
			return;
		}
		if(obj.data && obj.data.page && load_video_model_by_search_keyword(model, obj.data.page.list))
			onSuccess(obj);
		else
			onFailed("搜索文章信息缺失");
	}
	req.sendRequest(s, onFailed);
}

function get_bangumi_detail(option, onSuccess, onFailed){
	var req = new WebRequest("GET", AcApi.BANGUMI_DETAIL.arg(option.acId));
	function s(obj){
		if(check_error(AcApi.BANGUMI_DETAIL, obj, onFailed))
		{
			return;
		}
		console.log("Bangimi source -> " + obj.vdata.videoGroupContent[0].list[0].sourceType); // NEED_TO_COM
		onSuccess(obj);
	}
	req.sendRequest(s, onFailed);
}

function get_channel_operate(option, onSuccess, onFailed){
	var req = new WebRequest("GET", AcApi.AC_EVENT);
	var opt = {
		pos: option.pos
	};
	req.setParameters(opt);
	function s(obj){
		var model = option.model;
		model.clear();
		if(check_error(AcApi.AC_EVENT, obj, onFailed))
		{
			return;
		}
		if(obj.vdata && Array.isArray(obj.vdata.operateList))
		{
			obj.vdata.operateList.forEach(function(value){
				var prop = {
					action_name: value.action,
					title: value.title,
					href: value.href,
					img: value.img
				}
				model.append(prop);
			});
			onSuccess(obj);
		}
		else
			onFailed("近期活动信息缺失");
	}
	req.sendRequest(s, onFailed);
}

function get_content_id_by_danmaku_id(option, onSuccess, onFailed){
	var req = new WebRequest("GET", AcApi.VIDEO_SOURCE);
	req.setParameters(option);
	function s(obj){
		if(obj)
		{
			getVideoDetail(obj.contentId.toString(), onSuccess, onFailed);
		}
		else
			onFailed("未能获取contentId");
	}
	req.sendRequest(s, onFailed);
}

function sign_in(option, onSuccess, onFailed)
{
	var req = new WebRequest("POST", AcApi.USER_LOGIN);
	req.setParameters(option);
	function s(obj){
		if(check_error(AcApi.USER_LOGIN, obj, onFailed))
		{
			return;
		}
		if(obj.vdata)
		{
			acsettings.expiresBy = obj.vdata.expiration;
			acsettings.accessToken = obj.vdata.token;
			acsettings.userId = obj.vdata.info.userid;
			signalCenter.userChanged();
			utility.sign_in();
			onSuccess(obj);
			//return true;
		} else {
			onFailed("登录信息缺失");
			//return false;
		}
	}
	req.sendRequest(s, onFailed);
}

function get_user_follow(option, onSuccess, onFailed){
	var req = new WebRequest("GET", AcApi.MY_FOLLOW);
	var opt = {
		name: option.name,
		pageSize: option.pageSize,
		access_token: acsettings.accessToken,
	}
	if (option.pageNo) opt.pageNo = option.pageNo;
	if(option.groupId)
		opt.groupId = option.groupId;
	req.setParameters(opt);
	function s(obj){
		var model = option.model;
		if (option.renew) model.clear();
		if(check_error(AcApi.MY_FOLLOW, obj, onFailed))
		{
			return;
		}
		if(Array.isArray(obj.friendList))
		{
			obj.friendList.forEach(function(e){
				var item = {
					userId: e.userId,
					username: e.userName,
					avatar: e.userImg,
					signature: e.signature,
					followedCount: e.followedCount,
					contributes: e.userContributeCount
				};
				model.append(item)
			});
			onSuccess(obj);
		}
		else
			onFailed("用户关注/粉丝信息缺失");
	}
	req.sendRequest(s, onFailed);
}

function get_user_album(option, onSuccess, onFailed){
	var req = new WebRequest("GET", AcApi.USER_ALBUM);
	var opt = {
		userId: option.userId,
		sort: option.sort,
		pageSize: option.pageSize,
	}
	if (option.pageNo) opt.pageNo = option.pageNo;
	req.setParameters(opt);
	function s(obj){
		var model = option.model;
		if (option.renew) model.clear();
		if(check_error(AcApi.USER_ALBUM, obj, onFailed))
		{
			return;
		}
		if (obj.vdata && load_album_model_by_user(model, obj.vdata.list))
			onSuccess(obj);
		else
			onFailed("用户合辑信息缺失");
	}
	req.sendRequest(s, onFailed);
}

function get_album_detail(opt, onSuccess, onFailed){
    var req = new WebRequest("GET", AcApi.ALBUM_DETAIL.arg(opt.albumId));
		function s(obj)
		{
			if(check_error(AcApi.ALBUM_DETAIL, obj, onFailed))
			{
				return;
			}
			if(obj.hasOwnProperty("vdata"))
			{
				if(opt.model && Array.isArray(obj.vdata.groups))
				{
					obj.vdata.groups.forEach(function(e){
						var item = {
							groupId: e.groupId,
							groupName: e.groupName,
						};
						opt.model.append(item);
					});
				}
				else
					onFailed("合辑分组信息缺失");
				onSuccess(obj);
			}
			else
				onFailed("合辑详情信息缺失");
		}
    req.sendRequest(s, onFailed);
}

function get_album_group_episode(option, onSuccess, onFailed){
	var req = new WebRequest("GET", AcApi.ALBUM_EPISODE.arg(option.albumId));
	var opt = {
		groupId: option.groupId,
		pageSize: option.pageSize,
	}
	if (option.pageNo) opt.pageNo = option.pageNo;
	req.setParameters(opt);
	function s(obj){
		var model = option.model;
		if (option.renew) model.clear();
		if(check_error(AcApi.ALBUM_EPISODE, obj, onFailed))
		{
			return;
		}
		if(obj.vdata && Array.isArray(obj.vdata.list))
		{
			obj.vdata.list.forEach(function(value){
				var prop = {
					subtitle: value.subtitle,
					contentId: value.contentId,
					article: value.article
				}
				model.append(prop)
			});
			onSuccess(obj);
		}
		else
			onFailed("合辑视频信息缺失");
	}
	req.sendRequest(s, onFailed);
}

function favorite_bangumi(aId, onSuccess, onFailed, action_name){
	if(action_name === "add")
	{
    var req = new WebRequest("POST", AcApi.FAVORITE_BANGUMI.arg(aId));
		var opt = {
			access_token: acsettings.accessToken
		};
		function s(obj)
		{
			if(check_error(AcApi.FAVORITE_BANGUMI, obj, onFailed))
			{
				return;
			}
			//if(obj.hasOwnProperty("vdata"))
				onSuccess();
			//else
				//onFailed("稿件是否收藏信息缺失");
		}
    req.sendRequest(s, onFailed);
	}
	else
	{
    var req = new WebRequest("GET", AcApi.FAVORITE_BANGUMI.arg(aId));
		var opt = {
			access_token: acsettings.accessToken
		};
		function s(obj)
		{
			if(check_error(AcApi.FAVORITE_BANGUMI, obj, onFailed))
			{
				return;
			}
			if(obj.hasOwnProperty("vdata"))
				onSuccess(obj);
			else
				onFailed("番剧是否收藏信息缺失");
		}
    req.sendRequest(s, onFailed);
	}
}

function favorite_album(aId, onSuccess, onFailed, action_name){
	if(action_name === "add")
	{
    var req = new WebRequest("POST", AcApi.FAVORITE_ALBUM.arg(aId));
		var opt = {
			access_token: acsettings.accessToken
		};
		function s(obj)
		{
			if(check_error(AcApi.FAVORITE_ALBUM, obj, onFailed))
			{
				return;
			}
			//if(obj.hasOwnProperty("vdata"))
				onSuccess();
			//else
				//onFailed("稿件是否收藏信息缺失");
		}
    req.sendRequest(s, onFailed);
	}
	else
	{
    var req = new WebRequest("GET", AcApi.FAVORITE_ALBUM.arg(aId));
		var opt = {
			access_token: acsettings.accessToken
		};
		function s(obj)
		{
			if(check_error(AcApi.FAVORITE_ALBUM, obj, onFailed))
			{
				return;
			}
			if(obj.hasOwnProperty("vdata"))
				onSuccess(obj);
			else
				onFailed("合辑是否收藏信息缺失");
		}
    req.sendRequest(s, onFailed);
	}
}

function follow_user(option, onSuccess, onFailed){
	var info;
	var prop;
	var type;
	if(option.name === "follow")
	{
		info = "关注用户信息缺失";
		prop = "followedCount";
		type = "POST";
	}
	else if(option.name === "unfollow")
	{
		info = "取消关注用户信息缺失";
		prop = "followedCount";
		type = "POST";
	}
	else
	{
		info = "是否关注用户信息缺失";
		prop = "isFollowing";
		type = "GET";
	}
	var req = new WebRequest(type, AcApi.FOLLOW_USER);
	var opt = option;
	opt.access_token = acsettings.accessToken;
	req.setParameters(opt);
	function s(obj)
	{
		if(check_error(AcApi.FOLLOW_USER, obj, onFailed))
		{
			return;
		}
		if(obj.hasOwnProperty(prop))
			onSuccess(obj);
		else
			onFailed(info);
	}
	req.sendRequest(s, onFailed);
}

function favorite(acId, onSuccess, onFailed){
    var req = new WebRequest("GET", AcApi.FAVORITE.arg(acId));
		var opt = {
			access_token: acsettings.accessToken
		};
		function s(obj)
		{
			if(check_error(AcApi.FAVORITE, obj, onFailed))
			{
				return;
			}
			if(obj.hasOwnProperty("vdata"))
				onSuccess(obj);
			else
				onFailed("稿件是否收藏信息缺失");
		}
    req.sendRequest(s, onFailed);
}

function get_fav_album(option, onSuccess, onFailed){
    var req = new WebRequest("GET", AcApi.MY_FAVORITE_ALBUM);
    var opt = {
				pageSize: option.pageSize,
			access_token: acsettings.accessToken
    }
    if (option.pageNo) opt.pageNo = option.pageNo;
    req.setParameters(opt);
    function s(obj){
        var model = option.model;
        if (option.renew) model.clear();
				if(check_error(AcApi.MY_FAVORITE_ALBUM, obj, onFailed))
				{
					return;
				}
				if(obj.vdata && load_album_model_by_user(model, obj.vdata.list))
					onSuccess(obj);
				else
					onFailed("收藏合辑信息缺失");
		}
		req.sendRequest(s, onFailed);
}

function get_fav_bangumi(option, onSuccess, onFailed){
    var req = new WebRequest("GET", AcApi.MY_FAVORITE_BANGUMI);
    var opt = {
				pageSize: option.pageSize,
			access_token: acsettings.accessToken
    }
    if (option.pageNo) opt.pageNo = option.pageNo;
    req.setParameters(opt);
    function s(obj){
        var model = option.model;
        if (option.renew) model.clear();
				if(check_error(AcApi.MY_FAVORITE_BANGUMI, obj, onFailed))
				{
					return;
				}
				if(obj.vdata && load_bangumi_model_by_search_keyword(model, obj.vdata.list))
					onSuccess(obj);
				else
					onFailed("收藏番剧信息缺失");
		}
		req.sendRequest(s, onFailed);
}

function get_user_alert(option, onSuccess, onFailed){
	var req = new WebRequest("GET", AcApi.MY_ALERT);
	var opt = {
		pageSize: option.pageSize,
		userId: acsettings.userId,
		access_token: acsettings.accessToken
	}
	if (option.pageNo) opt.pageNo = option.pageNo;
	req.setParameters(opt);
	function s(obj){
		var model = option.model;
		if (option.renew) model.clear();
		if(check_error(AcApi.MY_ALERT, obj, onFailed))
		{
			return;
		}
		if(obj.data && obj.data.page)
		{
			if(Array.isArray(obj.data.page.commentList) && Array.isArray(obj.data.page.quoteCommentList))
			{
				var i;
				for(i = 0; i < obj.data.page.commentList.length; i++)
				{
					var value = obj.data.page.commentList[i];
					var quote_value = null;
					var j;
					for(j = 0; j < obj.data.page.quoteCommentList.length; j++)
					{
						var q_value = obj.data.page.quoteCommentList[j];
						if(value.quoteId === q_value["id"])
						{
							quote_value = q_value;
							break;
						}
					}

					var prop = {
						title: value.title,
						avatar: value.avatar,
						content: value.content,
						floor: value.floor,
						time: value.time,
						type: value.isArticle ? "article" : "video",
						username: value.username,
						contentId: value.contentId,
						userId: value.userId,

						quote_floor: quote_value ? quote_value.floor : 0,
						quote_username: quote_value ? quote_value.username : "",
						quote_content: quote_value ? quote_value.content : "",
					}
					model.append(prop)
				}
				onSuccess(obj);
			}
			else
				onFailed("用户提醒信息缺失");
		}
		else
			onFailed("用户提醒信息缺失");
	}
	req.sendRequest(s, onFailed);
}

function delete_msg_group(option, onSuccess, onFailed){
    var req = new WebRequest("POST", AcApi.USER_MESSAGE);
    var opt = {
				name: "deleteGroup",
        access_token: acsettings.accessToken,
				p2p: option.p2p,
				mailGroupId: option.mailGroupId
    }
		function s(obj)
		{
			if(check_error(AcApi.USER_MESSAGE, obj, onFailed))
			{
				return;
			}
			if(obj.success)
			{
				onSuccess();
			}
			else
				onFailed("删除会话信息缺失");
		}
    req.setParameters(opt);
    req.sendRequest(s, onFailed);
}


function is_signin(){
    var expiresBy = acsettings.expiresBy;
    var token = acsettings.accessToken;
    var userId = acsettings.userId;
    var timeDiff = expiresBy - Date.now()/1000;
    if (timeDiff > 60 && token !== "" && userId !== ""){
        return true;
    } else {
        return false;
    }
}

function record_sign_in(option, onSuccess, onFailed)
{
	var req = new WebRequest(option === undefined || !option.hasOwnProperty("channel") ? "POST" : "GET", AcApi.USER_SIGN);
	var opt = {
		access_token: acsettings.accessToken
	};
	if(option && option.channel)
		opt.channel = option.channel;
	req.setParameters(opt);
	function s(obj){
		if(check_error(AcApi.USER_SIGN, obj, onFailed))
		{
			return;
		}
		if(obj.hasOwnProperty("data"))
		{
			onSuccess(obj);
		} else {
			onFailed("签到信息缺失");
		}
	}
	req.sendRequest(s, onFailed);
}

function find_user_by_name(name, suc, fail)
{
    var req = new WebRequest("GET", AcApi.FIND_USER_BY_NAME);
    var opt = {
			userName: name
		}
    req.setParameters(opt);
		function s(obj)
		{
			//console.log(obj);
			var json = obj.match(/(var UPUser = {.*})/);
			if(json && json.length === 2)
			{
				eval(json[1]);
				if(UPUser && UPUser.userId)
					suc(UPUser.userId);
				else
					fail();
			}
			else
				fail();
		}
    req.sendRequest(s, fail);
}

function user_unread(uid, onSuccess, onFailed){
    var req = new WebRequest("GET", AcApi.MY_UNREAD);
    var opt = {
			userId: uid,
			access_token: acsettings.accessToken
		}
    req.setParameters(opt);
		function s(obj)
		{
			if(check_error(AcApi.MY_UNREAD, obj, onFailed))
			{
				return;
			}
			onSuccess(obj);
		}
    req.sendRequest(s, onFailed);
}

function format_comment(comment, path, mark){
	String.prototype.replaceAll = function(s1,s2){
		return this.replace(new RegExp(s1, "g"), s2);
	}
	// [emot=ac, 01/]
	var r = comment.replace(/\[emot=([a-zA-Z0-9]+?),(\d+?)\/]/g, function($1, $2, $3){//[emot=**,41/] ac ais brd td
		var ext;
		switch($2)
		{
			case "ac":
			case "ac2":
			case "ais":
			case "blizzard":
				ext = "png";
				break;
			case "ac3":
			case "brd":
			case "dog":
			case "td":
			case "tsj":
				ext = "gif";
				break;
			default:
				return $1;
		}
		return "<img src=\"%1/%2/%3.%4\" height=\"50\"/>".arg(path).arg($2).arg($3).arg(ext);
	})
	// [at]user[/at]
	.replace(/\[at](.*)\[\/at]/g, function($1, $2){
		return("<a href=\"%1%2\">@%3</a>".arg(mark ? "at_user_by_name " : "").arg($2).arg($2));
	})
	// [img=图片][/img]
	.replace(/\[img=图片](.*)\[\/img]/g, function($1, $2){
		return("<img src=\"%1\"/>".arg($2));
	})
	// [s]xxx[/s]
	.replaceAll("\\[s]", "<s>")
		.replaceAll("\\[/s]", "</s>")
		// [i]xxx[/i]
		.replaceAll("\\[i]", "<i>")
		.replaceAll("\\[/i]", "</i>")
		// [b]xxx[/b]
		.replaceAll("\\[b]", "<b>")
		.replaceAll("\\[/b]", "</b>")
		// [u]xxx[/u]
		.replaceAll("\\[u]", "<u>")
		.replaceAll("\\[/u]", "</u>")
		// [size=14px]xxx[/size]
		.replace(/\[size="?(\d+?)(px)?"?]/g, function($1, $2, $3){
			return("<span style=\"font-size: %1px\">".arg($2));
		})
	.replaceAll("\\[/size]", "</span>")
		// [color= ffffff]xxx[/color]
		// [color=#ffffff]xxx[/color]
		.replace(/\[color="?\s*#?([0-9a-fA-F]+?)"?]/g, function($1, $2){
			return("<span style=\"color: #%1\">".arg($2));
		})
	.replaceAll("\\[/color]", "</span>")
		// [font=AAA, BBB]xxx[/font]
		.replace(/\[font="?([^"]+?)"?]/g, function($1, $2){
				return("<span style=\"font-family: %1\">".arg($2));
				})
	.replaceAll("\\[/font]", "</span>")
		// [ac=1111111]ac1111111[/ac]
		.replace(/\[ac="?(ac)?(\d+?)"?]/g, function($1, $2, $3){
			return("<a href=\"%1%2\">".arg(mark ? "ac_id " : "").arg($3));
		})
	.replaceAll("\\[/ac]", "</a>")
		//[url]www.xxx.com[/url]
		.replace(/\[url](.*)\[\/url]/g, function($1, $2){
			return("<a href=\"%1%2\">%3</a>".arg(mark ? "internal_link " : "").arg($2).arg($2));
		})
	//[url=www.xxx.com]xxx[/url]
	.replace(/\[url="?([^"]+?)"?]/g, function($1, $2){
			return("<a href=\"%1%2\">".arg(mark ? "internal_link " : "").arg($2));
			})
	.replaceAll("\\[/url]", "</a>")
		//[email]xxx[/email]
		.replace(/\[email](.*)\[\/email]/g, function($1, $2){
			return("<a href=\"%1mailto:%2\">%3</a>".arg(mark ? "to_mail " : "").arg($2).arg($2));
		});
	/*
		 .replaceAll("\\[", "<")
		 .replaceAll("]",  ">");
		 */
	//console.log("\n" + comment + "\n" + "--->" + r);
	return r;
}

function handle_link(url)
{
	if(!url)
		return "link_invalid";
	var link = url.toString();
//	console.log(link);
	var i = link.indexOf(" ");
	if(i === -1)
		return "format_invalid";
	var action_name = link.substring(0, i);
	var target = link.substring(i + 1);
	if(action_name === "ac_id")
		signalCenter.viewDetail(target);
	else if(action_name === "at_user_by_id")
		signalCenter.view_user_detail(parseInt(target));
	else if(action_name === "at_user_by_name")
		signalCenter.view_user_detail(target);
	else if(action_name === "to_mail")
		Qt.openUrlExternally(target);
	else if(action_name === "share")
		utility.share("", target);
	else if(action_name === "internal_link")
		signalCenter.view_link(target);
	else if(action_name === "chat_with_by_id")
		signalCenter.chat_with(parseInt(target));
	else if(action_name === "chat_with_by_name")
		signalCenter.chat_with(target);
	else if(action_name === "command")
		utility.exec(target);
	else
		Qt.openUrlExternally(target);
	//console.log(action_name + " -> " + target);
	return action_name;
}

function handle_home_action(action_name, data)
{
	//console.log(action_name + "_" + data);
	if(action_name === 1)
		signalCenter.viewDetail(data, "video");
	else if(action_name === 10)
		signalCenter.viewDetail(data, "article");
	else if(action_name === 2)
		signalCenter.view_bangumi_detail(data);
	else if(action_name === 11)
		signalCenter.view_rank(data);
	else if(action_name === 6)
		signalCenter.view_channel(data, 0);
	else
		signalCenter.showMessage("未被支持的操作 -> " + action_name);
}
// end(11 a)
