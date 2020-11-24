#pragma once

#include <QBluetoothDeviceDiscoveryAgent>
#include <QBluetoothSocket>
#include <QClipboard>
#include <QGuiApplication>
#include <QCoreApplication>
#include <QTime>
#include <map>
#include <QSettings>
#include <mutex>

#include "wakecore.h"

#ifdef Q_OS_ANDROID
#include <QBluetoothLocalDevice>
#endif

constexpr qint32 PAUSE_MS{20};
constexpr qint32 TIMEOUT_MS{1000};

enum class CmdType
{
    ASCII,
    HEX,
    DEC
};

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
    Q_INVOKABLE void setAppSettings(bool);
    Q_INVOKABLE void setCmdType(qint16);
    Q_INVOKABLE void setPauseMS(quint16);
    Q_INVOKABLE void setTimeoutMS(quint32);

private slots:
    void captureDeviceProperties(const QBluetoothDeviceInfo &device);
    void searchFinished();
    void connectionEstablished();
    void connectionInterrupted();
    void sockectReadyToRead();
    void searchError(QBluetoothDeviceDiscoveryAgent::Error error);

signals:
    void sendToQml(QString mes);
    void addDevice(QString name);
    void endOfSearch();
    void addLog(QString log);
    void addMes(QString message);

private:
    QBluetoothDeviceDiscoveryAgent *_discoveryAgent;
    QBluetoothSocket *_socket;
    std::map<QString, std::pair<QString, qint16>> _btdevices;
    WakeCore _wake;
    bool _reqIsActive;
    uint8_t _reqAddr;
    uint8_t _reqCmd;
    QByteArray _answer;
    QClipboard* _clipboard;
    bool _msInLogs;
    CmdType _cmdType;
    QSettings _settings;
    std::mutex _mtx;
    quint16 _pauseMS;
    quint32 _timeoutMS;

#ifdef Q_OS_ANDROID
    QBluetoothLocalDevice *_localDevice;
    bool _btWasOn;
#endif

    QByteArray sendCommand(uint8_t cmd, QByteArray data, uint8_t addr = 0);
    void addToLogs(QString);
};

