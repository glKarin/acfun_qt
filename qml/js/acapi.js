.pragma library

var AcApi = {
	// begin(11 c)
	/*
	 * 以下为安卓客户端5.0.0版本desktop官网版本
	 * 所有请求需要加入请求头 deviceType=1
	 * 部分请求需要额外加入请求头 appVersion=安卓的客户端版本号 market=安卓客户端获取途径（例如已知的portal：desktop官网下载，m360：360软件下载，acfunh5：手机端官网下载 等）
	 * 安卓客户端user-agent格式：acvideo core/安卓客户端版本号(设备品牌;设备型号;安卓版本号)
	 * 如诺基亚7 4G下：acvideo core(Nokia;TA-1041;7.1.1)
	 * 如网易MUMU模拟器下：acvideo core(Android;Mumu;4.4.4)
	 * */

	/* ************** 主页 ************** */
	// 获取视频和文章大分类和子类
	// 对应安卓首页的分区tab
	VIDEO_CATEGORY: "http://apipc.app.acfun.cn/v3/channels/allChannels",
	// 对于安卓主页分区tab下的近期活动
	AC_EVENT: "http://apipc.app.acfun.cn/v3/channels/channelOperate", // ?pos=0
		// 香蕉榜
	BANANA: "http://apipc.app.acfun.cn/v3/regions/banana", // ?&day=1/7
		/* ********************************* */

		/* ************* 分类 ************** */
		// 分类中热门和最新内容
		// 对于安卓分区进入频道后的页面
	VIDEO_CATEGORY_HOT_AND_NEW: "http://apipc.app.acfun.cn/v3/regions", // ?channelId=分类ID（0为主页）"
		// 获取分类视频
		// 对应安卓文章分类内容
	VIDEO_BY_CATEGORY: "http://apipc.app.acfun.cn/v3/regions/search", // ?channelId=分类ID&day=-1&sort=5&pageNo=1&pageSize=10
		/* ********************************* */

		/* ************* 搜索 ************** */
		// 搜索关键词建议
		SUGGEST_KEYWORD: " http://search.app.acfun.cn/suggest", // ?q=WORD
		// 搜索视频，文章，用户，合辑
	SEARCH_GENERAL: "http://search.app.acfun.cn/search", //q=ketword&sortField=score&pageNo=1&pageSize=20&type=1,2
		// 搜索番剧
	SEARCH_BANGUMI: "http://search.app.acfun.cn/search/album", //q=ketword&sort=0&pageNo=1&pageSize=20&status=3
		// 热门搜索关键词
	HOT_KEYWORD: "http://apipc.app.acfun.cn/v2/hotwords",
		// 搜索关键词
		// 对应安卓搜索结果页面
	SEARCH_KEYWORD: "http://search.app.acfun.cn/mobileSearch", // ?q=关键字&sortField=score&aiCount=番剧&spCount=合辑&greenCount=文章&listCount=20&userCount=up主&fqChannelId=63&pageNo=1&pageSize=20
		// 名字搜索用户 // http://www.acfun.cn/u/xxxxx.aspx
		FIND_USER_BY_NAME: "http://www.acfun.cn/member/findUser.aspx", // ?userName=
		/* ********************************* */

		/* ************* 用户 ************** */
		// 用户登录 POST
	USER_LOGIN: "http://account.app.acfun.cn/api/account/signin/normal", // ?username=USERNAME&password=PWD //&cid=
		// 用户信息
	USER_PROFILE: "http://apipc.app.acfun.cn/v2/user/content/profile", //?userId=ID
		// 关注或粉丝
		// 关注：name=getFollowingList, 粉丝：name=getFollowedList
	MY_FOLLOW: "http://mobile.app.acfun.cn/api/friend.aspx", //?name=getFollowingList&pageNo=1&pageSize=10&groupId=-1&access_token=TOKEN
		//?name=getFollowedList&pageNo=1&pageSize=10&access_token=TOKEN
		// 我的收藏：视频/文章
		// 视频：type=0, 文章：type=1
	MY_FAVORITE: "http://apipc.app.acfun.cn/v2/favorites/content", //?type=0-video/1-article&access_token=TOKEN&pageSize=20&pageNo=1
		// 我的收藏：合辑
	MY_FAVORITE_ALBUM: "http://apipc.app.acfun.cn/v2/favorites/album", //?access_token=TOKEN&pageSize=20&pageNo=1
		// 我的收藏：番剧
	MY_FAVORITE_BANGUMI: "http://apipc.app.acfun.cn/v3/favorites/bangumi", //?access_token=TOKEN&pageSize=10&pageNo=1
		// 收藏稿件
		// 是否收藏：GET * 收藏：POST, 取消收藏：DELETE
	FAVORITE: "http://apipc.app.acfun.cn/v2/favorites/content/%1", //4193362?access_token=TOKEN
		// 签到领香蕉
	USER_SIGN: "http://webapi.app.acfun.cn/record/actions/signin", //?(GET: channel=1&)access_token=TOKEN
		// 用户稿件
		// 也是对应安卓视频详情下的相关内容列表
	USER_UPLOAD: "http://apipc.app.acfun.cn/v2/user/content", //?userId=ID&type=0&sort=1&pageNo=1&pageSize=20&status=2 sort=1-最新投稿(rel) 2-最多播放 3-最多香蕉
		// 用户合辑
	USER_ALBUM: "http://apipc.app.acfun.cn/v2/user/album", //?userId=ID&sort=5&pageNo=1&pageSize=20 sort=5-最近更新 4-最多收藏
		// 发送评论 POST
	POST_COMMENT: "http://mobile.app.acfun.cn/comment.aspx", // userId=   contentId=   text=内容 (以上为必须)   source="mobile"   quoteId="引用评论的ID"   access_token=TOKEN   captcha=""验证码
		// 提醒列表
	MY_ALERT: "http://mobile.app.acfun.cn/comment/at/list", // ?pageNo=1&pageSize=10&userId=USERID&access_token=TOKEN
		// 私信
		// 私信列表: GET // ?name=getGroups&access_token=TOKEN&page=1
		// 发送私信: POST // ?name=newMail POST content=   userId=   access_token=
		// 获取消息: GET // ?name=getMails&access_token=TOKEN&p2p=SENDER_USERID-RECIVER_USERID
		// 未读消息数量: GET // ?name=getUnreadMailsCount&access_token=TOKEN&p2p=SENDER_USERID-RECIVER_USERID
	USER_MESSAGE: "http://mobile.app.acfun.cn/api/mail.aspx", 
		// 是否有未读消息
	MY_UNREAD: "http://mobile.app.acfun.cn/member/unRead.aspx", // ?uid=USERID&access_token=TOKEN
		// 收藏合辑
		// 是否收藏：GET * 收藏：POST, 取消收藏：DELETE
		FAVORITE_ALBUM: "http://apipc.app.acfun.cn/v2/favorites/album/%1", //5001477?access_token=TOKEN
		// 收藏番剧
		// 是否收藏：GET * 收藏：POST, 取消收藏：DELETE
		FAVORITE_BANGUMI: "http://apipc.app.acfun.cn/v3/favorites/bangumi/%1", //5021417?access_token=TOKEN
		// 粉 POST name=follow&groupId=0
		// 取粉 POST name=unfollow
		// 是否粉 GET name=checkFollow
		FOLLOW_USER: "http://mobile.app.acfun.cn/api/friend.aspx", // access_token=TOKEN&userId=USER_ID
		/* ********************************* */

		/* ************* 地址 ************** */
		// 视频地址
	VIDEO_SOURCE: "http://www.acfun.cn/video/getVideo.aspx", // ?id=ID
			// 弹幕地址
			DANMU_V2: "http://danmu.aixifan.com/V2/%1",
			DANMU_V4: "http://danmu.aixifan.com/V4/%1/%2/%3", // danmaku_id, 0, count
		/* ********************************* */

		/* ************* 详情 ************** */
		// 文章详情
	ARTICLE_DETAIL: "http://apipc.app.acfun.cn/v2/articles/%1", // 1-视频ID //?from=recommand/videoDetail_recommend_视频ID
		// 视频详情
	VIDEO_DETAIL: "http://apipc.app.acfun.cn/v2/videos/%1", // 1-视频ID //?from=recommand/videoDetail_recommend_视频ID
		// 评论
	COMMENT: "http://mobile.app.acfun.cn/comment/content/list", // ?version=4&contentId=ID&pageNo=1&pageSize=50
		/* ********************************* */

		/* ************* 番剧 ************** */
		// HTML www.acfun.cn
		// 番剧列表
		BANGUMI_LIST: "http://www.acfun.cn/album/abm/bangumis/list", // ?size=42&num=1&sorter=1最近更新6放送日期2创建日期&asc=0倒序/1正序&isNew=1本季新番&week=0-6星期日星期六
		// 番剧详情
	BANGUMI_DETAIL: "http://apipc.app.acfun.cn/v3/bangumis/%1",
		// 番剧视频
	BANGUMI_EPISODE: "http://apipc.app.acfun.cn/v3/bangumis/video", // ?albumId=ID&pageNo=1&pageSize=20
		// 用户香蕉数
		USER_BANANA: "http://mobile.app.acfun.cn/banana/getBananaCount.aspx", //?access_token=TOKEN
		/* ********************************* */

		/* ************* 合辑 ************** */
		// 合辑详情
	ALBUM_DETAIL: "http://apipc.app.acfun.cn/v3/album/%1",
		// 合辑视频
	ALBUM_EPISODE: "http://apipc.app.acfun.cn/v3/album/%1/contents", // ?groupID=ID&pageNo=1&pageSize=20
		/* ********************************* */

		// end(11 c)

	clientId:           "hf2QkYjrqcT3ndr9",
	authorize:          "https://ssl.acfun.tv/oauth2/authorize.aspx",
	redirectUri:        "https://ssl.acfun.tv/authSuccess.aspx",

	videocategories:    "http://api.acfun.tv:1069/videocategories",
	home_thumbnails:    "http://api.acfun.tv:1069/home/thumbnails",
	home_categories:    "http://api.acfun.tv:1069/home/categories",
	videos:             "http://api.acfun.tv:1069/videos",
	series:             "http://api.acfun.tv:1069/series",
	videos_playbill:    "http://api.acfun.tv:1069/videos/playbill",
	hotkeys:            "http://api.acfun.tv:1069/hotkeys",
	videos_search:      "http://api.acfun.tv:1069/videos/search",
	danmaku:            "http://danmaku1.acfun.tv",
	users:              "http://api.acfun.tv:1069/users",

	video_comment:      "http://static.comment.acfun.tv"
}

