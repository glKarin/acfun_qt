import QtQuick 1.1

QtObject {
    id: acsettings;

    property string accessToken: utility.getValue("accessToken","");
    onAccessTokenChanged: utility.setValue("accessToken", accessToken);

    property double expiresBy: utility.getValue("expiresBy", 0);
    onExpiresByChanged: utility.setValue("expiresBy", expiresBy);

    property string userId: utility.getValue("userId","");
    onUserIdChanged: utility.setValue("userId", userId);

    property bool usePlatformPlayer: utility.qtVersion < 0x040800 ||
                                     utility.getValue("usePlatformPlayer", true);
    onUsePlatformPlayerChanged: utility.setValue("usePlatformPlayer", usePlatformPlayer);

    property bool showFirstHelp: utility.getValue("showFirstHelp", true);
    onShowFirstHelpChanged: utility.setValue("showFirstHelp", showFirstHelp);

    // begin(11 a)
    // general
    property bool useExternallyBrowser: utility.getValue("use_externally_browser", true);
    onUseExternallyBrowserChanged: utility.setValue("use_externally_browser", useExternallyBrowser);
    property bool articleLoadImage: utility.getValue("article_load_image", true);
    onArticleLoadImageChanged: utility.setValue("article_load_image", articleLoadImage);

    // login
    property bool saveUserLoginInfo: utility.getValue("save_user_login_info", false);
    onSaveUserLoginInfoChanged: utility.setValue("save_user_login_info", saveUserLoginInfo);

    property string acceptLoginStatement: utility.getValue("accept_login_statement","");
    onAcceptLoginStatementChanged: utility.setValue("accept_login_statement", acceptLoginStatement);

    // request header
    property string deviceType: utility.getValue("deviceType", "");
    onDeviceTypeChanged: utility.setValue("deviceType", deviceType);

    property string market: utility.getValue("market", "");
    onMarketChanged: utility.setValue("market", market);

    property string appVersion: utility.getValue("appVersion", "");
    onAppVersionChanged: utility.setValue("appVersion", appVersion);

    property string userAgent: utility.getValue("user_agent", "");
    onUserAgentChanged: utility.setValue("user_agent", userAgent);

    // browser
    property bool browserLoadImage: utility.getValue("browser_load_image", false);
    onBrowserLoadImageChanged: utility.setValue("browser_load_image", browserLoadImage);

    property bool browserHelper: utility.getValue("browser_helper", false);
    onBrowserHelperChanged: utility.setValue("browser_helper", browserHelper);

    property bool browserAutoHandleUrl: utility.getValue("browser_auto_handle_url", true);
    onBrowserAutoHandleUrlChanged: utility.setValue("browser_auto_handle_url", browserAutoHandleUrl);

    // player
    property bool playerShowDanmu: utility.getValue("player_show_danmu", true);
    onPlayerShowDanmuChanged: utility.setValue("player_show_danmu", playerShowDanmu);

    property real playerDanmuFactory: utility.getValue("player_danmu_factory", 1.0);
    onPlayerDanmuFactoryChanged: utility.setValue("player_danmu_factory", playerDanmuFactory);

    property real playerDanmuOpacity: utility.getValue("player_danmu_opacity", 1.0);
    onPlayerDanmuOpacityChanged: utility.setValue("player_danmu_opacity", playerDanmuOpacity);

    property real playerDanmuSpeed: utility.getValue("player_danmu_speed", 1.0);
    onPlayerDanmuSpeedChanged: utility.setValue("player_danmu_speed", playerDanmuSpeed);

    // constant
    property variant playerDanmuOpacityRange: utility.get_constant("player_danmu_opacity_range");

    property variant playerDanmuSpeedRange: utility.get_constant("player_danmu_speed_range");

    property variant playerDanmuFactoryRange: utility.get_constant("player_danmu_factory_range");
    property variant appRC: utility.get_constant("app_rc");
    // end(11 a)
}
