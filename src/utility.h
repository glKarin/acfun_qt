#ifndef UTILITY_H
#define UTILITY_H

#include <QtDeclarative>

// begin(11 a)
// request header
#define APP_VERSION "appVersion"
#define MARKET "market"
#define DEVICE_TYPE "deviceType"
#define USER_AGENT "user_agent"
// end(11 a)

class Utility : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString appVersion READ appVersion CONSTANT)
    Q_PROPERTY(int qtVersion READ qtVersion CONSTANT)
public:
    static Utility* Instance();
    ~Utility();

    QString appVersion() const;
    int qtVersion() const;

public:
    // Save and load settings.
    Q_INVOKABLE QVariant getValue(const QString &key, const QVariant defaultValue = QVariant());
    Q_INVOKABLE void setValue(const QString &key, const QVariant &value);

    // Clear network cookies in qml
    Q_INVOKABLE void clearCookies();

    // Get url parameters
    Q_INVOKABLE QString urlQueryItemValue(const QString &url, const QString &key) const;

    // Launch player using built-in player
    Q_INVOKABLE void launchPlayer(const QString &url);

    // Share links using share ui
    Q_INVOKABLE void share(const QString &title, const QString &link);

    // Open html using default browser
    Q_INVOKABLE void openHtml(const QString &html);

    // Make date readable
    Q_INVOKABLE QString easyDate(const QDateTime &date);

    // Parse XML text
    Q_INVOKABLE QString domNodeValue(const QString &data, const QString &tagName);

    // Launch built-in browser
    Q_INVOKABLE void openURLDefault(const QString &url);

		// begin(11 a)
		// copy output for debug
    Q_INVOKABLE void copy_to_clipboard(const QString &text) const;
    Q_INVOKABLE QVariant get_user_login_info() const;
    Q_INVOKABLE void set_user_login_info(const QString &username, const QString &pwd);
		Q_INVOKABLE void sign_out();
		Q_INVOKABLE void sign_in();
		Q_INVOKABLE void reset_header_setting();
		Q_INVOKABLE bool is_update();
		Q_INVOKABLE QVariant get_constant(const QString &name) const;
		Q_INVOKABLE QVariant urlparse(const QString &url) const;
    Q_INVOKABLE bool exec(const QString &cmd) const;
    Q_INVOKABLE void weibo_share(const QString &title, const QString &link, const QString &pic);
		// end(11 a)

private:
    explicit Utility(QObject *parent = 0);

    QSettings* settings;
    QVariantMap map;

    QHash<QString, QString> lang;
    QList<QVariantList> formats;
    void initializeLangFormats();
    int normalize(int val, int single);

#ifdef Q_OS_SYMBIAN
    void LaunchAppL(const TUid aUid, HBufC* aParam);
    void LaunchL(int id, const QString& param);
    bool Launch(const int id, const QString& param);
#endif
};

#endif // UTILITY_H