// begin(11 a)
function get_response_error(api, obj)
{
	if(!api || !obj)
		return null;
	if(api === AcApi.USER_LOGIN)
	{
		if(obj.hasOwnProperty("success"))
		{
			if(!obj.success)
			{
				return({etype: "account", eid: obj["status"], edesc: obj.info || "<no_info>"});
			}
		}
		else if(obj.hasOwnProperty("errorid"))
		{
			if(obj.errorid !== 0)
				return({etype: "acapi_v2", eid: obj.errorid, edesc: obj.errordesc || "<no_error_desc>"});
		}
	}
	else if(api.indexOf("http://mobile.app.acfun.cn") !== -1)
	{
		if(obj.hasOwnProperty("success"))
		{
			if(!obj.success) // v3 error
			{
				if(obj.hasOwnProperty("msg"))
					return({etype: "acapi_mobile", eid: obj["status"], edesc: obj.msg || "<no_msg>"});
				else if(obj.hasOwnProperty("info"))
					return({etype: "acapi_mobile", eid: obj["status"], edesc: obj.info || "<no_info>"});
				else if(obj.hasOwnProperty("result"))
					return({etype: "acapi_mobile", eid: obj["status"] || "", edesc: obj.result || "<no_result>"});
				else
					return({etype: "acapi_mobile", eid: obj["status"], edesc: "<unknow_error>"});
			}
		}
	}
	else if(api.indexOf("http://webapi.app.acfun.cn") !== -1)
	{
		if(obj.hasOwnProperty("code"))
		{
			if(obj.code !== 200)
				return({etype: "acapi_web", eid: obj.code, edesc: obj.message || "<no_message>"});
		}
	}
	else if(api.indexOf("http://www.acfun.cn") !== -1)
	{
		if(obj.hasOwnProperty("code"))
		{
			if(obj.code.length > 0)
				return({etype: "acapi_www", eid: obj.code, edesc: obj.message || "<no_message>"});
		}
	}
	// v2 v3 error
	else
	{
		if(obj.hasOwnProperty("errorid"))
		{
			if(obj.errorid !== 0)
				return({etype: "acapi_v2", eid: obj.errorid, edesc: obj.errordesc || "<no_error_desc>"});
		}
		else if(obj.hasOwnProperty("code")) // v3 error
		{
			if(obj.code) // v3 error
				return({etype: "acapi_v3", eid: obj.code, edesc: obj.message || "<no_message>"});
		}
	}
	return null;
}

