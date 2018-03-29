import QtQuick 1.1
import com.nokia.meego 1.1
import "Component"
import "../js/main.js" as Script

MyPage {
	id: page;

	tools: ToolBarLayout {
		ToolIcon {
			platformIconId: "toolbar-back";
			onClicked: pageStack.pop();
		}
	}

	function open_statement_dialog()
	{
		signalCenter.createQueryDialog(
			"用户须知", 
			"程序登录功能已修改，与原作者无关。\n程序不会收集和公开用户的登录信息。\n如果勾选了\"记录信息\"选项，程序会加密保存帐密文本到本地，反之则不会如此。\n如果同意该声明，程序则允许用户登录，但出现任何问题，概不负责。\n如果不信任此程序，请拒绝。", 
			"同意", "拒绝", 
			function(){
				statement_checkbox.checked = true;
			},
			function(){
				statement_checkbox.checked = false;
			});
	}

	function load_user_info()
	{
		if(!acsettings.saveUserLoginInfo)
		{
			return;
		}
		var map = utility.get_user_login_info();
		username_input.text = map["username"];
		pwd_input.text = map["userpwd"];
	}

	function clear_user_login_info()
	{
		utility.set_user_login_info("", "");
	}

	function login()
	{
		if(!statement_checkbox.checked)
		{
			signalCenter.showMessage("请先阅读\"程式使用声明\"，如果同意该声明，则勾选\"我同意\"选项，之后程序可允许用户登录。");
			return;
		}
		var username = username_input.text;
		var pwd = pwd_input.text;
		if(!username || username.length === 0)
		{
			return;
		}
		if(!pwd || pwd.length === 0)
		{
			return;
		}

		if(acsettings.saveUserLoginInfo)
		{
			utility.set_user_login_info(username, pwd);
		}
		sign_in(username, pwd);
	}

	function sign_in(username, pwd)
	{
		loading = true;
		var opt = {
			"username":  username,
			"password": pwd
		};
		function s(obj){
			loading = false;
			signalCenter.showMessage("登录成功!");
			pageStack.pop();
		}
		function f(err){
			loading = false;
			signalCenter.showMessage(err);
		}
		Script.sign_in(opt, s, f);
	}

	ViewHeader {
		id: viewHeader;
		title: "登录";
	}

	Flickable {
		id: view;
		anchors{
			topMargin: constant.paddingMedium;
			bottomMargin: constant.paddingMedium;
			top: viewHeader.bottom;
			bottom: parent.bottom;
			left: parent.left;
			right: parent.right;
			leftMargin: constant.paddingLarge;
			rightMargin: constant.paddingLarge;
		}
		clip: true;
		contentWidth: main_col.width;
		contentHeight: Math.max(main_col.height, height);
		boundsBehavior: Flickable.StopAtBounds;
		flickableDirection: Flickable.VerticalFlick;
		Column {
			id: main_col;
			width: view.width;
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
				height: 60;
				spacing: constant.paddingMedium;
				Text{
					id: username_text;
					anchors.verticalCenter: parent.verticalCenter;
					width: 60;
					font: constant.titleFont;
					color: constant.colorLight;
					elide: Text.ElideRight;
					text: "口令";
					MouseArea{
						anchors.fill: parent;
						onClicked: {
							username_input.make_focus();
						}
					}
				}
				SearchInput{
					id: username_input;
					anchors.verticalCenter: parent.verticalCenter;
					width: parent.width - parent.spacing - username_text.width;
					search_icon_visible: false;
					actionKeyLabel: "下一项";	
					onReturnPressed: {
						if (text.length === 0)
						{
							signalCenter.showMessage("口令不能为空");
						}
						else
						{
							pwd_input.make_focus();
						}
					}
					placeholderText: ("手机号或邮箱");
					inputMethodHints: Qt.ImhNoAutoUppercase;
				}
			}

			Row{
				anchors.horizontalCenter: parent.horizontalCenter;
				width: parent.width;
				height: 60;
				spacing: constant.paddingMedium;
				Text{
					id: pwd_text;
					anchors.verticalCenter: parent.verticalCenter;
					width: 60;
					font: constant.titleFont;
					color: constant.colorLight;
					elide: Text.ElideRight;
					text: "密码";
					MouseArea{
						anchors.fill: parent;
						onClicked: {
							pwd_input.make_focus();
						}
					}
				}
				SearchInput{
					id:pwd_input;
					anchors.verticalCenter: parent.verticalCenter;
					width: parent.width - parent.spacing - pwd_text.width;
					echoMode: TextInput.Password;
					search_icon_visible: false;
					actionKeyLabel: "登录";	
					onReturnPressed: {
						if (text.length === 0)
						{
							signalCenter.showMessage("密码不能为空");
						}
						else if(username_input.text.length === 0)
						{
							signalCenter.showMessage("口令不能为空");
						}
						else
						{
							login();
						}
					}
					placeholderText: ("密纹");
					inputMethodHints: Qt.ImhNoAutoUppercase;
				}
			}

			Row{
				anchors.horizontalCenter: parent.horizontalCenter;
				width: showpwd_checkbox.width + store_checkbox.width + spacing;
				height: 40;
				spacing: constant.paddingMedium;
				CheckBox{
					id: showpwd_checkbox;
					anchors.verticalCenter: parent.verticalCenter;
					checked: false;
					text: "显示密码";
					onClicked:{
						pwd_input.echoMode = checked ? TextInput.Normal : TextInput.Password;
					}
				}
				CheckBox{
					id: store_checkbox;
					anchors.verticalCenter: parent.verticalCenter;
					checked: acsettings.saveUserLoginInfo;
					text: "记住信息";
					onClicked:{
						acsettings.saveUserLoginInfo = checked;
						if(!acsettings.saveUserLoginInfo)
						{
							clear_user_login_info();
						}
					}
				}
			}

			Row{
				anchors.horizontalCenter: parent.horizontalCenter;
				width: statement_checkbox.width + statement_text.width + spacing;
				height: 40;
				spacing: constant.paddingMedium;
				CheckBox{
					id: statement_checkbox;
					//width: parent.width;
					anchors.verticalCenter: parent.verticalCenter;
					checked: acsettings.acceptLoginStatement;
					text: "我同意";
					onCheckedChanged: {
						acsettings.acceptLoginStatement = checked;
					}
				}
				Text{
					id: statement_text;
					anchors.verticalCenter: parent.verticalCenter;
					//width: 60;
					font: constant.labelFont;
					color: constant.colorLight;
					elide: Text.ElideRight;
					text: "<a href=\"app_state\">程式使用声明</a>";
					onLinkActivated: {
						open_statement_dialog();
					}
				}
			}

			Button {
				id: loginBtn;
				anchors.horizontalCenter: parent.horizontalCenter;
				platformStyle: ButtonStyle {
					buttonWidth: 200;
				}
				text: "登录";
				enabled: username_input.text.length !== 0 && pwd_input.text.length !== 0;
				onClicked: {
					login();
				}
			}
		}
	}

	Component.onCompleted: {
		load_user_info();
	}
}

