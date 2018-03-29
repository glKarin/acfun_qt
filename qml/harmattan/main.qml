import QtQuick 1.1
import com.nokia.meego 1.1
import com.nokia.extras 1.1
import com.yeatse.acfun 1.0
import "Component"
import "ACPlayer" as AC
import "../js/main.js" as Script

PageStackWindow {
    id: app;

    initialPage: MainPage { id: mainPage; }

    CustomProgressBar { id: proBar; parent: pageStack; z: 10; }

    InfoBanner { id: infoBanner; topMargin: 36; }

    ACSettings { id: acsettings; }

    Constant { id: constant; }

    SignalCenter { id: signalCenter; }

    NetworkHelper { id: networkHelper; }

    AC.VisualStyle { id: visual; inPortrait: app.inPortrait; }

    Component.onCompleted: Script.initialize(signalCenter, acsettings, utility);

    /*
		// begin(11 a)
		// parse video part site in other thread for QQ and sohu
		WorkerScript{
			id: wk_sp;
			property bool time_limit: true;
			property int timeout_milliseconds: 45000; // 45sec
			//source: "../js/qq_parser_helper.js";
			onSourceChanged: {
				if(time_limit)
				{
					if(source.toString().length !== 0)
					{
						wk_timer.restart();
					}
					else
					{
						wk_timer.stop();
					}
				}
			}
		}
		Timer{
			id: wk_timer;
			running: false;
			repeat: true;
			interval: wk_sp.timeout_milliseconds;
			onTriggered: {
				if(wk_sp.time_limit)
				{
					if(wk_sp.toString().length !== 0){
						wk_sp.sendMessage({result: false, err: "Timeout: " + wk_sp.timeout_milliseconds});
						stop();
						console.log( "WorkerScript is timeout.");
					}
				}
				else
				{
					stop();
				}
			}
		}
		// end(11 a)
        */

}
