import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"
import "util.js" as Util

Item{
	id: root;
	property bool inverted: false;
	property int played_seconds: 0;
	property int total_seconds: 0;

	signal copy;
	signal openExternally;
	signal seek(real per);

	anchors.fill: parent;

	Flickable{
		id: view;
		anchors.fill: parent;
		contentWidth: width;
		contentHeight: main_col.height;
		clip: true;
		flickableDirection: Flickable.VerticalFlick;

		Column{
			id: main_col;
			anchors.horizontalCenter: parent.horizontalCenter;
			width: parent.width;
			spacing: constant.paddingMedium;
			Column{
				anchors.horizontalCenter: parent.horizontalCenter;
				width: parent.width;
				spacing: constant.paddingSmall;
				SectionHeader{
					title: "设置";
					inverted: true;
				}
				Column{
					anchors.horizontalCenter: parent.horizontalCenter;
					width: parent.width;
					spacing: constant.paddingMedium;
					SwitchItem{
						anchors.horizontalCenter: parent.horizontalCenter;
						width: parent.width;
						height: 60;
						text: "显示弹幕";
						inverted: root.inverted;
						checked: acsettings.playerShowDanmu;
						onCheckedChanged: {
							acsettings.playerShowDanmu = checked;
						}
					}
					SliderItem{
						anchors.horizontalCenter: parent.horizontalCenter;
						width: parent.width;
						height: 80;
						inverted: true;
						label_width: 90;
						text: "不透明度";
						sub_text: acsettings.playerDanmuOpacity.toFixed(1).toString();
						min_text: acsettings.playerDanmuOpacityRange.min.toFixed(1).toString();
						max_text: acsettings.playerDanmuOpacityRange.max.toFixed(1).toString();
						minimumValue: acsettings.playerDanmuOpacityRange.min;
						maximumValue: acsettings.playerDanmuOpacityRange.max;
						stepSize: acsettings.playerDanmuOpacityRange.step;
						value: acsettings.playerDanmuOpacity;
						onValueChanged:{
							if(pressed){
								acsettings.playerDanmuOpacity = value;
							}
						}
					}
					SliderItem{
						anchors.horizontalCenter: parent.horizontalCenter;
						width: parent.width;
						height: 80;
						inverted: true;
						label_width: 90;
						text: "字体比例";
						sub_text: acsettings.playerDanmuFactory.toFixed(1).toString();
						min_text: acsettings.playerDanmuFactoryRange.min.toFixed(1).toString();
						max_text: acsettings.playerDanmuFactoryRange.max.toFixed(1).toString();
						minimumValue: acsettings.playerDanmuOpacityRange.min;
						maximumValue: acsettings.playerDanmuFactoryRange.max;
						stepSize: acsettings.playerDanmuFactoryRange.step;
						value: acsettings.playerDanmuFactory;
						onValueChanged:{
							if(pressed){
								acsettings.playerDanmuFactory = value;
							}
						}
					}
					SliderItem{
						anchors.horizontalCenter: parent.horizontalCenter;
						width: parent.width;
						height: 80;
						inverted: true;
						label_width: 90;
						text: "滚动速度";
						sub_text: acsettings.playerDanmuSpeed.toFixed(1).toString();
						min_text: acsettings.playerDanmuSpeedRange.min.toFixed(1).toString();
						max_text: acsettings.playerDanmuSpeedRange.max.toFixed(1).toString();
						minimumValue: acsettings.playerDanmuSpeedRange.min;
						maximumValue: acsettings.playerDanmuSpeedRange.max;
						stepSize: acsettings.playerDanmuSpeedRange.step;
						value: acsettings.playerDanmuSpeed;
						onValueChanged:{
							if(pressed){
								acsettings.playerDanmuSpeed = value;
							}
						}
					}
					Column{
						anchors.horizontalCenter: parent.horizontalCenter;
						width: parent.width;
						spacing: constant.paddingSmall;
						Text {
							id: time_label;
							text: "总时长进度";
							font: constant.titleFont;
							color: "white";
							width: parent.width;
							elide: Text.ElideRight;
							horizontalAlignment: Text.AlignHCenter;
						}
						Item{
							width: parent.width;
							height: timeElapsedLabel.height + constant.paddingSmall;
							Text {
								id: timeElapsedLabel;
								text: Util.milliSecondsToString(played_seconds);
								font: constant.labelFont;
								color: "white";
								anchors {
									top: parent.top
									left: parent.left;
									right: timeDurationLabel.left;
									leftMargin: visual.controlMargins;
									topMargin: visual.controlMargins;
									bottomMargin: visual.controlMargins;
								}
							}
							Text {
								id: timeDurationLabel;
								text: Util.milliSecondsToString(root.total_seconds);
								font: constant.labelFont;
								color: "white";
								anchors {
									top: parent.top
									right: parent.right;
									rightMargin: visual.controlMargins;
									topMargin: visual.controlMargins;
									bottomMargin: visual.controlMargins;
								}
							}
						}
						ProgressBar {
                            platformInverted: true;
							anchors.horizontalCenter: parent.horizontalCenter;
							width: parent.width;
							value: root.played_seconds / root.total_seconds;
							MouseArea{
								anchors.centerIn: parent;
								//enabled:video.duration !== 0;
								width: parent.width;
								height: 5 * parent.height;
								onReleased:{
									root.seek(mouse.x / width);
								}
							}
						}
					}
				}
			}
			Column{
				anchors.horizontalCenter: parent.horizontalCenter;
				width: parent.width;
				spacing: constant.paddingSmall;
				SectionHeader{
					title: "其他";
					inverted: true;
				}
				Column{
					anchors.horizontalCenter: parent.horizontalCenter;
					width: parent.width;
					spacing: constant.paddingMedium;
					Button {
						anchors.horizontalCenter: parent.horizontalCenter;
                        width: Math.min(180, parent.width);
                        platformInverted: true;
						text: "复制地址";
						onClicked: {
							root.copy();
						}
					}
					Button {
                        anchors.horizontalCenter: parent.horizontalCenter;
                        width: Math.min(240, parent.width);
                        platformInverted: true;
						text: "外部播放器打开";
						onClicked: {
							root.openExternally();
						}
					}
				}
			}
		}
	}
	ScrollDecorator { flickableItem: view; }
}
