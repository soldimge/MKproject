#include <QtCore/QUrl>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml/QQmlContext>

#include "btcore.h"
#include "tablemodel.h"

//#include "QtAndroidTools.h"
//#include "keepawake.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

//    KeepAwake lock;

//    QtAndroidTools::initializeQmlTools();

    qmlRegisterType<TableModel>("TableModel", 0, 1, "TableModel");

    BTcore backEnd;

    QQmlApplicationEngine engine;
    QQmlContext *context = engine.rootContext();

    context->setContextProperty("backEnd", &backEnd);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
