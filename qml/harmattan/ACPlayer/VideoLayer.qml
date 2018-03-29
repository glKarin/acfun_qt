import QtQuick 1.1
import com.nokia.meego 1.1
import QtMobility.systeminfo 1.1
import QtMultimediaKit 1.1

Item {
    id: root;

		// begin(11 a)
    property alias seekable: video.seekable;
		// end(11 a)
    property alias source: video.source;
    property alias duration: video.duration;
    property alias timePlayed: video.position;
    property int timeRemaining: duration - timePlayed;
    property alias volume: video.volume;

    property bool isPlaying: false;
    property bool freezing: video.status === Video.Loading;

    signal playbackStarted;
    signal loadStarted;

		// begin(11 c)
		signal playFinished;
		// end(11 c)

    function play(){
        video.play();
    }

    function pause(){
        video.pause();
    }

    function stop(){
        video.stop();
    }

    function __handleStatusChange(status, playing, position, paused){
        var isVisibleState = status === Video.Buffered || status === Video.EndOfMedia;
        var isStalled = status === Video.Stalled;

        // 背景
        if ((isVisibleState||isStalled) && !(paused && position === 0)){
            blackBackground.opacity = 0;
        } else {
            blackBackground.opacity = 1;
        }

        // 加载图标
        if (!isVisibleState && playing){
            busyIndicator.visible = true;
        } else {
            busyIndicator.visible = false;
        }

        if (status === Video.EndOfMedia){
            video.stop();
            video.position = 0;
						// begin(11 a)
						root.playFinished();
						// end(11 a)
        }
    }

    function __setScreenSaver(){
        if (video.playing && !video.paused){
            screenSaver.setScreenSaverDelayed(true);
        } else {
            screenSaver.setScreenSaverDelayed(false);
        }
    }

    ScreenSaver {
        id: screenSaver;
    }

    Rectangle {
        id: videoBackground;
        color: "#000000";
        anchors.fill: parent;
    }

    Video {
        id: video;

        property bool playbackStarted: false;
        property bool loaded: false;

        volume: visual.currentVolume;
        autoLoad: true;
        anchors.fill: parent;
        fillMode: Video.PreserveAspectFit;
				// begin(11 c)
				onSourceChanged: {
					video.position = 0;
					if(source.toString().length !== 0)
					{
						play();
					}
				}
				// end(11 c)
				onPlayingChanged: {
            root.isPlaying = playing;
            __setScreenSaver();
            __handleStatusChange(status, isPlaying, position, paused);
        }
        onPausedChanged: {
            root.isPlaying = !paused;
            __setScreenSaver();
            __handleStatusChange(status, isPlaying, position, paused);
        }
        onStatusChanged: {
            if (status === Video.Buffered && !video.playbackStarted){
                video.playbackStarted = true;
                root.playbackStarted();
            }
            if (status === Video.Loading && !video.loaded){
                video.loaded = true;
                root.loadStarted();
            }
            __handleStatusChange(status, isPlaying, position, paused);
        }
				// begin(11 a)
				onError: {
					signalCenter.showMessage("播放时发生错误: %1 - %2".arg(error).arg(errorString));
				}
				// end(11 a)
    }

    Rectangle {
        id: blackBackground;
        anchors.fill: parent;
        color: "#000000";
    }

    BusyIndicator {
        id: busyIndicator;
        anchors.centerIn: blackBackground;
        running: true;
        visible: false;
        platformStyle: BusyIndicatorStyle {
            inverted: true;
            size: "large";
        }
    }
}
