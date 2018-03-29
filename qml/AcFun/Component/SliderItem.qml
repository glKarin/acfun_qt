import QtQuick 1.1
import com.nokia.symbian 1.1

Item{
	id: root;

    objectName: "k_SliderItem";

	property string text: "";
	property string sub_text: "";
	property string min_text: "";
	property string max_text: "";
	property alias minimumValue: slider.minimumValue;
	property alias maximumValue: slider.maximumValue;
	property alias stepSize: slider.stepSize;
	property alias value: slider.value;
	property bool inverted: false;
	property bool auto_label: false;
	property real label_width: 85;
	property alias pressed: slider.pressed;

	clip: true;

	Row{
		anchors.fill: parent;
		anchors.margins: constant.paddingSmall;
		spacing: 0; //constant.paddingLarge;
		Column{
			id: col;
			anchors.verticalCenter: parent.verticalCenter;
			width: root.label_width;
			spacing: constant.paddingSmall;
			Text{
				anchors.left: parent.left;
				width: parent.width;
				color: root.inverted ? "white" : constant.colorLight;
				font: constant.subTitleFont;
				elide: Text.ElideRight;
				text: root.text;
			}
			Text{
				anchors.left: parent.left;
				width: parent.width;
				horizontalAlignment: Text.AlignHCenter;
				font: constant.subTitleFont;
				color: root.inverted ? constant.colorDisabled : constant.colorLight;
				elide: Text.ElideRight;
				text: root.auto_label ? slider.value : root.sub_text;
			}
		}

		Column{
			width: parent.width - parent.spacing - col.width;
			anchors.verticalCenter: parent.verticalCenter;
			spacing: constant.paddingSmall;
			Item{
				width: parent.width;
				height: min_label.height;
				Text{
					id: min_label;
					anchors.left: parent.left;
					anchors.leftMargin: 30;
					anchors.top: parent.top;
					anchors.bottom: parent.bottom;
					width: parent.width / 2;
					horizontalAlignment: Text.AlignLeft;
					verticalAlignment: Text.AlignVCenter;
					font: constant.subTitleFont;
					color: root.inverted ? constant.colorDisabled : constant.colorLight;
					elide: Text.ElideRight;
					text: root.auto_label ? slider.minimumValue : root.min_text;
				}
				Text{
					id: max_label;
					anchors.right: parent.right;
					anchors.rightMargin: 30;
					anchors.top: parent.top;
					anchors.bottom: parent.bottom;
					width: parent.width / 2;
					horizontalAlignment: Text.AlignRight;
					verticalAlignment: Text.AlignVCenter;
					font: constant.subTitleFont;
					color: root.inverted ? constant.colorDisabled : constant.colorLight;
					elide: Text.ElideRight;
					text: root.auto_label ? slider.maximumValue : root.max_text;
				}
			}
			Slider{
				id: slider;
				width: parent.width;
				anchors.horizontalCenter: parent.horizontalCenter;
				minimumValue: 0;
				maximumValue: 100;
				stepSize: 1;
				value: 1;
				valueIndicatorText: value.toString();
			}
		}
	}
}
