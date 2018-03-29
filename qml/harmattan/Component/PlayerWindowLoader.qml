import QtQuick 1.1

Loader {
	id: playerLoader;
	property string __MIN: "min";
	property string __NOR: "nor";
	property string __MAX: "max";

	x: 0; 
	y: 72;
	width: 480;
	height: 270;
	z: 15;
	visible: opacity > 0.0;
	state: __MIN;
	transform: [
		Scale{
			id: scl;
			origin.x : x + width / 2;
			origin.y: y + height / 2;
			xScale: 1.0;
			yScale: 1.0;
		},
		Rotation {
			id: rot;
			origin: Qt.vector3d(pageStack.height / 2, pageStack.width / 2, 0);
			axis: Qt.vector3d(0, 0, 1);
			angle: 0;
		}
	]
	states: [
		State{
			name: playerLoader.__MIN;
			PropertyChanges{
				target: scl;
				xScale: 0.0;
				yScale: 0.0;
			}
			PropertyChanges{
				target: playerLoader;
				opacity: 0.0;
			}
		},
		State{
			name: playerLoader.__NOR;
		},
		State{
			name: playerLoader.__MAX;
			PropertyChanges{
				target: app;
				showStatusBar: false;
				platformToolBarHeight: 0;
				showToolBar: false;
				platformStyle.cornersVisible: false;
			}
			PropertyChanges{
				target: playerLoader;
				// harmattan
				width: app.inPortrait ? pageStack.height : pageStack.width;
				height: app.inPortrait ? pageStack.width : pageStack.height;
			}
			AnchorChanges{
				target: playerLoader;
				anchors.horizontalCenter: pageStack.horizontalCenter;
				anchors.verticalCenter: pageStack.verticalCenter;
			}
			PropertyChanges{
				target: rot;
				angle: app.inPortrait ? 90.0 : 0.0;
			}
		}
	]

	transitions: [
		Transition{
			ParallelAnimation{
				NumberAnimation{
					target: scl;
					properties: "xScale,yScale";
					duration: 400;
				}
				NumberAnimation{
					target: playerLoader;
					properties: "width,height";
					duration: 400;
				}
				AnchorAnimation{
					duration: 400;
				}
				RotationAnimation{
					duration: 400;
				}
			}
		}
	]
}
