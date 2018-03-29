#include "utility.h"
#include "acnetworkaccessmanagerfactory.h"
#include <QtXml/QDomDocument>

#ifdef Q_OS_SYMBIAN
#include <apgcli.h>
#include <apgtask.h>
#include <w32std.h>
#endif

#ifdef Q_OS_HARMATTAN
#include <maemo-meegotouch-interfaces/videosuiteinterface.h>
#include <maemo-meegotouch-interfaces/shareuiinterface.h>
#include <MDataUri>
#endif

// begin(11 c)
#include "netlizard_string_converter.h"

// login
#define USERNAME "username"
#define USERPWD "userpwd"
#define SAVE_USER_LOGIN_INFO "save_user_login_info"

// browser
#define ACCEPT_LOGIN_STATEMENT "accept_login_statement"
#define BROWSER_LOAD_IMAGE "browser_load_image"
#define BROWSER_HELPER "browser_helper"
#define BROWSER_AURO_HANDLE_URL "browser_auto_handle_url"

// player
#define PLAYER_SHOW_DANMU "player_show_danmu"
#define PLAYER_DANMU_OPACITY "player_danmu_opacity"
#define PLAYER_DANMU_SPEED "player_danmu_speed"
#define PLAYER_DANMU_FACTORY "player_danmu_factory"

#define PLAYER_DANMU_OPACITY_RANGE "player_danmu_opacity_range"
#define PLAYER_DANMU_SPEED_RANGE "player_danmu_speed_range"
#define PLAYER_DANMU_FACTORY_RANGE "player_danmu_factory_range"
#define APP_RC "app_rc"

#define USE_EXTERNALLY_BROWSER "use_externally_browser"
#define ARTICLE_LOAD_IMAGE "article_load_image"

#define RANGE_MIN "min"
#define RANGE_MAX "max"
#define RANGE_STEP "step"

#define REPAIRED "repaired"
#define KARIN_REPAIRED 11

#define USER_INFO_SPLIT ","

#define APP_VERSION_DEFAULT "5.0.0"
#define MARKET_DEFAULT "portal"
#define DEVICE_TYPE_DEFAULT "1"
#define USER_AGENT_DEFAULT "acvideo core/5.0.0(Nokia;TA-1041;7.1.1)"

#define RC_DEVELOPER_NAME "r_developer"
#define RC_RELEASED_NAME "r_released"
#define RC_VERSION_NAME "r_version"
#define RC_CODE_NAME "r_code"
#define RC_AC_NAME "r_ac"
#define RC_RP_NAME "r_rp"
#define RC_DEVELOPER "Karin"
#define RC_RELEASED "2018.03.27"
#define RC_VERSION "2.4.1rjinx11"
#define RC_CODE "jinx"
#define RC_AC QString::fromUtf8("香磷")
#define RC_RP "11"
// end(11 c)

Utility::Utility(QObject *parent) :
    QObject(parent),
    settings(0)
{
    settings = new QSettings(this);
		// begin(11 c)
		setValue(DEVICE_TYPE, getValue(DEVICE_TYPE, QVariant(DEVICE_TYPE_DEFAULT)));
		setValue(MARKET, getValue(MARKET, QVariant(MARKET_DEFAULT)));
		setValue(APP_VERSION, getValue(APP_VERSION, QVariant(APP_VERSION_DEFAULT)));
		setValue(USER_AGENT, getValue(USER_AGENT, QVariant(USER_AGENT_DEFAULT)));
		// end(11 c)
}

Utility::~Utility()
{
}

Utility* Utility::Instance()
{
    static Utility u;
    return &u;
}

QString Utility::appVersion() const
{
    return qApp->applicationVersion();
}

int Utility::qtVersion() const
{
    QString qtver(qVersion());
    QStringList vlist = qtver.split(".");
    if (vlist.length() >= 3){
        int major = vlist.at(0).toInt();
        int minor = vlist.at(1).toInt();
        int patch = vlist.at(2).toInt();
        return (major << 16) + (minor << 8) + patch;
    } else {
        return 0;
    }
}

QVariant Utility::getValue(const QString &key, const QVariant defaultValue)
{
    if (map.contains(key)){
        return map.value(key);
    } else {
        return settings->value(key, defaultValue);
    }
}

