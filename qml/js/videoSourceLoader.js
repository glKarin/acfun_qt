// begin(11 c)
Qt.include("VideoParser.js");
Qt.include("SinaParser.js");
Qt.include("YoukuParser.js"); // fixed
//Qt.include("TudouParser.js"); // not support and not find tudou source
Qt.include("QQParser.js"); // fixed
Qt.include("LetvParser.js"); // not suppport
Qt.include("IQiyiParser.js"); // not support
Qt.include("ZhuzhanParser.js"); // add
Qt.include("SohuParser.js"); // not suppport
Qt.include("PPTVParser.js"); // not suppport
// end(11 c)

// begin(11 c)
var sid, type, model;
var createPlayer;

function loadSource(t, s, m, f){
    sid = s; type = t; model = m;
		createPlayer = f;
		//sid = 1396011; // qq
		// end(11 c)

		var url = "http://www.acfun.cn/video/getVideo.aspx?id=" + sid;
		//console.log("#########################");
		//console.log(url);
		var xhr = new XMLHttpRequest();
		xhr.onreadystatechange = function() {
			if (xhr.readyState == XMLHttpRequest.DONE) {
				if (xhr.status == 200) {
					var res = null;
					try {
						//console.log(xhr.responseText);
						res = JSON.parse(xhr.responseText);
						/*
						var i = 0;
						for(var k in res)
						{
							console.log("%1: %2 - %3".arg(i++).arg(k).arg(res[k].toString()));
						}
						console.log("#########################");
						*/
					} catch(e) {
            createPlayer("获取视频源json失败");
						return;
					}
					if(!res)
					{
            createPlayer("获取视频地址信息失败");
						return;
					}
					if(res.sourceType)
						type = res.sourceType;

					var parser;
					if (type === "sina")
						parser = new SinaParser();
					else if (type === "youku")
						parser = new YoukuParser();
					else if (type === "qq")
						parser = new QQParser();
					else if (type === "letv")
						parser = new LetvParser();
					else if (type === "iqiyi")
						parser = new IQiyiParser();
					else if (type === "youku2")
					{
						addMessage("视频源: youku2. 尝试作为youku解析");
						parser = new YoukuParser();
					}
					else if (type === "zhuzhan")
						parser = new ZhuzhanParser();
					// not support source
					else if (type === "tudou")
						parser = new TudouParser();
					else if (type === "letv2")
						parser = new LetvParser();
					else if (type === "sohu")
						parser = new SohuParser();
					else if (type === "pptv")
						parser = new PPTVParser();

					if (parser == undefined){
						addMessage("未支持的视频源:"+type);
					} else {
						addMessage("视频源来自%1，正在解析视频...".arg(parser.name));
						var vobj = {
							sourceId: res.sourceId || sid,
							encode: res.encode || "",
							contentId: res.contentId || sid,
							sourceType: res.sourceType || type,
							sourceUrl: res.sourceUrl || ""
						};
						console.log("sourceId -> %1, type -> %2, sourceUrl -> %3, contentId -> %4, encode -> %5".arg(vobj.sourceId.toString()).arg(vobj.sourceType.toString()).arg(vobj.sourceUrl.toString()).arg(vobj.contentId.toString()).arg(vobj.encode.toString()));
						parser.start(vobj);
					}
				}
				else
					createPlayer("获取视频地址信息失败");
			}
		}

		xhr.open("GET", url);
		xhr.send();

}

function addMessage(msg){
    model.append({"text": msg});
}

// begin(11 c)
// from qml/<platform>/ACPlayer/util.js by Yeatse
function format_video_length(milliseconds) {
    var timeInSeconds = milliseconds > 0 ? milliseconds / 1000 : 0;
    var minutes = Math.floor(timeInSeconds / 60);
    var minutesString = minutes < 10 ? "0" + minutes : minutes;
    var seconds = Math.floor(timeInSeconds % 60);
    var secondsString = seconds < 10 ? "0" + seconds : seconds;
		return minutesString + ":" + secondsString;
}

var qualitys = [
	"未知", "渣清", "普清", "标清", "高清", "超清", "原画"
];

VideoParser.prototype.success = function(obj){
	if(!obj)
	{
		VideoParser.prototype.error("解析视频地址失败");
		return;
	}
	if(obj.data.length === 0)
	{
		VideoParser.prototype.error("无视频地址信息");
		return;
	}
	addMessage("视频包含%1种清晰度".arg(obj.data.length));
	var q = [];
	var i;
	for(i = 0; i < obj.data.length; i++)
	{
		var e = obj.data[i];
		addMessage("%1: %2段 时长%3".arg(e.value).arg(e.urls.length).arg(format_video_length(e.total_msec)));
	}

	var def = obj.data[obj.def];
	var url = def.urls[0].url;
	createPlayer(obj);
}
// end(11 c)

VideoParser.prototype.error = function(message){
	// begin(11 c)
            addMessage("视频解析失败> <" + "   (" + message + ")");
						console.log(message);
						// end(11 c)
        }

// for test
