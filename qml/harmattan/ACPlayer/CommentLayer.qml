import QtQuick 1.1
import "../../js/main.js" as Script
import "Comments.js" as Utils

Item {
    id: root;

		// begin(11 a)
		property bool running: acsettings.playerShowDanmu;

		visible: running;
		clip: true;
		// end(11 a)

    property string commentId;
    property int timePlayed;

    property int commentCount: 0;

    function get(){
        var opt = {
            pool: Utils.commentPool,
            cid: commentId
        }
        function s(){
            console.log("comment loaded");
            root.timePlayedChanged.connect(createText);
        }
        function f(err){
            console.log(err);
        }
        Script.getSyncComments(opt, s, f);
    }

    function createText(){
			// begin(11 a)
			if(!running)
			{
				return;
			}
			// end(11 a)
        if (timePlayed === 0) Utils.commentIndex = 0;
        var secs = timePlayed / 1000;
        var poolIdx = Utils.commentPool[Utils.commentIndex];
        while(poolIdx !== undefined && poolIdx.time < secs
              && root.commentCount < visual.maxCommentCount){
            if (secs - poolIdx.time < 3){
							// begin(11 c)
                var prop = {
                    "color": Utils.intToColor(poolIdx.color),
                    "font.pixelSize": parseInt(poolIdx.fontSize * acsettings.playerDanmuFactory),
										"opacity": acsettings.playerDanmuOpacity,
                    "text": poolIdx.text
                }
								// end(11 c)
                singleComment.createObject(root, prop);
            }
            poolIdx = Utils.commentPool[++Utils.commentIndex];
        }
    }

    Component.onCompleted: get();

    Component {
        id: singleComment;
        Text {
            id: commentText;

            property int idx: 0;

            x: root.width;
            y: idx*18;
            textFormat: Text.PlainText;

            NumberAnimation {
                id: normalAnimation;
                target: commentText;
                property: "x";
                from: root.width;
                to: -commentText.width;
								// begin(11 c)
                duration: parseInt(3000 / acsettings.playerDanmuSpeed);
								// end(11 c)
                onCompleted: commentText.destroy();
            }

            Component.onCompleted: {
                root.commentCount ++;
                commentText.idx = Utils.addToScreen();
                normalAnimation.start();
            }
            Component.onDestruction: {
                root.commentCount --;
                Utils.clearFromScreen(commentText.idx);
            }
        }
    }
}
