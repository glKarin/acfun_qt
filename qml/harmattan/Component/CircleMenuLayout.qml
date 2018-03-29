import QtQuick 1.1
import "CircleMenuLayout.js" as Layout

Item {
	id: circleMenuLayout;

	objectName: "k_CircleMenuLayout";
	anchors.centerIn: parent;

	// if not set anchors, must to set in&out_circle_radius or width&per;
	property real out_circle_radius: 0;
	property real in_circle_radius: 0;
	// if set anchors, must to set "per" prpperty.
	property real per: in_circle_radius / out_circle_radius;

	property bool auto_scale_items: false;

	// private property
	property real subWidth: width * per;
	width: visible && parent ? out_circle_radius : 0
	height: width;

	onSubWidthChanged: Layout.layout();
	onWidthChanged: Layout.layout()
	onHeightChanged: Layout.layout()
	onChildrenChanged: Layout.childrenChanged()
	Component.onCompleted: Layout.layout()

}