// end(11 a)

var WebRequest = function (method, url){
	this.method = method;
	this.url = url;
	this.parameters = new Object();
	this.encodedParams = function(){
		var res = [];
		for (var i in this.parameters){
			res.push(i+"="+encodeURIComponent(this.parameters[i]));
		}
		return res.join("&");
	}
}

WebRequest.prototype.setParameters = function(param){
	for (var i in param) this.parameters[i] = param[i];
}

WebRequest.prototype.sendRequest = function(onSuccess, onFailed){
	console.log("request==========\n", this.url);
	var xhr = new XMLHttpRequest();
	xhr.onreadystatechange = function(){
		if (xhr.readyState === xhr.DONE){
			// begin(11 a)
			//utility.copy_to_clipboard(xhr.responseText);
			//console.log(xhr.responseText);
			// end(11 a)
			if (xhr.status === 200 || xhr.status === 201){
				var res;
				try {
					res = JSON.parse(xhr.responseText);
				} catch(e){
					res = xhr.responseText;
				}
				try {
					onSuccess(res);
				} catch(e){
					onFailed(JSON.stringify(e));
				}
			} else {
				onFailed(xhr.status);
			}
		}
	}
	var p = this.encodedParams(), m = this.method;
	if (m === "GET" && p.length > 0){
		xhr.open("GET", this.url+"?"+p);
		// begin(11 c)
		//console.log(this.url + "?" + p);
		// end(11 c)
	} else {
		xhr.open(m, this.url);
	}

	if (m === "POST"){
		xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		xhr.setRequestHeader("Content-Length", p.length);
		xhr.send(p);
	} else if (m === "GET"){
		xhr.send();
	}
}
