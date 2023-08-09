#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSettings>
#include <QQuickStyle>
#include <QDebug>

int main(int argc, char *argv[])
{
    QGuiApplication::setApplicationName("Tagatuos");
    QGuiApplication::setApplicationName("tagatuos2.kugiigi");
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QSettings settings;
    QString style = QQuickStyle::name();
    if (settings.contains("style")) {
        QQuickStyle::setStyle(settings.value("style").toString());
    }
    else {
        settings.setValue("style", "Suru");
        QQuickStyle::setStyle("Suru");
    }

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("availableStyles", QQuickStyle::availableStyles());
    engine.load(QUrl(QStringLiteral("qrc:///Main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
