import QtQuick 1.1
import com.nokia.meego 1.1
import "../Component"

Item{
	id: root;

	property variant stream_types: null;
	property int type_index: 0;
	property int part_index: 0;
	property bool inverted: false;

	signal clicked(int type, int part);

	anchors.fill: parent;

	function init(d, t, p)
	{
		stream_types = d;
		type_view.model = stream_types ? stream_types : null;
		part_view.model = null;
		update(t, p);
	}

	function update(type, part)
	{
		var t = type;
		if(type === undefined || type < 0)
		{
			t = 0;
		}
		var p = part;
		if(part === undefined || part < 0)
		{
			p = 0;
		}
		if(stream_types)
		{
			type_view.currentIndex = t;
			type_view.positionViewAtIndex(t, ListView.Beginning);
			type_index = t;
			part_view.model = stream_types[t].urls;
			part_view.currentIndex = p;
			part_view.positionViewAtIndex(p, GridView.Beginning);
			part_index = p;
		}
		else
		{
			type_view.currentIndex = -1;
			part_view.currentIndex = -1;
			type_index = 0;
			part_index = 0;
		}
	}

	function ready()
	{
		if(stream_types)
		{
			if(type_view.currentIndex !== type_index)
			{
				if(!type_view.model)
				{
					type_view.model = stream_types;
				}
				type_view.currentIndex = type_index;
				type_view.positionViewAtIndex(type_index, ListView.Beginning);
				part_view.model = stream_types[type_index].urls;
				part_view.currentIndex = part_index;
				part_view.positionViewAtIndex(part_index, GridView.Beginning);
			}
			if(part_view.currentIndex !== part_index)
			{
				if(!part_view.model)
				{
					part_view.model = stream_types[type_index].urls;
				}
				part_view.currentIndex = part_index;
				part_view.positionViewAtIndex(part_index, GridView.Beginning);
			}
		}
		else
		{
			type_view.currentIndex = -1;
			part_view.currentIndex = -1;
		}
	}

	ListView {
		id: type_view;
		anchors {
			top: parent.top;
			left: parent.left;
			right: parent.right;
			leftMargin: constant.paddingSmall;
			rightMargin: constant.paddingSmall;
		}
		height: 65;
		clip: true;
		orientation: ListView.Horizontal;
		//model: root.stream_types;
		spacing: constant.paddingSmall;
		delegate: Component {
			AbstractItem{
				width: 150;
				height: type_view.height;
				Text{
					anchors.verticalCenter: parent.verticalCenter;
					width: parent.width;
					horizontalAlignment: Text.AlignHCenter;
					elide: Text.ElideRight;
					text: modelData.value;
					color: parent.ListView.isCurrentItem ? (root.inverted ? "skyblue" : "seagreen") : (root.inverted ? "white" : constant.colorLight);
					font.family: constant.labelFont.family;
					font.pixelSize: constant.labelFont.pixelSize;
					font.bold: parent.ListView.isCurrentItem;
				}
				Rectangle{
					anchors.bottom: parent.bottom;
					anchors.left: parent.left;
					anchors.right: parent.right;
					height: 6;
					radius: 4;
					smooth: true;
					color: "red";
					visible: parent.ListView.isCurrentItem;
				}
				MouseArea{
					anchors.fill: parent;
					onClicked: {
						if(parent.ListView.view.currentIndex !== index)
						{
							parent.ListView.view.currentIndex = index;
							part_view.model = root.stream_types[parent.ListView.view.currentIndex].urls;
							part_view.currentIndex = 0;
							part_view.positionViewAtBeginning();
						}
					}
				}
			}
		}

		/*
		 onModelChanged: {
			 part_view.model = root.stream_types[currentIndex].urls;
			 part_view.currentIndex = 0;
			 part_view.positionViewAtBeginning();
		 }
		 */
	}

	Rectangle{
		id: line;
		anchors{
			top: type_view.bottom;
			left: parent.left;
			right: parent.right;
			margins: constant.paddingSmall;
		}
		height: 2;
		color: root.inverted ? "white" : "black";
	}

	GridView {
		id: part_view;
		anchors {
			top: line.bottom;
			left: parent.left;
			right: parent.right;
			bottom: parent.bottom;
			leftMargin: constant.paddingSmall;
			rightMargin: constant.paddingSmall;
		}
		clip: true;
		cellWidth: 110;
		cellHeight: 80;
		//model: ;
		delegate: Component{
			Item {
				id: delegate_item;
				width: GridView.view.cellWidth;
				height: GridView.view.cellHeight;

				Rectangle {
					anchors.fill: parent;
					anchors.margins: constant.paddingSmall;
					color: delegate_item.GridView.isCurrentItem ? (root.inverted ? "lightgrey" : "orange") : (root.inverted ? "black" : "white");
					Text {
						anchors.centerIn: parent;
						//anchors.fill: parent;
						font: constant.titleFont;
						color: delegate_item.GridView.isCurrentItem ? (root.inverted ? "lightseagreen" : "lightskyblue"): (root.inverted ? "white" : "black");
						text: modelData.value
						//horizontalAlignment: Text.AlignRight;
						//verticalAlignment: Text.AlignVCenter;
						elide: Text.ElideRight;
						textFormat: Text.PlainText;
					}
				}

				MouseArea {
					id: mouseArea;
					anchors.fill: parent;
					onClicked: {
						delegate_item.GridView.view.currentIndex = index;
						root.type_index = type_view.currentIndex;
						root.part_index = index;
						root.clicked(root.type_index, root.part_index);
					}
				}
			}
		}
	}

	ScrollDecorator { flickableItem: part_view; }
}

