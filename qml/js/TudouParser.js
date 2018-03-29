var TudouParser = new Function();
TudouParser.prototype = new VideoParser();
TudouParser.prototype.constructor = TudouParser;
TudouParser.prototype.name = "土豆";

TudouParser.prototype.start = function(vid){
	TudouParser.prototype.error("不支持"); return;
}

