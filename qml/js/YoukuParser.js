var YoukuParser = function(){

	function youku_request(url, callback) {
		var xhr = new XMLHttpRequest();
		xhr.onreadystatechange = function() {
			if (xhr.readyState == XMLHttpRequest.DONE) {
				if (xhr.status == 200) {
					if(callback)
					{
						var res = null;
						try {
							//console.log("___" + xhr.responseText + "____");
							res = JSON.parse(xhr.responseText);
						} catch(e) {
							res = xhr.responseText;
						}
						callback(res, xhr.getAllResponseHeaders());
					}
				}
			}
		}

		xhr.open("GET", url);
		xhr.send();
		//console.log("__ " + url);
	}

	var window = new Object();

	function youku_getJSONP(url, callback) {
		var cbname = "cb" + Date.now().toString();
		url += "&callback=";
		url += cbname;
		//console.log(url);

		window[cbname] = function(response) {
			callback(response);
		}

		var xhr = new XMLHttpRequest();
		xhr.onreadystatechange = function() {
			if (xhr.readyState == XMLHttpRequest.DONE) {
				//console.log(xhr.responseText);
				//utility.copy_to_clipboard(xhr.responseText);
				if (xhr.status == 200) {
					try {
						eval("window."+xhr.responseText);
					} finally {
						delete window[cbname];
					}
				} else {
					delete window[cbname];
				}
			}
		}

		xhr.open("GET", url);
		xhr.send();
	}

	function youku(videoId) {
		var etag_url = "https://log.mmstat.com/eg.js";
		youku_request(etag_url, function(text, header){
			var arr = header.split("\r\n");
			var utid;
			for(var i in arr)
			{
				var a = arr[i].split(": ");
				var etag = a[0].toLowerCase();
				if(etag === "etag")
				{
					utid = a[1].split('"')[1];
					var url = "https://ups.youku.com/ups/get.json?vid=%1&ccode=%2&client_ip=%3&utid=%4&client_ts=%5";
					var CCODE = "0590";
					var CLIENT_IP = "192.168.1.1";
					var ts = Date.now().toString();
					url = url.arg(Youku_HandleVID(videoId)).arg(CCODE).arg(CLIENT_IP).arg(utid).arg(ts);
					console.log(url);

					youku_getJSONP(url, function(obj){
						if(!obj.data)
						{
							YoukuParser.prototype.error("No data");
							return;
						}
						try
						{
							var r = ({});
							r.title = obj.data.video ? obj.data.video.title : "";
							r.data = [];
							for(var s in obj.data.stream)
							{
								var e = obj.data.stream[s];
								var o = ({});
								//console.log(e.stream_type);
								o.urls = [];
								o.type = e.stream_type;
								o.total_msec = e.hasOwnProperty("milliseconds_video") ? e.milliseconds_video : (e.hasOwnProperty("milliseconds_audio") ? milliseconds_audio : 0);
								var j;
								for(j = 0; j < e.segs.length; j++)
								{
									/*
										 var q = link.indexOf("?");
										 if(q !== -1)
										 link = link.substring(0, q);
										 */
									var item = {
										value: j,
										url: Youku_RemakeCdnUrl(e.segs[j].cdn_url),
										msec: e.segs[j].hasOwnProperty("total_milliseconds_video") ? e.segs[j].total_milliseconds_video : (e.segs[j].hasOwnProperty("total_milliseconds_audio") ? e.segs[j].total_milliseconds_audio : 0)
									};
									o.urls.push(item);
								}
								r.data.push(o);
							}
							if(r.data.length > 0)
							{
								// Last updated: 2017-10-13
								var stream_types = [
								{name: '3gphd',    'container': 'mp4', 'video_profile': '渣清', value: 2},
								{name: 'flvhd',    'container': 'flv', 'video_profile': '渣清', value: 2},

								{name: 'flv',      'container': 'flv', 'video_profile': '标清', value: 3},
									{name: 'mp4',      'container': 'mp4', 'video_profile': '标清', value: 3},
									{name: 'mp4sd',    'container': 'mp4', 'video_profile': '标清', value: 3},

										{name: 'mp4hd',    'container': 'mp4', 'video_profile': '高清', value: 4},

										{name: '3gp',      'container': '3gp', 'video_profile': '渣清', value: 1},

											{name: 'hd2',      'container': 'flv', 'video_profile': '超清', value: 5},
											{name: 'mp4hd2',   'container': 'mp4', 'video_profile': '超清', value: 5},
												{name: 'hd2v2',    'container': 'flv', 'video_profile': '超清', value: 5},
												{name: 'mp4hd2v2', 'container': 'mp4', 'video_profile': '超清', value: 5},

													{name: 'hd3',      'container': 'flv', 'video_profile': '1080P', value: 6},
													{name: 'mp4hd3',   'container': 'mp4', 'video_profile': '1080P', value: 6},
														{name: 'hd3v2',    'container': 'flv', 'video_profile': '1080P', value: 6},
														{name: 'mp4hd3v2', 'container': 'mp4', 'video_profile': '1080P', value: 6},
															];
								var sort = function(a, b){
									var f = function(v)
									{
										var i;
										for(i = 0; i < stream_types.length; i++)
										{
											if(v.type === stream_types[i].name)
												return {index: i, value: stream_types[i].value};
										}
										return {index: i, value: Number.MAX_VALUE};
									}
									var ai = f(a);
									var bi = f(b);
									if(ai.value === bi.value)
										return ai.index - bi.index;
									else
										return ai.value - bi.value;
								}
								r.data.sort(sort);
								var i;
								for(i = 0; i < r.data.length; i++)
								{
									var q = 0;
									var j;
									for(j = 0; j < stream_types.length; j++)
									{
										if(r.data[i].type === stream_types[j].name)
										{
											q = stream_types[j].value;
											break;
										}
									}
									r.data[i].quality = q;
									r.data[i].value = "%1(%2)".arg(qualitys[q]).arg(r.data[i].type);
								}
								var def = -1;
								for(i = 0; i < stream_types.length; i++)
								{
									var j;
									for(j = 0; j < r.data.length; j++)
									{
										if(stream_types[i].name === r.data[j].type)
										{
											def = j;
											break;
										}
									}
									if(def !== -1)
										break;
								}
								r.def = def === -1 ? 0 : def;
								YoukuParser.prototype.success(r);
							}
							else
							{
							YoukuParser.prototype.error("No stream.");
							}
						}
						catch(e)
						{
							YoukuParser.prototype.error(e);
						}
					}); 
					break;
				}
			}
		}, function(e){
			YoukuParser.prototype.error("Can not get utid.");
		});
	}

	function Youku_RemakeCdnUrl(url_in)
	{
		if(!url_in)
			return null;
		var dispatcher_url = "vali.cp31.ott.cibntv.net";
		if(url_in.indexOf(dispatcher_url) != -1)
			return url_in;
		else if(url_in.indexOf("k.youku.com") != -1)
			return url_in;
		else
		{
			var parts = url_in.split("://", 2);
			var parts_2 = parts[1].split("/");
			parts_2[0] = dispatcher_url;
			var url_out_2 = parts_2.join("/");
			return parts[0] + "://" + url_out_2;
		}
	}

	function Youku_HandleVID(vid)
	{
		if(!vid)
			return vid;
		if(vid.length === 17 && vid.indexOf("==") === 15)
		{
			return vid.substring(0, 15);
		}
		return vid;
	}

	function query(url) {
		youku(videoId);
	}

	this.start = function(res){
		youku(res.sourceId);
		/*
		var pattern = /^http:\/\/v.youku.com\/v_show\/id_([0-9a-zA-Z]+)(==|_.*)?\.html/;
		if (!url.match(pattern)) {
			showStatusText("Invalid url!");
			return;
		}
		var videoId = url.match(pattern)[1];
			 var typeMap = {
			 "flv": "flv", //普清
			 "mp4": "mp4", //高清
			 "flvhd2": "flv", //超清
			 "3gphd": "mp4", //高清
			 "3gp": "3gp", //普清
			 "flvhd3": "flv", //1080p原画
			 };
			 */
	}
};

YoukuParser.prototype = new VideoParser();
YoukuParser.prototype.constructor = YoukuParser;
YoukuParser.prototype.name = "优酷";

