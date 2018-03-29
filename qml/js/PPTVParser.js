var PPTVParser = new Function();
PPTVParser.prototype = new VideoParser();
PPTVParser.prototype.constructor = PPTVParser;
PPTVParser.prototype.name = "PPTV";

PPTVParser.prototype.start = function(vid){
	PPTVParser.prototype.error("不支持"); return;
}

