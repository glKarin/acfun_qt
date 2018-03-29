import QtQuick 1.1
import com.nokia.meego 1.1
import "util.js" as Util

Item {
    id: root;

    property bool autoHide;
    property bool isPlaying;
    property int timePlayed;
    property int timeDuration;
    property bool backFreezed;

    signal backPressed;
    signal pausePressed;
    signal playPressed;

		// begin(11 a)
		property real setting_bar_width: 400;
		property real setting_bar_height: 340;
		property bool has_next: false;
		property bool has_prev: false;
		property alias title: label.text
		property bool seekable: false;
		property alias stream_types: streamtype_tab.stream_types;
		property alias played_seconds: setting_tab.played_seconds;
		property alias total_seconds: setting_tab.total_seconds;

		signal prev;
		signal next;
		signal play(int type, int part);
		signal setting;
		signal streams;
		signal seek(real per);
		signal seekForAll(real per);
		signal copyUrl;
		signal playWithExternally;

		function set_streams(l, d, t, p)
		{
			streamtype_tab.init(d, t, p);
			label.text = "%1_%2[%3]".arg(l).arg(d[t].value).arg(p.toString());
		}

		function set_type_and_part(t, p)
		{
			streamtype_tab.update(t, p);
		}

		function toggle_setting()
		{
			if(tab_group.currentTab === setting_tab)
			{
				settingBar.state = settingBar.state === "" ? "Hidden" : "";
			}
			else
			{
				tab_group.currentTab = setting_tab;
				settingBar.state = "";
			}
		}

		function toggle_streamtype()
		{
			if(tab_group.currentTab === streamtype_tab)
			{
				settingBar.state = settingBar.state === "" ? "Hidden" : "";
			}
			else
			{
				tab_group.currentTab = streamtype_tab;
				settingBar.state = "";
			}
			streamtype_tab.ready();
		}
		// end(11 a)

    Component.onCompleted: root.forceActiveFocus();

    Keys.onUpPressed: __volumeUp();
    Keys.onDownPressed: __volumeDown();
		// begin(11 a)
		Keys.onLeftPressed: root.prev();
		Keys.onRightPressed: root.next();
		// end(11 a)

    function __volumeUp() {
        var maxVol = 1.0;
        var volThreshold = 0.1;
        if (visual.currentVolume < maxVol - volThreshold) {
            visual.currentVolume += volThreshold;
        } else {
            visual.currentVolume = maxVol;
        }
    }

    function __volumeDown() {
        var minVol = 0.0;
        var volThreshold = 0.1;
        if (visual.currentVolume > minVol + volThreshold) {
            visual.currentVolume -= volThreshold;
        } else {
            visual.currentVolume = minVol;
        }
    }

    anchors.fill: parent;

    Connections {
        target: Qt.application;
        onActiveChanged: {
            if (!Qt.application.active){
                root.pausePressed();
            }
        }
    }

    MouseArea {
        id: mouseArea;
        anchors.fill: parent;
        onClicked: {
            bottomBar.state = bottomBar.state === "" ? "Hidden" : "";
						// begin(11 a)
						topBar.state = topBar.state === "" ? "Hidden" : "";
						// end(11 a)
        }
    }

    Timer {
        id: controlHideTimer;
				// begin(11 c)
        running: root.autoHide && bottomBar.state === "" && topBar.state === "";
        interval: visual.videoControlsHideTimeout;
				onTriggered: {
					bottomBar.state = "Hidden";
					topBar.state = "Hidden";
					//settingBar.state = "Hidden";
			}
				// end(11 c)
    }

    Item {
        id: bottomBar;
        width: parent.width;
        height: visual.controlAreaHeight;
        y: parent.height - visual.controlAreaHeight;

        states: [
            State {
                name: "Hidden";
                PropertyChanges {
                    target: bottomBar;
                    y: root.height;
                    opacity: 0.0;
                }
            }
        ]
        transitions: [
            Transition {
                from: ""; to: "Hidden"; reversible: true;
                ParallelAnimation {
                    PropertyAnimation {
                        properties: "opacity"
                        easing.type: Easing.InOutExpo
                        duration: visual.animationDurationShort
                    }
                    PropertyAnimation {
                        properties: "y"
                        duration: visual.animationDurationNormal
                    }
                }
            }
        ]

        BorderImage {
            id: background;
            property Style tbStyle: ToolBarStyle {
                inverted: true;
            }
            anchors.fill: parent;
            opacity: visual.controlOpacity;
            source: tbStyle.background;
            border { left: 10; top: 10; right: 10; bottom: 10; }
        }
        Button {
            id: backbutton;
            platformStyle: ButtonStyle {
                buttonWidth: visual.controlHeight;
                buttonHeight: visual.controlHeight;
                inverted: true;
            }
            enabled: !root.backFreezed;
            iconSource: "image://theme/icon-m-toolbar-back-white"
            anchors {
                left: parent.left;
                leftMargin: visual.controlMargins / 2;
                verticalCenter: parent.verticalCenter;
            }
            onClicked: root.backPressed();
        }
        Rectangle {
            id: separatorLine;
            width: visual.separatorWidth;
            color: visual.separatorColor;
            anchors {
                top: parent.top;
                bottom: parent.bottom;
                left: backbutton.right;
                leftMargin: visual.controlMargins / 2;
            }
        }
        Button {
            id: playButton;
            platformStyle: ButtonStyle {
                buttonWidth: visual.controlHeight;
                buttonHeight: visual.controlHeight;
                inverted: true;
            }
            iconSource: root.isPlaying
                        ? "image://theme/icon-m-toolbar-mediacontrol-pause-white"
                        : "image://theme/icon-m-toolbar-mediacontrol-play-white";
            anchors {
                verticalCenter: parent.verticalCenter;
                left: separatorLine.right;
                leftMargin: visual.controlMargins*2;
            }
            onClicked: {
							// begin(11 a)
								controlHideTimer.restart();
								// end(11 a)
                if (root.isPlaying){
                    root.pausePressed();
                } else {
                    root.playPressed();
                }
            }
        }
        Text {
            id: timeElapsedLabel;
            text: Util.milliSecondsToString(timePlayed);
            font: constant.labelFont;
            color: "white";
            anchors {
                bottom: playButton.verticalCenter;
                left: playButton.right;
                right: parent.right;
                leftMargin: visual.controlMargins;
                rightMargin: visual.controlMargins;
            }
        }
        Text {
            id: timeDurationLabel;
            text: Util.milliSecondsToString(timeDuration);
            font: constant.labelFont;
            color: "white";
            anchors {
                bottom: playButton.verticalCenter;
                right: parent.right;
                rightMargin: visual.controlMargins;
            }
        }
        ProgressBar {
            id: progressBar;
            platformStyle: ProgressBarStyle {
                inverted: true;
            }
            anchors {
                top: playButton.verticalCenter;
                left: playButton.right;
                right: timeDurationLabel.right;
                leftMargin: visual.controlMargins;
            }
            value: root.timePlayed / root.timeDuration;
						// begin(11 a)
						MouseArea{
							anchors.centerIn: parent;
							//enabled:video.duration !== 0;
							enabled: root.seekable;
							width: parent.width;
							height: 5 * parent.height;
							onReleased:{
								controlHideTimer.restart();
								if(root.seekable) {
									root.seek(mouse.x / parent.width);
								}
							}
						}
						// end(11 a)
        }
    }

		// begin(11 a)
		Item {
			id: topBar;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.top: parent.top;
			height: visual.controlAreaHeight;

			states: [
				State {
					name: "Hidden";
					PropertyChanges {
						target: topBar;
						height: 0;
						opacity: 0.0;
					}
				}
			]
			transitions: [
				Transition {
					from: ""; to: "Hidden"; reversible: true;
					ParallelAnimation {
						PropertyAnimation {
							properties: "opacity"
							easing.type: Easing.InOutExpo
							duration: visual.animationDurationShort
						}
						PropertyAnimation {
							properties: "height"
							duration: visual.animationDurationNormal
						}
					}
				}
			]

			BorderImage {
				id: background_t;
				property Style tbStyle: ToolBarStyle {
					inverted: true;
				}
				anchors.fill: parent;
				opacity: visual.controlOpacity;
				source: tbStyle.background;
				border { left: 10; top: 10; right: 10; bottom: 10; }
			}

			Text {
				id: label;
				font: constant.labelFont;
				color: "white";
				anchors {
					left: parent.left;
					right: separatorLine_t.left;
					leftMargin: visual.controlMargins;
					rightMargin: visual.controlMargins;
					top: parent.top;
					bottom: parent.bottom;
				}
				elide: Text.ElideRight;
				verticalAlignment: Text.AlignVCenter;
			}
			Rectangle {
				id: separatorLine_t;
				width: visual.separatorWidth;
				color: visual.separatorColor;
				anchors {
					top: parent.top;
					bottom: parent.bottom;
					right: prev_button.left;
					rightMargin: visual.controlMargins 
				}
			}
			Button {
				id: prev_button;
				platformStyle: ButtonStyle {
					buttonWidth: visual.controlHeight;
					buttonHeight: visual.controlHeight;
					inverted: true;
				}
				enabled: root.has_prev;
				iconSource: "image://theme/icon-m-toolbar-previous-white"
				anchors {
					right: next_button.left;
					rightMargin: visual.controlMargins * 2;
					verticalCenter: parent.verticalCenter;
				}
				onClicked: {
					// begin(11 a)
					controlHideTimer.restart();
					// end(11 a)
					root.prev();
				}
			}
			Button {
				id: next_button;
				platformStyle: ButtonStyle {
					buttonWidth: visual.controlHeight;
					buttonHeight: visual.controlHeight;
					inverted: true;
				}
				enabled: root.has_next;
				iconSource: "image://theme/icon-m-toolbar-next-white"
				anchors {
					right: separatorLine_t2.left;
					rightMargin: visual.controlMargins;
					verticalCenter: parent.verticalCenter;
				}
				onClicked: {
					// begin(11 a)
					controlHideTimer.restart();
					// end(11 a)
					root.next();
				}
			}
			Rectangle {
				id: separatorLine_t2;
				width: visual.separatorWidth;
				color: visual.separatorColor;
				anchors {
					top: parent.top;
					bottom: parent.bottom;
					right: stream_button.left;
					rightMargin: visual.controlMargins 
				}
			}
			Button {
				id: stream_button;
				platformStyle: ButtonStyle {
					buttonWidth: visual.controlHeight;
					buttonHeight: visual.controlHeight;
					inverted: true;
				}
				iconSource: "image://theme/icon-m-toolbar-list-white"
				anchors {
					right: setting_button.left;
					rightMargin: visual.controlMargins * 2;
					verticalCenter: parent.verticalCenter;
				}
				onClicked: {
					// begin(11 a)
					controlHideTimer.restart();
					// end(11 a)
					root.streams();
					root.toggle_streamtype();
				}
			}
			Button {
				id: setting_button;
				platformStyle: ButtonStyle {
					buttonWidth: visual.controlHeight;
					buttonHeight: visual.controlHeight;
					inverted: true;
				}
				iconSource: "image://theme/icon-m-toolbar-settings-white"
				anchors {
					right: parent.right;
					rightMargin: 60; // symbian ? 
					verticalCenter: parent.verticalCenter;
				}
				onClicked: {
					// begin(11 a)
					controlHideTimer.restart();
					// end(11 a)
					root.setting();
					root.toggle_setting();
				}
			}
		}

		Item {
			id: settingBar;
			width: root.setting_bar_width;
			height: root.setting_bar_height;
			anchors.right: parent.right;
			anchors.top: parent.top;
			anchors.topMargin: visual.controlAreaHeight;
			state: "Hidden";

			states: [
				State {
					name: "Hidden";
					PropertyChanges {
						target: settingBar;
						height: 0;
						opacity: 0.0;
					}
				}
			]
			transitions: [
				Transition {
					from: ""; to: "Hidden"; reversible: true;
					ParallelAnimation {
						PropertyAnimation {
							properties: "opacity"
							easing.type: Easing.InOutExpo
							duration: visual.animationDurationShort
						}
						PropertyAnimation {
							properties: "height"
							duration: visual.animationDurationNormal
						}
					}
				}
			]

			TabGroup{
				id: tab_group;
				anchors{
					bottom: close_icon.top;
					top: parent.top;
					left: parent.left;
					right: parent.right;
					margins: constant.paddingSmall;
				}
				z: 1;
				currentTab: setting_tab;
				SettingItem{
					id: setting_tab;
					anchors.fill: parent;
					inverted: true;
					onCopy: {
						root.copyUrl();
					}
					onOpenExternally: {
						root.playWithExternally();
					}
					onSeek: root.seekForAll(per);
				}

				StreamtypeItem{
					id: streamtype_tab;
					anchors.fill: parent;
					inverted: true;
					onClicked: {
						root.play(type, part);
					}
				}
			}

			ToolIcon{
				id: close_icon;
				anchors.bottom: parent.bottom;
				anchors.horizontalCenter: parent.horizontalCenter;
				height: 45;
				width: 60;
				platformIconId: "toolbar-up";
				onClicked: {
					settingBar.state = "Hidden";
				}
			}

			Rectangle{
				anchors.fill: parent;
				color: "black";
				opacity: 0.6;
			}
		}
		// end(11 a)

	}
