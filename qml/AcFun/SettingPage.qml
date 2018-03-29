import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"
import "../js/main.js" as Script
import "../js/keywordhistory.js" as KW_DB
import "../js/database.js" as PLAYED_DB

MyPage {
	id: page;

    title: "设置";
	tools: ToolBarLayout {
		ToolIcon {
			platformIconId: "toolbar-back";
			onClicked: pageStack.pop();
		}
	}

	QtObject{
		id: qobj;
		property int keyword_history: KW_DB.getHistorySize();
		property int played_history: PLAYED_DB.get_size();
		property bool header_edit: false;

		function open_update()
		{
			signalCenter.open_info_dialog("更新", signalCenter.c_KARIN_UPDATE);
		}

		function open_about()
		{
			signalCenter.open_info_dialog("关于", signalCenter.c_KARIN_ABOUT, Script.handle_link);
		}

		function set_header_setting()
		{
			var hm = [
				{name: "userAgent", setting: "user_agent"},
				{name: "deviceType", setting: "deviceType"},
				{name: "market", setting: "market"},
				{name: "appVersion", setting: "appVersion"}
			];
			var i;
			for(i = 0; i < hm.length; i++)
			{
				acsettings[hm[i].name] = utility.getValue(hm[i].setting, "");
				header_model.get(i).value = acsettings[hm[i].name];
			}
			header_repeater.modelChanged(header_model);
		}

		function allow_edit_header_setting()
		{
			signalCenter.createQueryDialog(
				"警告",
				"以下一些或全部请求头，是某些Acfun接口所必需的。如果值错误可能导致无法访问API，导致某些程序功能无法使用。如果没有确定或被通知，请不要修改。如果无意间被修改过，可以点击\"重置\"按钮还原。",
				"允许修改",
				"禁止修改",
				function(){
					header_edit = true;
					header_switcher.checked = true;
				},
				function(){
					header_edit = false;
					header_switcher.checked = false;
				});
			}

			function clear_played()
			{
				signalCenter.createQueryDialog(
					"请注意",
					"该操作无法撤回！确定要清空播放历史记录？",
					"确定",
					"取消",
					function(){
						PLAYED_DB.clearHistory();
						keyword_history = KW_DB.getHistorySize();
					});
				}

				function clear_keyword()
				{
					signalCenter.createQueryDialog(
						"请注意",
						"该操作无法撤回！确定要清空搜索关键词历史记录？",
						"确定",
						"取消",
						function(){
							KW_DB.clearHistory();
							played_history = PLAYED_DB.get_size();
						});
					}

					function make_header_model()
					{
						header_model.clear();
						header_model.append({
							name: "userAgent",
							text: "User-Agent",
							value: acsettings.userAgent,
							desc: "访问Acfun API的用户代理"
						});
						header_model.append({
							name: "deviceType",
							text: "deviceType",
							value: acsettings.deviceType,
							desc: "设备类型（整数类型）"
						});
						header_model.append({
							name: "market",
							text: "market",
							value: acsettings.market,
							desc: "应用来源（portal, acfun_h5, m360...）"
						});
						header_model.append({
							name: "appVersion",
							text: "appVersion",
							value: acsettings.appVersion,
							desc: "版本号（x.x.x）"
						});
					}
				}

				ViewHeader {
					id: viewHeader;
					title: "设置";
				}

				Column {
					id: head_col;
					anchors.left: parent.left;
					anchors.top: viewHeader.bottom;
					anchors.right: parent.right;
					spacing: constant.paddingMedium;

					Image {
						id: acfun;
						anchors.horizontalCenter: parent.horizontalCenter;
						clip: true;
						width: 200;
						sourceSize.width: 200;
						fillMode: Image.PreserveAspectCrop;
						source: Qt.resolvedUrl("../gfx/acfun_logo.png");
					}

					Row{
						anchors.horizontalCenter: parent.horizontalCenter;
						width: parent.width;

						Text{
							anchors.verticalCenter: parent.verticalCenter;
							horizontalAlignment: Text.AlignHCenter;
							width: parent.width / 3;
							font: constant.titleFont;
							color: constant.colorLight;
							elide: Text.ElideRight;
							text: "<a href=\"show_update\">查看更新</a>"
							onLinkActivated: {
								qobj.open_update();
							}
						}
						Text{
							anchors.verticalCenter: parent.verticalCenter;
							horizontalAlignment: Text.AlignHCenter;
							width: parent.width / 3;
							font: constant.titleFont;
							color: constant.colorLight;
							elide: Text.ElideRight;
							text: "<a href=\"show_about\">关于更新</a>"
							onLinkActivated: {
								qobj.open_about();
							}
						}
						Text{
							anchors.verticalCenter: parent.verticalCenter;
							horizontalAlignment: Text.AlignHCenter;
							width: parent.width / 3;
							font: constant.titleFont;
							color: constant.colorLight;
							elide: Text.ElideRight;
							text: "<a href=\"../gfx/acapi.json\">API</a>"
							onLinkActivated: {
                                utility.openURLDefault(link);
							}
						}
					}
				}

				Flickable{
					id: view;
					anchors{
						fill: parent;
						topMargin: viewHeader.height + head_col.height + constant.paddingMedium;
					}
					contentWidth: width;
					contentHeight: main_col.height;
					clip: true;
					flickableDirection: Flickable.VerticalFlick;

					Column {
						id: main_col;
						anchors.left: parent.left;
						anchors.top: parent.top;
						anchors.right: parent.right;
						spacing: constant.paddingMedium;
						// general setting
						Column{
							anchors.horizontalCenter: parent.horizontalCenter;
							width: parent.width;
							spacing: constant.paddingSmall;
							SectionHeader{
								title: "一般";
							}
							Column{
								id: general_col;
								anchors.horizontalCenter: parent.horizontalCenter;
								width: parent.width;
								spacing: constant.paddingMedium;
								Column{
									anchors.horizontalCenter: parent.horizontalCenter;
									width: parent.width;
									spacing: constant.paddingSmall;
									Text{
										anchors.horizontalCenter: parent.horizontalCenter;
										width: parent.width;
										font: constant.titleFont;
										color: constant.colorLight;
										elide: Text.ElideRight;
										text: "播放器";
									}
									Text{
										anchors.horizontalCenter: parent.horizontalCenter;
										width: parent.width;
										font: constant.subTitleFont;
										color: constant.colorMid;
										maximumLineCount: 3;
										wrapMode: Text.Wrap;
										elide: Text.ElideRight;
										text: "(部分源自youku/QQ的视频播放出现\"3-Forbidden\"错误，请使用外部播放器播放)";
									}
									ButtonColumn{
										anchors.horizontalCenter: parent.horizontalCenter;
										width: parent.width;
										spacing: constant.paddingSmall;
										CheckBox {
                                            id: i_player_btn;
                                            enabled: utility.qtVersion >= 0x040800;
											text: "内置播放器";
											checked: !acsettings.usePlatformPlayer;
                                            onClicked: acsettings.usePlatformPlayer = false;
										}
										CheckBox {
                                            id: e_player_btn;
											text: "外部播放器";
											checked: acsettings.usePlatformPlayer;
                                            onClicked: acsettings.usePlatformPlayer = true;
                                        }
                                        Component.onCompleted: {
                                            if (! (utility.qtVersion >= 0x040800))
                                            {
                                                i_player_btn.text += " (Qt请求4.8以上版本)";
                                                acsettings.usePlatformPlayer = true;
                                            }
                                        }
									}
								}								
								Column{
									anchors.horizontalCenter: parent.horizontalCenter;
									width: parent.width;
									spacing: constant.paddingSmall;
									Text{
										anchors.horizontalCenter: parent.horizontalCenter;
										width: parent.width;
										font: constant.titleFont;
										color: constant.colorLight;
										elide: Text.ElideRight;
										text: "浏览器";
									}
									Text{
										anchors.horizontalCenter: parent.horizontalCenter;
										width: parent.width;
										font: constant.subTitleFont;
										color: constant.colorMid;
										maximumLineCount: 3;
										wrapMode: Text.Wrap;
										elide: Text.ElideRight;
										text: "(用来打开评论中，私信中和其他的外部链接)";
									}
									ButtonColumn{
										anchors.horizontalCenter: parent.horizontalCenter;
										width: parent.width;
										spacing: constant.paddingSmall;
										CheckBox {
											text: "外部浏览器";
											checked: acsettings.useExternallyBrowser;
											onClicked: acsettings.useExternallyBrowser = true;
										}
										CheckBox {
											text: "内置浏览器";
											checked: !acsettings.useExternallyBrowser;
											onClicked: acsettings.useExternallyBrowser = false;
										}
									}
								}								
								SwitchItem{
									anchors.horizontalCenter: parent.horizontalCenter;
									width: parent.width;
									height: 60;
									text: "文章加载图片";
									checked: acsettings.articleLoadImage;
									onCheckedChanged: {
										acsettings.articleLoadImage = checked;
									}
								}
							}
						}

						// browser setting
						Column{
							anchors.horizontalCenter: parent.horizontalCenter;
							width: parent.width;
							spacing: constant.paddingSmall;
							SectionHeader{
								title: "浏览器";
							}
							Column{
								id: browser_col;
								anchors.horizontalCenter: parent.horizontalCenter;
								width: parent.width;
								spacing: constant.paddingMedium;
								SwitchItem{
									anchors.horizontalCenter: parent.horizontalCenter;
									width: parent.width;
									height: 60;
									text: "加载图片";
									checked: acsettings.browserLoadImage;
									onCheckedChanged: {
										acsettings.browserLoadImage = checked;
									}
								}
								SwitchItem{
									anchors.horizontalCenter: parent.horizontalCenter;
									width: parent.width;
									height: 60;
									text: "自动处理Url";
									checked: acsettings.browserAutoHandleUrl;
									onCheckedChanged: {
										acsettings.browserAutoHandleUrl = checked;
									}
								}
								SwitchItem{
									anchors.horizontalCenter: parent.horizontalCenter;
									width: parent.width;
									height: 60;
									text: "辅助条";
									checked: acsettings.browserHelper;
									onCheckedChanged: {
										acsettings.browserHelper = checked;
									}
								}
							}
						}

						// header swttings
						Column{
							anchors.horizontalCenter: parent.horizontalCenter;
							width: parent.width;
							spacing: constant.paddingSmall;
							SectionHeader{
								title: "请求头";
							}
							Column{
								id: header_col;
								anchors.horizontalCenter: parent.horizontalCenter;
								width: parent.width;
								SwitchItem{
									id: header_switcher;
									anchors.horizontalCenter: header_col.horizontalCenter;
									height: 60;
									width: 200;
									label_proxy: true;
									text: qobj.header_edit ? "允许修改" : "禁止修改";
									checked: qobj.header_edit;
									onCheckedChanged: {
										if(checked)
										{
											qobj.allow_edit_header_setting();
										}
										else
										{
											qobj.header_edit = false;
											qobj.set_header_setting();
										}
									}
								}

								Repeater{
									id: header_repeater;
									model: ListModel{
										id: header_model;
									}
									delegate: Component{
										Row{
											//anchors.horizontalCenter: header_col.horizontalCenter;
											width: header_col.width;
											height: 60;
											spacing: constant.paddingMedium;
											Text{
												id: header_text;
												anchors.verticalCenter: parent.verticalCenter;
												width: 150;
												font: constant.titleFont;
												color: constant.colorLight;
												elide: Text.ElideRight;
												text: model.text;
												MouseArea{
													enabled: qobj.header_edit;
													anchors.fill: parent;
													onClicked: {
														header_input.make_focus();
													}
												}
											}
											SearchInput{
												id: header_input;
												anchors.verticalCenter: parent.verticalCenter;
												width: parent.width - parent.spacing - header_text.width;
												readOnly: !qobj.header_edit;
												text: model.value;
												search_icon_visible: false;
                                                actionKeyLabel: "保存";
												onReturnPressed: {
													if (text.length === 0)
													{
														signalCenter.showMessage(model.name + "不能为空");
													}
													else
													{
														acsettings[model.name] = text;
													}
												}
												placeholderText: model.desc;
												inputMethodHints: Qt.ImhNoAutoUppercase;
												Connections{
													target: header_repeater;
													onModelChanged: {
														//console.log(model.value);
														header_input.text = model.value;
													}
												}
											}
										}
									}
								}
								Component.onCompleted: {
									qobj.make_header_model();
								}
							}
							Button {
								anchors.horizontalCenter: parent.horizontalCenter;
                                width: 200;
								text: "重置";
								onClicked: {
									utility.reset_header_setting();
									qobj.set_header_setting();
								}
							}
						}

						// other functions
						Column{
							anchors.horizontalCenter: parent.horizontalCenter;
							width: parent.width;
							spacing: constant.paddingSmall;
							SectionHeader{
								title: "其他";
							}
							Column{
								anchors.horizontalCenter: parent.horizontalCenter;
								width: parent.width;
								Text{
									width: parent.width;
									horizontalAlignment: Text.AlignHCenter;
									font: constant.titleFont;
									color: constant.colorLight;
									elide: Text.ElideRight;
									text: "搜索关键词记录: " + qobj.keyword_history;
								}
								Button {
                                    anchors.horizontalCenter: parent.horizontalCenter;
                                    width: 300;
									text: "清空搜索关键词记录";
									onClicked: {
										qobj.clear_keyword();
									}
								}
							}
							Column{
								anchors.horizontalCenter: parent.horizontalCenter;
								width: parent.width;
								Text{
									width: parent.width;
									horizontalAlignment: Text.AlignHCenter;
									font: constant.titleFont;
									color: constant.colorLight;
									elide: Text.ElideRight;
									text: "播放历史记录: " + qobj.played_history;
								}
								Button {
                                    anchors.horizontalCenter: parent.horizontalCenter;
                                    width: 200;
									text: "清空播放历史记录";
									onClicked: {
										qobj.clear_played();
									}
								}
							}
						}
					}
				}
                ScrollDecorator { flickableItem: view; }

			}


