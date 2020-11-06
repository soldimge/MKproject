#include "appcore.h"
#include "wakecore.h"

#include <QDebug>
#include <QDateTime>

void pause(qint32 ms)
{
    QTime pauseEnd = QTime::currentTime().addMSecs(ms);
    while (QTime::currentTime() < pauseEnd)
        QCoreApplication::processEvents(QEventLoop::AllEvents, 100);
}

AppCore::AppCore(QObject *parent) : QObject(parent)
{
    this->discoveryAgent = new QBluetoothDeviceDiscoveryAgent(this);
    this->socket = new QBluetoothSocket(QBluetoothServiceInfo::RfcommProtocol, this);

    connect(this->discoveryAgent, SIGNAL(deviceDiscovered(QBluetoothDeviceInfo)), this, SLOT(captureDeviceProperties(QBluetoothDeviceInfo)));
    connect(this->discoveryAgent, SIGNAL(finished()), this, SLOT(searchFinished()));

    connect(this->socket, SIGNAL(connected()), this, SLOT(connectionEstablished()));
    connect(this->socket, SIGNAL(disconnected()), this, SLOT(connectionInterrupted()));
    connect(this->socket, SIGNAL(readyRead()), this, SLOT(sockectReadyToRead()));
}

AppCore::~AppCore()
{
    on_pushButton_Disconnect_clicked();
    delete discoveryAgent;
}

void AppCore::captureDeviceProperties(const QBluetoothDeviceInfo &device)
{
//    ui->comboBox_Devices->addItem(device.name() + "  >>>  " + device.address().toString());
    qDebug() << "device found. name: " << device.name() << " and address: " << device.address().toString();
    this->addToLogs("device found...\n  name/address: " + device.name() + " / " + device.address().toString());
    btdevices[device.name()] = device.address().toString();
}

void AppCore::searchFinished()
{
    this->addToLogs("Search finished.");
    emit endOfSearch();
    for(auto i : btdevices)
    {
        qDebug() << i.first << " --- " << i.second;
        emit addDevice(i.first);
    }
}

void AppCore::connectionEstablished()
{
    this->addToLogs("connected");
    emit sendToQml("connected");
}

void AppCore::connectionInterrupted()
{
    this->addToLogs("Connection interrupted");
    emit sendToQml("Connection interrupted");
}

void AppCore::sockectReadyToRead()
{
/*    while (this->socket->canReadLine())*/
    pause(200);

    QByteArray line = this->socket->readLine();

    WakeCore WKread;

    for (uint8_t ch : line)
    {
        if (WKread.byteParse(ch))
        {
            this->addToLogs(QString ((char*)WKread.getRcvData()));
        }
    }
    this->addToLogs((char*)WKread.getRcvData());
    sendWakePackToDevice(1, 1, "1234");
}

void AppCore::on_pushButton_Search_clicked()
{
    this->addToLogs("Search started");
    emit sendToQml("Search started");
    btdevices.clear();
    this->discoveryAgent->start();
    connect(this->discoveryAgent, SIGNAL(deviceDiscovered(QBluetoothDeviceInfo)), this, SLOT(captureDeviceProperties(QBluetoothDeviceInfo)));
}

void AppCore::on_pushButton_Connect_clicked()
{
        this->addToLogs("Initialising connection.");
        emit sendToQml("Initialising connection.");
        static const QString serviceUuid(QStringLiteral("00001101-0000-1000-8000-00805F9B34FB"));
        this->socket->connectToService(QBluetoothAddress(QBluetoothAddress()), QBluetoothUuid(serviceUuid), QIODevice::ReadWrite);
        this->addToLogs("Connecting to device/address: " /*+ portList.first() + " / " + portList.last()*/);
        emit sendToQml("Connecting to device.");
}

void AppCore::connect_toDevice_clicked(QString name)
{
    on_pushButton_Disconnect_clicked();
    this->addToLogs("Initialising connection.");
    emit sendToQml("Initialising connection.");
    static const QString serviceUuid(QStringLiteral("00001101-0000-1000-8000-00805F9B34FB"));
    this->socket->connectToService(QBluetoothAddress(btdevices[name]), QBluetoothUuid(serviceUuid), QIODevice::ReadWrite);
    this->addToLogs("Connecting to device/address:" + name + " / " + btdevices[name]);
    emit sendToQml("Connecting to device.");
}

void AppCore::addToLogs(QString message)
{
//    QString currentDateTime = QDateTime::currentDateTime().toString("yyyy.MM.dd hh:mm:ss");
    QString currentDateTime = QDateTime::currentDateTime().toString("hh:mm:ss");
    qDebug() << (currentDateTime + ":   " + message);
}

void AppCore::sendMessageToDevice(QString message)
{
    sendWakePackToDevice(1, 1, message);
}

void AppCore::sendWakePackToDevice(uint8_t addr, uint8_t idCmd, QString message)
{
    WakeCore WKsend;

    size_t sendSize = WKsend.dataPrepare(addr, idCmd, (uint8_t*)message.toStdString().c_str(), message.length());
    QByteArray sendArray((char*)WKsend.getSndData(), sendSize);

    if (this->socket->isOpen() && this->socket->isWritable()) {
        this->addToLogs("Sending message to device : " + message);
        this->socket->write(sendArray);
    } else {
        this->addToLogs("Cannot send message. No open connection.");
        emit sendToQml("Cannot send message. No open connection.");
    }
}

void AppCore::on_pushButton_Disconnect_clicked()
{
    this->addToLogs("Closing connection.");
    emit sendToQml("Closing connection.");
    this->socket->disconnectFromService();
    emit sendToQml("Disconnected");
}
