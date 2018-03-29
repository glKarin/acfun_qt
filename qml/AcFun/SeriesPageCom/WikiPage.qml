import QtQuick 1.1
import com.nokia.symbian 1.1
import CustomWebKit 1.0
import "../Component"

MyPage {
    id: page;

    title: webView.title;

    property url c_HOME: Qt.resolvedUrl("../../gfx/ac_home.html");
    //property url c_HOME: "http://m.acfun.cn";
    property url location_to: c_HOME;

    tools: ToolBarLayout {
        ToolButton {
            iconSource: "toolbar-back";
            onClicked: pageStack.pop();
        }
        ToolIcon{
            id:back;
            platformIconId: "toolbar-previous";
            enabled: webView.back.enabled;
            onClicked:{
                webView.back.trigger();
            }
        }
        ToolIcon{
            id:forward;
            platformIconId: "toolbar-next";
            enabled: webView.forward.enabled;
            onClicked:{
                webView.forward.trigger();
            }
        }
        ToolIcon {
            platformIconId: webView.progress === 1.0 ? "toolbar-refresh" : "toolbar-mediacontrol-pause";
            enabled: webView.progress === 1.0 ? webView.reload.enabled : webView.stop.enabled;
            onClicked :{
                if(webView.progress === 1.0){
                    webView.reload.trigger();
                }else{
                    webView.stop.trigger();
                }
            }
        }
        ToolIcon {
            platformIconId: "toolbar-menu";
            onClicked: circle_menu.toggle();
        }
    }

    function load(){
        webView.url = page.location_to;
    }

    function handle(link){
        var linkString = link.toString();
        if (/http.*?\.swf\?.*?vid=/.test(linkString)){
            //播放器地址
            var vid = utility.urlQueryItemValue(linkString, "vid");
            if (vid !== ""){
                var cid = utility.urlQueryItemValue(linkString, "cid");
                if (cid === "") cid = vid;
                signalCenter.playVideo("", "sina", vid, cid);
                return;
            }
        }
        if (linkString.indexOf("http://wiki.acfun.tv")===0){
            webView.url = linkString;
            return;
        }
        var acMatch = linkString.match(/http:\/\/.*?acfun\.tv\/v\/ac(\d+)/);
        if (acMatch){
            var acId = acMatch[1];
            signalCenter.viewDetail(acId);
            return;
        }
        var templ = [
                    { regex: /(http:\/\/)?www\.acfun\.(cn|tv)\/v\/ac(\d+)/, index: 3, func: signalCenter.viewDetail},
                    { regex: /(http:\/\/)?www\.acfun\.(cn|tv)\/bangumi\/ab(\d+)(_\d+_\d+)?/, index: 3, func: signalCenter.view_bangumi_detail},
                    { regex: /(http:\/\/)?www\.acfun\.(cn|tv)\/a\/aa(\d+)/, index: 3, func: signalCenter.view_album_detail},
                    { regex: /(http:\/\/)?www\.acfun\.(cn|tv)\/u\/(\d+)\.aspx/, index: 3, func: signalCenter.view_user_detail_by_id},
                    { regex: /(http:\/\/)?m\.acfun\.(cn|tv)\/v\/\?ac=(\d+)/, index: 3, func: signalCenter.viewDetail},
                    { regex: /(http:\/\/)?m\.acfun\.(cn|tv)\/v\/ac(\d+)/, index: 3, func: signalCenter.viewDetail}, // old
                    { regex: /(http:\/\/)?m\.acfun\.(cn|tv)\/v\/\?ab=(\d+)/, index: 3, func: signalCenter.view_bangumi_detail},
                    { regex: /(http:\/\/)?m\.acfun\.(cn|tv)\/details\?upid=(\d+)(&cid=\d+)?/, index: 3, func: signalCenter.view_user_detail_by_id},
                    { regex: /(http:\/\/)?m\.acfun\.(cn|tv)\/a\/aa(\d+)/, index: 3, func: signalCenter.view_album_detail}
                ];

        var i;
        for(i = 0; i < templ.length; i++)
        {
            var match_res = linkString.match(templ[i].regex);
            if (match_res){
                var aid = match_res[templ[i].index];
                templ[i].func(aid);
                return;
            }
        }

        //console.log(link);
        webView.url = link;
        return true;
        //Qt.openUrlExternally(linkString);
    }

    function fixUrl(url)
    {
        if (url == "") return url
        if (url[0] == "/") return "file://"+url
        if (url.indexOf(":")<0) {
            if (url.indexOf(".")<0 || url.indexOf(" ")>=0) {
                return "https://m.baidu.com/s?word="+url
            } else {
                return "http://"+url
            }
        }
        return url
    }

    function go_to_url(text)
    {
        if(text.indexOf("about:") === 0)
        {
            var a = text.split(":");
            if(a.length === 2)
            {
                var v = a[1];
                if(v.toLowerCase() === "config")
                {
                    pageStack.push(Qt.resolvedUrl("../SettingPage.qml"));
                }
                else if(v.toLowerCase() === "karin")
                {
                    signalCenter.open_info_dialog("关于", signalCenter.c_KARIN_ABOUT, Qt.openUrlExternally);
                }
                else if(v.toLowerCase() === "update")
                {
                    signalCenter.open_info_dialog("更新", signalCenter.c_KARIN_UPDATE);
                }
                else if(v.toLowerCase() === "acfun")
                {
                    pageStack.push(Qt.resolvedUrl("../AboutPage.qml"));
                }
                else
                {
                    signalCenter.showMessage("未知的查询 -> " + v);
                }
            }
        }
        else
        {
            var url = fixUrl(text);
            if(acsettings.browserAutoHandleUrl)
            {
                handle(url);
            }
            else
            {
                webView.url = url;
            }
        }
    }

    ViewHeader {
        id: viewHeader;

        Text {
            id: title;
            anchors {
                left: parent.left;
                leftMargin: constant.paddingMedium;
                right: parent.right;
                rightMargin: constant.paddingMedium;
                top: parent.top;
            }
            height: 25;
            font: constant.subTitleFont;
            color: constant.colorLight;
            elide: Text.ElideRight;
            text: webView.title;
            horizontalAlignment: Text.AlignHCenter;
        }
        SearchInput {
            id: searchInput;
            anchors {
                left: parent.left; right: searchBtn.left;
                leftMargin: constant.paddingMedium;
                rightMargin: constant.paddingMedium;
                //verticalCenter: parent.verticalCenter;
                top: title.bottom;
                bottom: parent.bottom;
            }
            z: 1;
            placeholderText: "输入网址/关键词";
            search_icon_visible: false;
            actionKeyLabel: "转到";
            inputMethodHints: Qt.ImhNoAutoUppercase;
            onReturnPressed: {
                if (text.length === 0) return;
                searchBtn.clicked();
            }
        }

        Button {
            id: searchBtn;
            anchors {
                right: parent.right; rightMargin: constant.paddingMedium;
                top: title.bottom;
                bottom: parent.bottom;
                //verticalCenter: parent.verticalCenter;
            }
            z: 2;
            width: height;
            //text: "转到";
            iconSource: privateStyle.toolBarIconPath("toolbar-mediacontrol-play");
            onClicked: {
                if (searchInput.text.length === 0) return;
                searchInput.make_blur();
                go_to_url(searchInput.text);
            }
        }

        ProgressBar{
            id:progressbar;
            anchors{
                leftMargin: constant.paddingLarge;
                rightMargin: constant.paddingLarge;
                left: parent.left;
                right: parent.right;
                verticalCenter: parent.bottom;
            }
            z: -1;
            maximumValue : 1;
            minimumValue : 0;
            value: webView.progress;
            visible: value !== 1.0;
        }
    }
    Item{
        anchors.fill: parent;
        anchors.topMargin: viewHeader.height;
        Slider{
            id: hslider;
            anchors{
                bottom: parent.bottom;
                left: parent.left;
                right: vslider.left;
            }
            z: 2;
            minimumValue: 0;
            maximumValue: Math.max(view.contentWidth - view.width, 0);
            visible: acsettings.browserHelper;
            stepSize: 1;
            value: view.contentX;
            height: visible ? 45 : 0;
            onValueChanged:{
                if(pressed){
                    view.contentX = value;
                }
            }
        }

        Slider{
            id: vslider;
            anchors{
                top: parent.top;
                bottom: hslider.top;
                right: parent.right;
            }
            z: 2;
            stepSize: 1;
            inverted: true;
            width: visible ? 45 : 0;
            visible: acsettings.browserHelper;
            minimumValue: 0;
            maximumValue: Math.max(view.contentHeight - view.height, 0);
            value: view.contentY;
            orientation: Qt.Vertical;
            onValueChanged:{
                if(pressed){
                    view.contentY = value;
                }
            }
        }

        Flickable {
            id: view;
            anchors.top: parent.top;
            anchors.bottom: hslider.top;
            anchors.left: parent.left;
            anchors.right: vslider.left;
            clip: true;
            contentWidth: webView.width;
            contentHeight: webView.height;
            boundsBehavior: Flickable.StopAtBounds;
            WebView {
                id: webView;
                preferredWidth: Math.max(view.width, 0);
                preferredHeight: Math.max(view.height, 0);
                // begin(11 c)
                settings {
                    autoLoadImages: acsettings.browserLoadImage;
                }
                // end(11 c)
                onLoadStarted: {
                    page.loading = true;
                    view.contentX = 0;
                    view.contentY = 0;
                    view.returnToBounds();
                }
                onLoadFinished: page.loading = false;
                onLoadFailed: page.loading = false;
                onLinkClicked: {
                    if(acsettings.browserAutoHandleUrl)
                    {
                        handle(link);
                    }
                    else
                    {
                        webView.url = link;
                    }
                }
                // begin(11 c)
                onUrlChanged: {
                    searchInput.text = url.toString();
                }
                contentsScale: 1;
                Keys.onLeftPressed: webView.contentsScale -= 0.1;
                Keys.onRightPressed: webView.contentsScale += 0.1;

                onAlert: {
                    signalCenter.showMessage(message);
                }
                onZoomTo: doZoom(zoom,centerX,centerY)
                onContentsSizeChanged: {
                    contentsScale = Math.min(1,view.width / contentsSize.width)
                }
                onDoubleClick: {
                    if (!heuristicZoom(clickX,clickY,2.5)) {
                        var zf = view.width / contentsSize.width
                        if (zf >= contentsScale)
                            zf = 2.0*contentsScale // zoom in (else zooming out)
                        doZoom(zf,clickX*zf,clickY*zf)
                    }
                }
                function doZoom(zoom,centerX,centerY)
                {
                    if (centerX) {
                        var sc = zoom*contentsScale;
                        scaleAnim.to = sc;
                        flickVX.from = view.contentX
                        flickVX.to = Math.max(0,Math.min(centerX-view.width/2,webView.width*sc-view.width))
                        finalX.value = flickVX.to
                        flickVY.from = view.contentY
                        flickVY.to = Math.max(0,Math.min(centerY-view.height/2,webView.height*sc-view.height))
                        finalY.value = flickVY.to
                        quickZoom.start()
                    }
                }
                // end(11 c)
            }
            // begin(11 a)
            SequentialAnimation {
                id: quickZoom

                PropertyAction {
                    target: webView
                    property: "renderingEnabled"
                    value: false
                }
                ParallelAnimation {
                    NumberAnimation {
                        id: scaleAnim
                        target: webView
                        property: "contentsScale"
                        easing.type: Easing.Linear
                        duration: 200
                    }
                    NumberAnimation {
                        id: flickVX
                        target: view
                        property: "contentX"
                        easing.type: Easing.Linear
                        duration: 200
                        from: 0
                        to: 0
                    }
                    NumberAnimation {
                        id: flickVY
                        target: view
                        property: "contentY"
                        easing.type: Easing.Linear
                        duration: 200
                        from: 0
                        to: 0
                    }
                }
                PropertyAction {
                    id: finalX
                    target: view
                    property: "contentX"
                    value: 0
                }
                PropertyAction {
                    id: finalY
                    target: view
                    property: "contentY"
                    value: 0
                }
                PropertyAction {
                    target: webView
                    property: "renderingEnabled"
                    value: true
                }
            }
            // end(11 a)
        }
        ScrollDecorator { flickableItem: view; }
    }

    // end(11 c)

    // begin(11 a)
    CircleMenu{
        id: circle_menu;
        radius: 240;
        center_radius: 120;
        animation_duration: 200;
        x: parent.width - width - constant.paddingMedium;
        y: parent.height - height - constant.paddingMedium;
        z: 2;
        tools: CircleMenuLayout{
            auto_scale_items: true;
            out_circle_radius: circle_menu.radius;
            in_circle_radius: circle_menu.center_radius;
            ToolIcon {
                platformIconId: "toolbar-settings";
                onClicked: pageStack.push(Qt.resolvedUrl("../SettingPage.qml"));
            }
            ToolIcon {
                platformIconId: "toolbar-add";
                onClicked: {
                    webView.contentsScale += 0.1;
                }
            }
            ToolIcon {
                //platformIconId: "toolbar-add";
                Text{
                    anchors.fill: parent;
                    text: "—";
                    horizontalAlignment: Text.AlignHCenter;
                    verticalAlignment: Text.AlignVCenter;
                    font.weight: Font.Black;
                    font.pixelSize: 32;
                    font.family: constant.titleFont.family;
                }
                onClicked: {
                    webView.contentsScale -= 0.1;
                }
            }
            ToolIcon {
                platformIconId: "../../gfx/edit.svg";
                //enabled: !acsettings.browserAutoHandleUrl;
                onClicked: {
                    if(handle(webView.url))
                    {
                        signalCenter.showMessage("不支持的Url -> " + webView.url);
                    }
                }
            }
            ToolIcon {
                platformIconId: "toolbar-home";
                onClicked: {
                    webView.url = Qt.resolvedUrl(page.c_HOME);
                }
            }
            ToolIcon {
                platformIconId: "toolbar-search";
                onClicked: {
                    utility.openURLDefault(webView.url);
                }
            }
        }
    }
    onStatusChanged: {
        if(status !== PageStatus.Active && circle_menu.opened)
        {
            circle_menu.close();
        }
    }
}