void Utility::setValue(const QString &key, const QVariant &value)
{
    if (map.value(key) != value){
        map.insert(key, value);
        settings->setValue(key, value);
    }
}

void Utility::clearCookies()
{
    ACNetworkCookieJar::GetInstance()->clearCookies();
}

QString Utility::urlQueryItemValue(const QString &url, const QString &key) const
{
    QUrl myUrl(url);
    return myUrl.queryItemValue(key);
}

QString Utility::domNodeValue(const QString &data, const QString &tagName)
{
    QDomDocument doc;
    if (doc.setContent(data)){
        QDomElement element = doc.documentElement();
        QDomNodeList list = element.elementsByTagName(tagName);
        for (uint i=0; i<list.length(); i++){
            QDomElement e = list.at(i).toElement();
            if (!e.isNull()){
                return e.text();
            }
        }
    }
    return QString();
}

void Utility::launchPlayer(const QString &url)
{
#ifdef Q_OS_SYMBIAN
    //    const int KMpxVideoPlayerID = 0x200159B2;
    //    Launch(KMpxVideoPlayerID, url);
    QString path = QDir::tempPath();
    QDir dir(path);
    if (!dir.exists()) dir.mkpath(path);
    QString ramPath = path+"/video.ram";
    QFile file(ramPath);
    if (file.exists()) file.remove();
    if (file.open(QIODevice::ReadWrite)){
        QTextStream out(&file);
        out << url;
        file.close();
        QDesktopServices::openUrl(QUrl("file:///"+ramPath));
    }
#elif defined(Q_OS_HARMATTAN)
    VideoSuiteInterface suite;
    QStringList list = url.split("\n");
    suite.play(list);
#elif defined(Q_WS_SIMULATOR)
    qDebug() << url;
#else
    QDesktopServices::openUrl(url);
#endif
}

void Utility::openURLDefault(const QString &url)
{
#ifdef Q_OS_SYMBIAN
    TRAP_IGNORE(LaunchL(0x10008D39, "4 "+url));
#elif defined(Q_WS_SIMULATOR)
    qDebug() << "Open browser:" << url;
#else
    QDesktopServices::openUrl(QUrl(url));
#endif
}

void Utility::openHtml(const QString &html)
{
    QString path = QDir::tempPath();
    QDir dir(path);
    if (!dir.exists()) dir.mkpath(path);
    QString htmlPath = path + "/temp.html";
    QFile file(htmlPath);
    if (file.exists()) file.remove();
    if (file.open(QIODevice::ReadWrite)){
        QTextStream out(&file);
        out << html;
        file.close();
        QDesktopServices::openUrl(QUrl("file:///"+htmlPath));
    }
}

void Utility::share(const QString &title, const QString &link)
{
#ifdef Q_OS_HARMATTAN
    MDataUri duri;
    duri.setMimeType("text/x-url");
    duri.setTextData(link);
    duri.setAttribute("title", title);
    if (!duri.isValid()){
        qDebug() << "Share: Invalid URI";
        return;
    }
    QStringList items;
    items << duri.toString();
    ShareUiInterface shareIf("com.nokia.ShareUi");
    if (!shareIf.isValid()){
        qDebug() << "Share: Invalid interface";
        return;
    }
    shareIf.share(items);
#else
#endif
}

QString Utility::easyDate(const QDateTime &date)
{
    if (formats.length() == 0) initializeLangFormats();

    QDateTime now = QDateTime::currentDateTime();
    int secsDiff = date.secsTo(now);

    QString token;
    if (secsDiff < 0){
        secsDiff = abs(secsDiff);
        token = lang["from"];
    } else {
        token = lang["ago"];
    }

    QString result;
    foreach (QVariantList format, formats) {
        if (secsDiff < format.at(0).toInt()){
            if (format == formats.at(0)){
                result = format.at(1).toString();
            } else {
                int val = ceil(double(normalize(secsDiff, format.at(3).toInt()))/format.at(3).toInt());
                result = tr("%1 %2 %3", "e.g. %1 is number value such as 2, %2 is mins, %3 is ago")
                        .arg(QString::number(val)).arg(val != 1 ? format.at(2).toString() : format.at(1).toString()).arg(token);
            }
            break;
        }
    }
    return result;
}

