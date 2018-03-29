var QQParser = new Function();
QQParser.prototype = new VideoParser();
QQParser.prototype.constructor = QQParser;
QQParser.prototype.name = "QQ";

QQParser.prototype.start = function(res){
	qq(res.sourceId);
}

var part_count = 0;
var total_count = 0;
var has_error = false;
var window = new Object();

function qq_getJSONP(url, callback, fail, ia, parta) {
	var cbname = "cb" + Date.now().toString();
	url += "&callback=";
	url += cbname;
	// if no callback, default is QZOutputJson;
	//console.log(url);

	window[cbname] = function(response) {
		callback(response, ia, parta);
	}

	var xhr = new XMLHttpRequest();
	xhr.onreadystatechange = function() {
		if (xhr.readyState == XMLHttpRequest.DONE) {
			//console.log(xhr.responseText);
			//utility.copy_to_clipboard(xhr.responseText);
			if (xhr.status == 200) {
				try {
					eval("window."+xhr.responseText);
				}
				catch(e)
				{
					fail(e);
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

function qq_request(url, suc, fail, ia, parta)
{
	var xhr = new XMLHttpRequest();
	xhr.onreadystatechange = function(){
		if (xhr.readyState === XMLHttpRequest.DONE){
			if (xhr.status == 200){
				//console.log(xhr.responseText);
				suc(xhr.responseText, ia, parta);
				return;
			}
			fail("Parse QQ failed");
		}
	}
	xhr.open("GET", url);
	xhr.send();
}

function qq(vid)
{ 
	has_error = false;
	part_count = 0;
	total_count = 0;
	var r = ({});

	var info_api = "http://vv.video.qq.com/getinfo?otype=json&appver=3.2.19.333&platform=11&defnpayver=1&vid=" + vid;
	//console.log(info_api);
	qq_getJSONP(info_api, function (video_json){ // get_info
		try
		{
			var fn_pre = video_json["vl"]["vi"][0]["lnk"];
			var title = video_json["vl"]["vi"][0]["ti"];
			var host = video_json["vl"]["vi"][0]["ul"]["ui"][0]["url"];
			var streams = video_json["fl"]["fi"];
			var seg_cnt = video_json["vl"]["vi"][0]["cl"]["fc"];
			if(seg_cnt == 0)
				seg_cnt = 1;

			total_count = seg_cnt * streams.length;

			r.title = video_json.vl.vi[0].ti || "";
			r.data = new Array(streams.length);
			var i;
			for(i = 0; i < streams.length; i++)
			{
				if(has_error)
				{
					QQParser.prototype.error("Error");
					return;
				}
				// last is the highest quality.
				var quality = streams[i]["name"];
				var part_format_id = streams[i]["id"];
				r.data[i] = ({});
				//console.log(streams[i].name + " - " + streams[i].cname);
				r.data[i].urls = new Array(seg_cnt);
				r.data[i].type = quality;
				r.data[i].total_msec = 0;

				for(var part = 1; part < seg_cnt + 1; part++)
				{
					if(has_error)
					{
						QQParser.prototype.error("Error");
						return;
					}
					var filename = fn_pre + ".p" + parseInt(part_format_id % 10000).toString() + "." + parseInt(part).toString() + ".mp4";
					var key_api = "http://vv.video.qq.com/getkey?otype=json&platform=11&format=%1&vid=%2&filename=%3&appver=3.2.19.333".arg(part_format_id.toString()).arg(vid.toString()).arg(filename);
					//console.log(key_api);
					qq_getJSONP(key_api, function(key_json, ia, parta){ //get_key
						//console.log("__", ia, parta);
						try
						{
							var vkey = null;
							var url;
							if (!key_json.hasOwnProperty("key"))
							{
								vkey = video_json["vl"]["vi"][0]["fvkey"];
								url = "%1%2?vkey=%3".arg(video_json["vl"]["vi"][0]["ul"]["ui"][0]["url"]).arg(fn_pre + ".mp4").arg(vkey);
							}
							else
							{
								vkey = key_json["key"];
								url = "%1%2?vkey=%3".arg(host).arg(filename).arg(vkey);
							}
							//console.log(url);
							if(!vkey)
							{
								if(parta == 1)
									console.log("WRONG: " + key_json["msg"]);
								else
									console.log(key_json["msg"]);
								has_error = true;
								return;
							}
							if(!key_json.hasOwnProperty("filename"))
							{
								console.log(key_json["msg"]);
								has_error = true;
								return;
							}
							var item = ({});
							item.msec = parseInt(parseFloat(video_json.vl.vi[0].cl.ci[parta - 1].cd) * 1000);
							r.data[ia].total_msec += item.msec;
							item.value = parta - 1;
							item.url = url;
							r.data[ia].urls[parta - 1] = item;
							part_count++;
							//console.log(part_count, total_count);
						}
						catch(e)
						{
							has_error = true;
							part_count++;
							QQParser.prototype.error(e);
							return;
						}
						finally{
							if(has_error)
							{
								return;
							}
							if(part_count >= total_count)
							{
								if(r.data.length > 0)
								{
									var stream_types = [
									{name: "sd", value: 3, cname: "标清;(270P)"},
									{name: "hd", value: 4, cname: "高清;(480P)"},
									{name: "shd", value: 5, cname: "超清;(720P)"},
										{name: "fhd", value: 6, cname: "蓝光;(1080P)"},
									];
									var sort = function(a, b){
										var f = function(v)
										{
											var i;
											for(i = 0; i < stream_types.length; i++)
											{
												if(v.type === stream_types[i].name)
													return stream_types[i].value;
											}
											return Number.MAX_VALUE;
										}
										var ai = f(a);
										var bi = f(b);
										return ai - bi;
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
										r.data[i].urls.sort(function(a, b){
											return(a.value - b.value);
										});
									}
									r.def = 0;
									QQParser.prototype.success(r);
									return;
								}
								else
								{
									QQParser.prototype.error("No data");
									return;
								}
							}
						}
					}, function(e){
						has_error = true;
						QQParser.prototype.error(e);
						part_count += seg_cnt;
					}, i, part); // request 2
				}
			}
		}
		catch(e)
		{
			has_error = true;
			QQParser.prototype.error(e);
			return;
		}
	}, function(e){
		has_error = true;
		QQParser.prototype.error(e);
	}); // request 1
}

//qq("j0025mcp0h1");

