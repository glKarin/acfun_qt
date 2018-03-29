var SinaParser = new Function();
SinaParser.prototype = new VideoParser();
SinaParser.prototype.constructor = SinaParser;
SinaParser.prototype.name = "新浪";

SinaParser.prototype.start = function(res){
	var regex = /(http[s]?:\/\/)?video\.sina\.com\.cn\/v\/b\/(\d+)-(\d+)\.html/;
	var backup_vid = res.sourceUrl.match(regex);
	var vid;
	try{
		vid = backup_vid[2];
	}
	catch(e)
	{
		vid = res.sourceId;
	}
	//console.log(res.sourceId, vid);
	sina(vid);
}

function sina_request(url, suc, fail)
{
	var xhr = new XMLHttpRequest();
	xhr.onreadystatechange = function(){
		if (xhr.readyState == xhr.DONE){
			if (xhr.status == 200){
				suc(xhr.responseXML);
			}else
				fail("Request failed");
		}
	}
	xhr.open("GET", url);
	xhr.send();
}

function randint(min, max)
{
	return parseFloat(Math.random() * (max - min) + min).toString();
}

function time()
{
	return parseInt(Date.now() / 1000);
}

function sina(vid)
{
	//vid = "1193036";
	var rand = "0.%1%2".arg(randint(10000, 10000000)).arg(randint(10000, 10000000));
	var tm = time().toString(2);
	var t = parseInt(tm.slice(0, -6), 2).toString();
	var k = Qt.md5((vid + 'Z6prk18aWxP278cVAH' + t + rand)/*.encode('utf-8')*/).substring(0, 16) + t;
	var url = 'http://ask.ivideo.sina.com.cn/v_play.php?vid=%1&ran=%2&p=i&k=%3&r=ent.sina.com.cn'.arg(vid.toString()).arg(rand).arg(k);
	console.log(url);
	sina_request(url, function(xml){
		if(!xml)
		{
			SinaParser.prototype.error("No XML response from Sina");
			return;
		}

		// getElementsByTagName
		/*Object.prototype.*/ var getElementsByTagName = function(obj, name)
		{
			if(!obj || !name)
				return null;

			var doc = obj.documentElement || obj;
			if(!doc)
				return null;

			var r = [];
			var f = function(o, n, arr)
			{
				if(!o || !n || !arr)
					return;
				if(o.tagName && o.tagName === n)
				{
					arr.push(o);
				}

				if(o.childNodes)
				{
					var i;
					for(i = 0; i < o.childNodes.length; i++)
					{
						f(o.childNodes[i], n, arr);
					}
				}
			}

			f(doc, name, r);
			return r;
		}

		try
		{
			var r = ({});
			var video = getElementsByTagName(xml, "video")[0];
			var result = getElementsByTagName(video, "result")[0];
			if(result.firstChild.nodeValue === "error")
			{
				var message = getElementsByTagName(video, "message")[0];
				SinaParser.prototype.error(message.firstChild.nodeValue);
				return;
			}
			var vname = getElementsByTagName(video, "vname")[0].firstChild.nodeValue;
			var durls = getElementsByTagName(video, "durl");
			var timelength = getElementsByTagName(video, "timelength")[0].firstChild.nodeValue;
			r.title = vname || "";
			r.data = [];
			var o = ({});
			o.urls = [];
			o.type = "flv";
			o.total_msec = timelength;
			var urls = [];
			for(var durl in durls)
			{
				var url = getElementsByTagName(durls[durl], "url")[0].firstChild.nodeValue;
				//var seg_size = getElementsByTagName(durls[durl], "filesize")[0].firstChild.nodeValue;
				var order = getElementsByTagName(durls[durl], "order")[0].firstChild.nodeValue;
				var length = getElementsByTagName(durls[durl], "length")[0].firstChild.nodeValue;
				urls.push(url)
					var item = {
						value: Number(order),
						url: url,
						msec: length
					};
				o.urls.push(item);
				//console.log(url);
			}
			r.data.push(o);
			if(r.data.length > 0)
			{
				var sort = function(a, b){
					return a.value - b.value;
				}
				var i;
				for(i = 0; i < r.data.length; i++)
				{
					r.data[i].urls.sort(sort);
					r.data[i].quality = 6; // I dont know the quality of flv.
					r.data[i].value = "%1(%2)".arg(qualitys[r.data[i].quality]).arg(r.data[i].type);
				}
				r.def = 0;
				ZhuzhanParser.prototype.success(r);
			}
			else
			{
				SinaParser.prototype.error("No url Data");
			}
		}
		catch(e)
		{
			SinaParser.prototype.error(e);
		}
	}, function(e){
		SinaParser.prototype.error(e);
	});
}

