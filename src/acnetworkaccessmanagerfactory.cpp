#include "acnetworkaccessmanagerfactory.h"
#include "utility.h"

ACNetworkAccessManagerFactory::ACNetworkAccessManagerFactory() :
    QDeclarativeNetworkAccessManagerFactory()
{
}

QNetworkAccessManager* ACNetworkAccessManagerFactory::create(QObject *parent)
{
    QMutexLocker lock(&mutex);
    Q_UNUSED(lock);
    QNetworkAccessManager* manager = new ACNetworkAccessManager(parent);

    QNetworkCookieJar* cookieJar = ACNetworkCookieJar::GetInstance();
    manager->setCookieJar(cookieJar);
    cookieJar->setParent(0);

    return manager;
}

ACNetworkAccessManager::ACNetworkAccessManager(QObject *parent) :
    QNetworkAccessManager(parent)
{
}

QNetworkReply *ACNetworkAccessManager::createRequest(Operation op, const QNetworkRequest &request, QIODevice *outgoingData)
{
    QNetworkRequest req(request);
		// begin(11 c)

#ifndef Q_OS_HARMATTAN
    if(req.url().scheme() == "https")
    {
        QSslConfiguration config;
        config.setPeerVerifyMode(QSslSocket::VerifyNone);
        config.setProtocol(QSsl::TlsV1);
        req.setSslConfiguration(config);
    }
#endif
    QString host = request.url().host();
    if(host == "play.youku.com" || host == "k.youku.com" || host == "ups.youku.com" || host == "vali.cp31.ott.cibntv.net") // 2018-1
    {
        //request.setAttribute(QNetworkRequest::CookieLoadControlAttribute, QNetworkRequest::Manual);
        req.setRawHeader("Referer", "http://v.youku.com"); // 2018-1
        req.setRawHeader("User-Agent",
						"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36" // 2018-1
    );
				// glBegin(2017)
        //QString s("__ysuid=" + QString::number(std::time(0))); // 2016
				//QString s(QString("__ysuid=%1%2").arg(QDateTime::currentMSecsSinceEpoch()).arg(100 + qrand() % (999 - 100)));
				//qDebug()<<s;
        //request.setRawHeader("Cookie", s.toAscii());
				// glEnd()
    }
		else
		{
			/*
			qDebug()<<Utility::Instance()->getValue(USER_AGENT).toByteArray();
			qDebug()<<Utility::Instance()->getValue(DEVICE_TYPE).toByteArray();
			qDebug()<<Utility::Instance()->getValue(MARKET).toByteArray();
			qDebug()<<Utility::Instance()->getValue(APP_VERSION).toByteArray();
			*/
			req.setRawHeader("User-Agent", Utility::Instance()->getValue(USER_AGENT).toByteArray());
			req.setRawHeader("deviceType", Utility::Instance()->getValue(DEVICE_TYPE).toByteArray());
			req.setRawHeader("market", Utility::Instance()->getValue(MARKET).toByteArray());
			req.setRawHeader("appVersion", Utility::Instance()->getValue(APP_VERSION).toByteArray());
			if(host == "player.acfun.cn")
			{
				QUrl new_url(request.url());
				QList<QPair<QString, QString> >query_items = new_url.queryItems();
				for(QList<QPair<QString, QString> >::iterator itor = query_items.begin();
						itor != query_items.end();
						++itor)
				{
					if(itor -> first == "referer")
					{
						QString referer = itor -> second;
						query_items.erase(itor);
						new_url.setQueryItems(query_items);
						req.setUrl(new_url);
						QByteArray bytes;
						bytes.append(referer);
						req.setRawHeader("Referer", bytes);
						break;
					}
				}
			}
		}
		// end(11 c)
    QNetworkReply *reply = QNetworkAccessManager::createRequest(op, req, outgoingData);
    return reply;
}

ACNetworkCookieJar::ACNetworkCookieJar(QObject *parent) :
    QNetworkCookieJar(parent)
{
    load();
}

ACNetworkCookieJar::~ACNetworkCookieJar()
{
    save();
}

ACNetworkCookieJar* ACNetworkCookieJar::GetInstance()
{
    static ACNetworkCookieJar cookieJar;
    return &cookieJar;
}

void ACNetworkCookieJar::clearCookies()
{
    QList<QNetworkCookie> emptyList;
    setAllCookies(emptyList);
}

QList<QNetworkCookie> ACNetworkCookieJar::cookiesForUrl(const QUrl &url) const
{
    QMutexLocker lock(&mutex);
    Q_UNUSED(lock);
    return QNetworkCookieJar::cookiesForUrl(url);
}

bool ACNetworkCookieJar::setCookiesFromUrl(const QList<QNetworkCookie> &cookieList, const QUrl &url)
{
    QMutexLocker lock(&mutex);
    Q_UNUSED(lock);
    return QNetworkCookieJar::setCookiesFromUrl(cookieList, url);
}

void ACNetworkCookieJar::save()
{
    QMutexLocker lock(&mutex);
    Q_UNUSED(lock);
    QList<QNetworkCookie> list = allCookies();
    QByteArray data;
    foreach (QNetworkCookie cookie, list) {
			// begin(11 c)
        if (true || !cookie.isSessionCookie()){
					// end(11 c)
            data.append(cookie.toRawForm());
            data.append("\n");
        }
    }
    Utility::Instance()->setValue("Cookies", data);
}

void ACNetworkCookieJar::load()
{
    QMutexLocker lock(&mutex);
    Q_UNUSED(lock);
    QByteArray data = Utility::Instance()->getValue("Cookies").toByteArray();
    setAllCookies(QNetworkCookie::parseCookies(data));
}
