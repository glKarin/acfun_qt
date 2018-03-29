import QtQuick 1.1
import com.nokia.meego 1.1
// begin(11 a)
import com.nokia.extras 1.1
// end(11 a)
import "Component"
import "../js/main.js" as Script

MyPage {
    id: page;

		// begin(11 c)
    property int cid: -1;
    property int pid: -1;
    property string cname;
    //property variant subclass;
    //onCidChanged: internal.loadModel();
		// end(11 c)

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back";
            onClicked: pageStack.pop();
        }
        ToolIcon {
            platformIconId: "toolbar-refresh";
            onClicked: internal.getlist();
        }
    }

		// begin(11 c)
    function getlist(){ internal.loadModel(); internal.getlist(); }
		// end(11 c)

    QtObject {
        id: internal;

        property int pageNumber: 1;
        property int totalNumber: 0;
        property int pageSize: 20;

				// begin(11 c)
				property bool has_next_page: false;
        property int classId: page.cid;
				// end(11 c)
        property string className;

				// begin(11 c)
				function make_tumbler_model()
				{
					tumblermodel.clear();
					if(!signalCenter.videocategories)
					{
						return;
					}
					Script.make_one_category_model(signalCenter.videocategories, tumblermodel);
				}

        function setClass(){
                var item = tumblermodel.get(channelstc.selectedIndex);
								if (item){
									var item2 = item.children.get(subchannelstc.selectedIndex);
									if(item2)
									{
                    classId = item2.channel_id;
										className = item2.value;
										page.cname = item.value;
									}
                }
        }

				function loadModel(){
					make_tumbler_model();
					var c_id = 0;
					var sub_c_id = 0;
					if(page.pid === 0)
					{
						c_id = page.cid;
						sub_c_id = -1;
					}
					else
					{
						c_id = page.pid;
						sub_c_id = page.cid;
					}
					//console.log(page.cid + "_" + page.pid);
					var i;
					for(i = 0; i < tumblermodel.count; i++)
					{
						if(tumblermodel.get(i).channel_id == c_id)
						{
							channelstc.selectedIndex = i;
							var item = tumblermodel.get(i);
							subchannelstc.items = item.children;
							if(sub_c_id === -1)
							{
								subchannelstc.selectedIndex = 0;
							}
							else
							{
								subchannelstc.selectedIndex = 0;
								var j;
								for(j = 0; j < item.children.count; j++)
								{
									if(item.children.get(j).channel_id == sub_c_id)
									{
										subchannelstc.selectedIndex = j;
										break;
									}
								}
							}
							page.cname = tumblermodel.get(i).value;
							className = item.children && item.children.count > 0 ? item.children.get(0).value : "推荐";
							break;
						}
					}
				}
				// end(11 c)

        function getlist(option){
            loading = true;
						// begin(11 c)
            var opt = { model: view.model, "class": classId, "pageSize": pageSize };
            if (view.count === 0) option = "renew";
            option = option || "renew";
            if (option === "renew"){
                opt.renew = true;
								totalNumber = 0;
								pageNumber = 1;
								has_next_page = false;
            } else {
                opt.cursor = pageNumber + 1;
            }
            function s(obj){
                loading = false;
								has_next_page = false;
								if(obj.vdata.list && Array.isArray(obj.vdata.list))
								{
									if(obj.vdata.list.length !== 0)
									{
										if (option !== "renew"){
											pageNumber += 1;
										}
										totalNumber += obj.vdata.list.length;
										has_next_page = (obj.vdata.list.length === pageSize);
									}
									//pageSize = 20;
								}
            }
						// end(11 c)
            function f(err){ loading = false; signalCenter.showMessage(err); }
            Script.getClass(opt, s, f);
        }
    }

		// begin(11 c)
		Row{
			id: channelRow;
			property real theight: 185;
			function toggle()
			{
				if(state === "show")
				{
					state = "hide";
				}
				else if(state === "hide")
				{
					state = "show";
				}
			}
			anchors.top: viewheader.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			width: parent.width;
			height: 185;
			state: "show";
			visible: height >= 80;
			states: [
				State{
					name: "show";
					PropertyChanges {
						target: channelRow;
						height: theight;
					}
				}
				,
				State{
					name: "hide";
					PropertyChanges {
						target: channelRow;
						height: 0;
					}
				}
			]
			transitions: [
				Transition {
					from: "hide";
					to: "show";
					NumberAnimation{
						target: channelRow;
						property: "height";
						easing.type: Easing.OutExpo;
						duration: 400;
					}
				}
				,
				Transition {
					from: "show";
					to: "hide";
					NumberAnimation{
						target: channelRow;
						property: "height";
						easing.type: Easing.InExpo;
						duration: 400;
					}
				}
			]
			z: 1;
			Rectangle{
				id:tumbler;
				width:parent.width - 80;
				height: parent.height;
				z:1;
				Tumbler {
					anchors.fill: parent;
					columns: [channelstc, subchannelstc];
					TumblerColumn {
						id:channelstc;
						items:ListModel{id: tumblermodel}
						label:"频道";
						selectedIndex: 0;
						onSelectedIndexChanged: {
							subchannelstc.items = items.get(selectedIndex).children;
							subchannelstc.selectedIndex = 0;
						}
					}

					TumblerColumn {
						id:subchannelstc;
						items: null; // channelstc.items.get(channelstc.selectedIndex).children;
						label:"子频道";
						selectedIndex: 0;
					}
				}
			}
			ToolIcon{
				width: 80;
				height: width;
				anchors.verticalCenter: parent.verticalCenter;
				platformIconId: "toolbar-search";
				onClicked:{
					internal.setClass();
					internal.getlist();
				}
			}
		}

		// end(11 c)

		ViewHeader {
			id: viewheader;
			title: page.cname + "-" + internal.className;
			ToolIcon {
				anchors {
					right: parent.right; verticalCenter: parent.verticalCenter;
				}
				platformIconId: "toolbar-view-menu";
				// begin(11 c)
				onClicked: channelRow.toggle();
				// end(11 c)
			}
		}

		ListView {
			id: view;
			// begin(11 c)
			anchors { fill: parent; topMargin: viewheader.height + channelRow.height; }
			// end(11 c)
			model: ListModel {}
			delegate: CommonDelegate {}
			footer: FooterItem {
				// begin(11 c)
				visible: internal.has_next_page;
				// end(11 c)
				enabled: !loading;
				onClicked: internal.getlist("next");
			}
			// begin(11 a)
			clip: true;
			// end(11 a)
		}

		ScrollDecorator { flickableItem: view; }
	}