void Utility::initializeLangFormats()
{
    lang["ago"] = tr("ago");
    lang["from"] = tr("From Now");
    lang["now"] = tr("just now");
    lang["minute"] = tr("min");
    lang["minutes"] = tr("mins");
    lang["hour"] = tr("hr");
    lang["hours"] = tr("hrs");
    lang["day"] = tr("day");
    lang["days"] = tr("days");
    lang["week"] = tr("wk");
    lang["weeks"] = tr("wks");
    lang["month"] = tr("mth");
    lang["months"] = tr("mths");
    lang["year"] = tr("yr");
    lang["years"] = tr("yrs");

    QVariantList l1;
    l1 << 60 << lang["now"];
    QVariantList l2;
    l2 << 3600 << lang["minute"] << lang["minutes"] << 60;
    QVariantList l3;
    l3 << 86400 << lang["hour"] << lang["hours"] << 3600;
    QVariantList l4;
    l4 << 604800 << lang["day"] << lang["days"] << 86400;
    QVariantList l5;
    l5 << 2628000 << lang["week"] << lang["weeks"] << 604800;
    QVariantList l6;
    l6 << 31536000 << lang["month"] << lang["months"] << 2628000;
    QVariantList l7;
    l7 << INT_MAX << lang["year"] << lang["years"] << 31536000;

    formats << l1 << l2 << l3 << l4 << l5 << l6 << l7;
}

int Utility::normalize(int val, int single)
{
    int margin = 0.1;
    if (val >= single && val <= single*(1+margin))
        return single;
    return val;
}

#ifdef Q_OS_SYMBIAN
void Utility::LaunchAppL(const TUid aUid, HBufC* aParam)
{
    RWsSession ws;
    User::LeaveIfError(ws.Connect());
    CleanupClosePushL(ws);
    TApaTaskList taskList(ws);
    TApaTask task = taskList.FindApp(aUid);

    if(task.Exists())
    {
        task.BringToForeground();
        HBufC8* param8 = HBufC8::NewLC(aParam->Length());
        param8->Des().Append(*aParam);
        task.SendMessage(TUid::Null(), *param8); // UID not used, SwEvent capability need to be declared
        CleanupStack::PopAndDestroy(param8);
    }
    else
    {
        RApaLsSession apaLsSession;
        User::LeaveIfError(apaLsSession.Connect());
        CleanupClosePushL(apaLsSession);
        TThreadId thread;
        User::LeaveIfError(apaLsSession.StartDocument(*aParam, aUid, thread));
        CleanupStack::PopAndDestroy(1, &apaLsSession);
    }
    CleanupStack::PopAndDestroy(&ws);
}
void Utility::LaunchL(int id, const QString& param)
{
    //Coversion to Symbian C++ types
    TUid uid = TUid::Uid(id);
    TPtrC ptr(static_cast<const TUint16*>(param.utf16()), param.length());
    HBufC* desc_param = HBufC::NewLC( param.length());
    desc_param->Des().Copy(ptr);

    LaunchAppL(uid, desc_param);

    CleanupStack::PopAndDestroy(desc_param);
}
bool Utility::Launch(const int id, const QString& param)
{
    // TRAPD to prevent possible leave (kind of exception in Symbian C++)
    TRAPD(err, LaunchL(id, param));
    return err == KErrNone;
}
#endif

// begin(11 a)
void Utility::copy_to_clipboard(const QString &text) const
{
	QApplication::clipboard() -> setText(text);
}

QVariant Utility::get_user_login_info() const
{
	QString username = settings -> value(USERNAME).toString();
	QString pwd = settings -> value(USERPWD).toString();
	QVariantMap map;
	QString name_string("");
	QString pwd_string("");
	if(!username.isEmpty())
	{
		char *name_str = NULL;
		Converter_DecodeIntStringToString(username.toLocal8Bit().data(), USER_INFO_SPLIT, &name_str);
		name_string = QString::fromLocal8Bit(name_str);
		free(name_str);
	}
	if(!pwd.isEmpty())
	{
		char *pwd_str = NULL;
		Converter_DecodeIntStringToString(pwd.toLocal8Bit().data(), USER_INFO_SPLIT, &pwd_str);
		pwd_string = QString::fromLocal8Bit(pwd_str);
		free(pwd_str);
	}
	map.insert(USERNAME, QVariant(name_string));
	map.insert(USERPWD, QVariant(pwd_string));
	return map;
}

