#include <QtCore/QUrl>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml/QQmlContext>
#include "statusbar.h"
#include "appcore.h"

#ifdef Q_OS_ANDROID
#include "keepawake.h"
//#include "QtAndroidTools.h"
#endif

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

#ifdef Q_OS_ANDROID
    KeepAwake lock;
#endif
    qmlRegisterType<StatusBar>("StatusBar", 0, 1, "StatusBar");
//    QtAndroidTools::initializeQmlTools();

    app.setOrganizationName("Laser");
    app.setOrganizationDomain("soldimge@gmail.com");
    app.setApplicationName("Laser Application");

    AppCore backEnd;

    QQmlApplicationEngine engine;
    QQmlContext *context = engine.rootContext();

    context->setContextProperty("backEnd", &backEnd);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
