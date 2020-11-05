#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QBluetoothDeviceDiscoveryAgent>
#include <QBluetoothSocket>

#include <QCoreApplication>
#include <QTime>

class BTcore : public QObject
{
    Q_OBJECT

public:
    BTcore(QObject *parent = nullptr);
    ~BTcore();
    Q_INVOKABLE void on_pushButton_Connect_clicked();
    Q_INVOKABLE void on_pushButton_Search_clicked();
    Q_INVOKABLE void on_pushButton_Disconnect_clicked();
    Q_INVOKABLE void sendMessageToDevice(QString);
    Q_INVOKABLE void sendWakePackToDevice(uint8_t addr, uint8_t idCmd, QString message);

private slots:
    void captureDeviceProperties(const QBluetoothDeviceInfo &device);
    void searchFinished();
    void connectionEstablished();
    void connectionInterrupted();
    void sockectReadyToRead();


signals:
    void sendToQml(QString mes);

private:
    QBluetoothDeviceDiscoveryAgent *discoveryAgent;
    QBluetoothSocket *socket;
    void addToLogs(QString);
};
#endif // MAINWINDOW_H