void Utility::set_user_login_info(const QString &username, const QString &pwd)
{
	if(username.isEmpty() || pwd.isEmpty())
	{
		settings -> setValue(USERNAME, QVariant(""));
		settings -> setValue(USERPWD, QVariant(""));
		return;
	}
	char *name_str = NULL;
	Converter_EncodeStringToIntString(username.toLocal8Bit().data(), USER_INFO_SPLIT, &name_str);
	char *pwd_str = NULL;
	Converter_EncodeStringToIntString(pwd.toLocal8Bit().data(), USER_INFO_SPLIT, &pwd_str);

	settings -> setValue(USERNAME, QVariant(QString(name_str)));
	settings -> setValue(USERPWD, QVariant(QString(pwd_str)));

	free(name_str);
	free(pwd_str);
}

void Utility::sign_in()
{
    ACNetworkCookieJar::GetInstance()->save();
}

void Utility::sign_out()
{
    ACNetworkCookieJar::GetInstance()->clearCookies();
		QByteArray data;
    setValue("Cookies", data);
}

void Utility::reset_header_setting()
{
		setValue(DEVICE_TYPE, QVariant(DEVICE_TYPE_DEFAULT));
		setValue(MARKET, QVariant(MARKET_DEFAULT));
		setValue(APP_VERSION, QVariant(APP_VERSION_DEFAULT));
		setValue(USER_AGENT, QVariant(USER_AGENT_DEFAULT));
}

bool Utility::is_update()
{
	bool n = false;
	if(!settings -> contains(REPAIRED))
		n = true;
	else
	{
		QVariant v = settings -> value(REPAIRED);
		QString ver = v.toString();
		if(ver < QString(KARIN_REPAIRED))
			n = true;
	}
	if(n)
		settings -> setValue(REPAIRED, QVariant(KARIN_REPAIRED));
	return n;
}

QVariant Utility::get_constant(const QString &name) const
{
	QVariantMap map;
#define __MAKE_RANGE_MAP(n, min, max, step) \
	if(name == n) \
	{ \
		map.insert(RANGE_MIN, QVariant(min)); \
		map.insert(RANGE_MAX, QVariant(max)); \
		map.insert(RANGE_STEP, QVariant(step)); \
	}
	__MAKE_RANGE_MAP(PLAYER_DANMU_OPACITY_RANGE, 0.1, 1.0, 0.1)
	else __MAKE_RANGE_MAP(PLAYER_DANMU_SPEED_RANGE, 0.5, 2.0, 0.1)
	else __MAKE_RANGE_MAP(PLAYER_DANMU_FACTORY_RANGE, 0.2, 2.0, 0.1)
	else if(name == APP_RC)
	{
		map.insert(RC_DEVELOPER_NAME, QVariant(RC_DEVELOPER));
		map.insert(RC_VERSION_NAME, QVariant(RC_VERSION));
		map.insert(RC_RELEASED_NAME, QVariant(RC_RELEASED));
		map.insert(RC_CODE_NAME, QVariant(RC_CODE));
		map.insert(RC_AC_NAME, QVariant(RC_AC));
		map.insert(RC_RP_NAME, QVariant(RC_RP));
	}
	return map;
#undef __MAKE_RANGE_MAP
}

QVariant Utility::urlparse(const QString &u) const
{
	QUrl url(u);
	QVariantMap map;
	map.insert("scheme", url.scheme());
	map.insert("host", url.host());
	map.insert("path", url.path());
	map.insert("password", url.password());
	map.insert("userName", url.userName());
	map.insert("port", url.port());
	QVariantMap m;
	QList<QPair<QString, QString> > querys = url.queryItems();
	for(QList<QPair<QString, QString> >::const_iterator itor = querys.begin();
			itor != querys.end();
			++itor)
	{
		m.insert(itor -> first, itor -> second);
	}
	map.insert("queryItems", m);
	return map;
}

bool Utility::exec(const QString &cmd) const
{
	if(cmd.isEmpty())
		return false;
	return QProcess::startDetached(cmd);
}

void Utility::weibo_share(const QString &title, const QString &link, const QString &pic)
{
	QString url = QString("http://service.weibo.com/share/share.php?url=%1&type=3&title=%2&pic=%3").arg(link).arg(title).arg(pic);
	openURLDefault(url);
}
// end(11 a)
