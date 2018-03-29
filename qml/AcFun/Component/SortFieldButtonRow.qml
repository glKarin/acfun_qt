import QtQuick 1.1
import com.nokia.symbian 1.1

ButtonRow {
	id: root;
	signal sortClicked(int orderId, string orderName);

	function reset()
	{
		checkedButton = score;
	}

	Button {
		id: score;
		text: "相关度"
		onClicked: { sortClicked(0, "score"); }
	}
	Button {
		text: "收藏数";
		onClicked: { sortClicked(15, "stows"); }
	}
	Button {
		text: "点击数";
		onClicked: { sortClicked(11, "views"); }
	}
	Button {
		text: "发布时间"
		onClicked: { sortClicked(1, "releaseDate"); }
	}
	Button {
		text: "评论数"
		onClicked: { sortClicked(13, "comments"); }
	}
}
