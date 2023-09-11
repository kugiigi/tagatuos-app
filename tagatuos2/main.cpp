#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSettings>
#include <QQuickStyle>
#include <QDebug>

int main(int argc, char *argv[])
{
    QApplication::setApplicationName("Tagatuos");
    QApplication::setApplicationName("tagatuos2.kugiigi");

    QApplication app(argc, argv);

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
