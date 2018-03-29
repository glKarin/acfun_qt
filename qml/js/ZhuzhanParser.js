var ZhuzhanParser = function(){

	function zhuzhan_getJSONP(url, header, callback) {
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
						callback(res);
					}
				}
			}
		}

		xhr.open("GET", url);
		if(header)
		{
			for(var k in header)
				xhr.setRequestHeader(k, header[k]);
		}
		xhr.send();
		//console.log("__ " + url);
	}

	// base64.decode
	function na(a) {
		if (!a) return "";
		var a = a.toString(),
			c, b, f, i, e, h = [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1, 63, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, -1, -1, -1, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1, -1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1];
		i = a.length;
		f = 0;
		for (e = ""; f < i;) {
			do c = h[a.charCodeAt(f++) & 255]; while (f < i && -1 == c);
			if (-1 == c) break;
			do b = h[a.charCodeAt(f++) & 255]; while (f < i && -1 == b);
			if (-1 == b) break;
			e += String.fromCharCode(c << 2 | (b & 48) >> 4);
			do {
				c = a.charCodeAt(f++) & 255;
				if (61 == c) return e;
				c = h[c]
			} while (f < i && -1 == c);
			if (-1 == c) break;
			e += String.fromCharCode((b & 15) << 4 | (c & 60) >> 2);
			do {
				b = a.charCodeAt(f++) & 255;
				if (61 == b) return e;
				b = h[b]
			} while (f < i && -1 == b);
			if (-1 == b) break;
			e += String.fromCharCode((c &
						3) << 6 | b)
		}
		return e
	}

	// rc4
	function E(a, c) {
		for (var b = [], f = 0, i, e = "", h = 0; 256 > h; h++) b[h] = h;
		for (h = 0; 256 > h; h++) f = (f + b[h] + a.charCodeAt(h % a.length)) % 256, i = b[h], b[h] = b[f], b[f] = i;
		for (var q = f = h = 0; q < c.length; q++) h = (h + 1) % 256, f = (f + b[h]) % 256, i = b[h], b[h] = b[f], b[f] = i, e += String.fromCharCode(c.charCodeAt(q) ^ b[(b[h] + b[f]) % 256]);
		return e
	}

	function zhuzhan(sourceId, sign, contentId) {
		var referer = "http://www.acfun.cn/v/ac" + contentId;
		zhuzhan_getJSONP("http://player.acfun.cn/flash_data?vid=%1&ct=%2&ev=%3&sign=%4&time=%5".arg(sourceId).arg(85).arg(3).arg(sign).arg(Date.now().toString()) + "&referer=" + referer, {"Referer": referer}, function(res){
			var data = res.data;
			if(!data)
			{
				ZhuzhanParser.prototype.error("No data");
				return;
			}
			try
			{
				var b64_d_data = /*base64_decode*/na(data);
				//console.log("b64 -> " + b64_d_data);
				var rc4_d_data = /*rc4*/E("8bdc7e1a", b64_d_data);
				//console.log("rc4 -> " + rc4_d_data);
				var youku_json = JSON.parse(rc4_d_data);

				var r = ({});
				r.title = youku_json.title || (youku_json.video ? youku_json.video.title : "");
				r.data = [];
				var i;
				for(i = 0; i < youku_json.stream.length; i++)
				{
					var e = youku_json.stream[i];
					// if is m3u8, there is no segs property.
					if(!e.hasOwnProperty("segs"))
						continue;
					var o = ({});
					//console.log(e.stream_type);
					o.urls = [];
					o.type = e.stream_type;
					o.total_msec = e.hasOwnProperty("duration") ? e.duration * 1000 : (e.hasOwnProperty("milliseconds_video") ? e.milliseconds_video : (e.hasOwnProperty("milliseconds_audio") ? milliseconds_audio : 0));
					var j;
					for(j = 0; j < e.segs.length; j++)
					{
						var item = {
							value: j,
							url: e.segs[j].url,
							msec: e.segs[j].hasOwnProperty("seconds") ? e.segs[j].seconds * 1000 : (e.segs[j].hasOwnProperty("total_milliseconds_video") ? e.segs[j].total_milliseconds_video : (e.segs[j].hasOwnProperty("total_milliseconds_audio") ? e.segs[j].total_milliseconds_audio : 0))
						};
						o.urls.push(item);
					}
					r.data.push(o);
				}
				if(r.data.length > 0)
				{
					var stream_types = [
					{name: "flvhd",  value: 3},
					{name: "mp4hd", value: 4},
					{name: "mp4hd2", value: 5},
						{name: "mp4hd3", value: 6}
					//m3u8_mp4
					//m3u8_hd3
					//m3u8_hd
					//m3u8_flv
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
					}
					r.def = 0;
					ZhuzhanParser.prototype.success(r);
				}
				else
				{
					ZhuzhanParser.prototype.error("No url Data");
				}
			}
			catch(e)
			{
				ZhuzhanParser.prototype.error(e);
			}
		});
	}

	this.start = function(res){
		var sourceId = res.sourceId;
		var sign = res.encode;
		var contentId = res.contentId;
		zhuzhan(sourceId, sign, contentId);
	}
};

ZhuzhanParser.prototype = new VideoParser();
ZhuzhanParser.prototype.constructor = ZhuzhanParser;
ZhuzhanParser.prototype.name = "优酷云";

