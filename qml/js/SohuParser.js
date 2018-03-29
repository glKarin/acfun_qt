var SohuParser = new Function();
SohuParser.prototype = new VideoParser();
SohuParser.prototype.constructor = SohuParser;
SohuParser.prototype.name = "搜狐";

SohuParser.prototype.start = function(res){
	//sohu(res.sourceId);
	SohuParser.prototype.error("不支持"); return;
}

/*
var window = new Object();

function getJSONP(url, callback) {
	var cbname = "cb" + Date.now().toString();
	//url += "&callback=";
	//url += cbname;
	//console.log(url);

	window[cbname] = function(response) {
		callback(response);
	}

	var xhr = new XMLHttpRequest();
	xhr.onreadystatechange = function() {
		if (xhr.readyState == XMLHttpRequest.DONE) {
			console.log(xhr.responseText);
			//utility.copy_to_clipboard(xhr.responseText);
			if (xhr.status == 200) {
				try {
					//eval("window." + cbname + "=(" + xhr.responseText + ");");
					window[cbname] = window[cbname](JSON.parse(xhr.responseText));
				}
				catch(e)
				{
					console.log(e);
				} finally {
					delete window[cbname];
				}
			} else {
				delete window[cbname];
			}
		}
	}

	console.log(url);
	xhr.open("GET", url);
	xhr.send();
}

function sohu_request(url, suc, fail)
{
	var xhr = new XMLHttpRequest();
	xhr.onreadystatechange = function(){
		if (xhr.readyState == xhr.DONE){
			if (xhr.status == 200){
				try
				{
					console.log(xhr.responseText);
					suc(JSON.parse(xhr.responseText));
				}
				catch(e)
				{
					fail(e);
				}
			}else
				fail("Request failed");
		}
	}
	xhr.open("GET", url);
	xhr.send();
}

function real_url(host,vid,tvid,_new,clipURL,ck)
{
	var url = 'http://'+host+'/?prot=9&prod=flash&pt=1&file='+clipURL+'&new='+_new +'&key='+ ck+'&vid='+vid.toString()+'&uid='+Date.now().toString()+'&t='+Math.random().toString()+'&rb=1';
	console.log(url);
	return url;
	sohu_request(url, function(obj){
		return json.loads(get_html(url))['url']
	}, function(e){
	});
}

function sohu(vid)
{
	var r = ({});
	r.c = 0;
	r.tc = 0;
	r.loaded = false;
	r.has_error = false;
	getJSONP('http://hot.vrs.sohu.com/vrs_flash.action?vid=%1'.arg(vid.toString()), function(info){
			if(!info)
			{
				r.has_error = true;
				return;
			}
			r.title = info.keyword || "";
			var types = ["relativeId", "norVid", "highVid", "superVid", "oriVid"];
			var ava_types = [];
			var count = 0;
			var i;
			var ext_for = true;
			for(i = 0; i < types.length; i++)
			{
				var hqvid = 0;
				var qtyp = types[i];
				if(info.data)
					hqvid = info["data"][qtyp];
				else
					hqvid = info[qtyp];
				if(hqvid && hqvid != 0 && hqvid != vid)
					ava_types.push({name: qtyp, value: hqvid});
				console.log(hqvid);
			}
	r.data = new Array(ava_types.count);
	for(i = 0; i < ava_types.length; i++)
	{
		if(r.has_error)
			break;
		var qtyp = ava_types[i].name;
		var hqvid = ava_types[i].value;
		r.data[i] = ({});
		r.data[i].urls = [];
		r.data[i].type = qtyp;
		r.data[i].total_msec = 0;
		var d = r.data[i];
		console.log(qtyp, hqvid);
		getJSONP('http://hot.vrs.sohu.com/vrs_flash.action?vid=%1'.arg(hqvid), function(info2){
				if(!info2 || !info2.allot)
				{
					return;
				}
				var host = info2['allot'];
				var prot = info2['prot'];
				var tvid = info2['tvid'];
				var urls = [];
				var data = info2['data'];
				//var title = data['tvName'];
				console.log(data['tvName']);
				var cul = data['clipsURL'].length;
				var cbl = data['clipsBytes'].length;
				var sl = data['su'].length;
				if(cul === cbl && cul === sl)
				{
					return;
				}
				var len = Math.min(cul, Math.min(cbl, sl))
				var j;
				for(j = 0; j < len; j++)
				{
					var u = d.urls[j];
					u.value = j;
					u.mesc = 0;
					var _new = data["su"][j];
					var clip = data["clipsURL"][j];
					var ck = data["ck"][j];
					var clipURL = utility.urlparse(clip).path;
					u.url = real_url(host, hqvid, tvid,_new, clipURL, ck);
				}
	});
	}
});
}

*/
