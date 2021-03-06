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
#include <QAndroidJniObject>
#include <QAndroidIntent>
#include <QtAndroid>
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
    Q_INVOKABLE void btSearch();
    Q_INVOKABLE void connectToDevice(QString);
    Q_INVOKABLE void btDisconnect();
    Q_INVOKABLE void sendMessageToDevice(QString, QString, qint16);
    Q_INVOKABLE void copyToBuffer(QString);
    Q_INVOKABLE void setAppSettings(bool, bool);
    Q_INVOKABLE void setCmdType(qint16);
    Q_INVOKABLE void setPauseMS(quint16);
    Q_INVOKABLE void setTimeoutMS(quint32);
#ifdef Q_OS_ANDROID
    Q_INVOKABLE void openSystemBluetoothSettings();
    Q_INVOKABLE void openSystemLocationSettings();
#endif

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
    void addMes(QString message);
    void enableSendButton(bool condition);

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
    bool _isWakeOn;

#ifdef Q_OS_ANDROID
    QBluetoothLocalDevice *_localDevice;
    bool _btWasOn;
#endif

    QByteArray sendCommand(uint8_t cmd, QByteArray data, uint8_t addr = 0);
    void addToLogs(QString);
};

