#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QBluetoothDeviceDiscoveryAgent>
#include <QBluetoothSocket>
#include <QClipboard>
#include <QGuiApplication>
#include <QCoreApplication>
#include <QTime>
#include <map>

#include "wakecore.h"

constexpr qint32 PAUSE_MS{20};
constexpr qint32 TIMEOUT_MS{1000};

class AppCore : public QObject
{
    Q_OBJECT

public:
    AppCore(QObject *parent = nullptr);
    ~AppCore();
    Q_INVOKABLE void on_pushButton_Connect_clicked();
    Q_INVOKABLE void on_pushButton_Search_clicked();
    Q_INVOKABLE void connect_toDevice_clicked(QString);
    Q_INVOKABLE void on_pushButton_Disconnect_clicked();
    Q_INVOKABLE void sendMessageToDevice(QString, QString, qint16);
    Q_INVOKABLE void copyToBuffer(QString);

private slots:
    void captureDeviceProperties(const QBluetoothDeviceInfo &device);
    void searchFinished();
    void connectionEstablished();
    void connectionInterrupted();
    void sockectReadyToRead();

signals:
    void sendToQml(QString mes);
    void addDevice(QString name);
    void endOfSearch();
    void addLog(QString log);

private:
    QBluetoothDeviceDiscoveryAgent *_discoveryAgent;
    QBluetoothSocket *_socket;
    std::map<QString, QString> _btdevices;
    WakeCore _wake;
    bool _reqIsActive;
    uint8_t _reqCmd;
    QByteArray _answer;
    QClipboard* _clipboard;

    QByteArray sentCommand(uint8_t cmd, QByteArray data, uint8_t addr = 0);
    void addToLogs(QString);
};
#endif // MAINWINDOW_H
