#include "appcore.h"

#include <QDebug>
#include <QDateTime>

namespace
{
void addToLogs(QString message)
{
//    QString currentDateTime = QDateTime::currentDateTime().toString("yyyy.MM.dd hh:mm:ss");
    QString currentDateTime = QDateTime::currentDateTime().toString("hh:mm:ss");
    qDebug() << (currentDateTime + ":   " + message);
}

void pause(qint32 ms)
{
    QTime pauseEnd = QTime::currentTime().addMSecs(ms);
    while (QTime::currentTime() < pauseEnd)
    {
        QCoreApplication::processEvents(QEventLoop::AllEvents, 100);
    }
}
}

AppCore::AppCore(QObject *parent) : QObject(parent)
{
    this->_discoveryAgent = new QBluetoothDeviceDiscoveryAgent(this);
    this->_socket = new QBluetoothSocket(QBluetoothServiceInfo::RfcommProtocol, this);

    connect(this->_discoveryAgent, SIGNAL(deviceDiscovered(QBluetoothDeviceInfo)), this, SLOT(captureDeviceProperties(QBluetoothDeviceInfo)));
    connect(this->_discoveryAgent, SIGNAL(finished()), this, SLOT(searchFinished()));

    connect(this->_socket, SIGNAL(connected()), this, SLOT(connectionEstablished()));
    connect(this->_socket, SIGNAL(disconnected()), this, SLOT(connectionInterrupted()));
    connect(this->_socket, SIGNAL(readyRead()), this, SLOT(sockectReadyToRead()));
}

AppCore::~AppCore()
{
    on_pushButton_Disconnect_clicked();
    delete _discoveryAgent;
}

void AppCore::captureDeviceProperties(const QBluetoothDeviceInfo &device)
{
//    ui->comboBox_Devices->addItem(device.name() + "  >>>  " + device.address().toString());
    addToLogs("device found. name: " + device.name() + " and address: " + device.address().toString());
    addToLogs("device found...\n  name/address: " + device.name() + " / " + device.address().toString());
    _btdevices[device.name()] = device.address().toString();
}

void AppCore::searchFinished()
{
    addToLogs("Search finished.");
    emit endOfSearch();
    for(auto i : _btdevices)
    {
        addToLogs(i.first + " --- " + i.second);
        emit addDevice(i.first);
    }
}

void AppCore::connectionEstablished()
{
    addToLogs("connected");
    emit sendToQml("connected");
}

void AppCore::connectionInterrupted()
{
    addToLogs("Connection interrupted");
    emit sendToQml("Connection interrupted");
}

void AppCore::sockectReadyToRead()
{
    QByteArray rcvArray = this->_socket->readLine();

    for (uint8_t byte : rcvArray)
    {
        if (_wake.byteParse(byte) == ParseResult::PARSE_SUCCESS)
        {
            uint8_t rcvCmd = _wake.getRcvCmd();
            QByteArray rcvArray = QByteArray((char*)_wake.getRcvData(), _wake.getRcvSize());

            addToLogs("CMD " + QString(rcvCmd) + ": " + rcvArray);

            if (_reqIsActive && _reqCmd == rcvCmd)
            {
                _reqIsActive = false;
                _answer = rcvArray;
            }

            sentCommand(rcvCmd, rcvArray);
        }
    }
}

QByteArray AppCore::sentCommand(uint8_t cmd, QByteArray data, uint8_t addr)
{
    size_t sendSize = _wake.dataPrepare(cmd, (uint8_t*)data.data(), data.length(), addr);

    if (this->_socket->isOpen() && this->_socket->isWritable())
    {
        addToLogs("Sending message to device : " + QString(data));
        if (this->_socket->write((char*)_wake.getSndData(), sendSize) == (qint64)sendSize)
        {
            _reqIsActive = true;
            size_t timeout = 0;
            while(_reqIsActive && timeout < 1000)
            {
                //wait(20);
                timeout += 20;
            }

            if (!_reqIsActive)
            {
                //success recieving
                return _answer;
            }
            else
            {
                _reqIsActive = false;
                //error timeout
            }
        }
    }
    else
    {
        addToLogs("Cannot send message. No open connection.");
        emit sendToQml("Cannot send message. No open connection.");
    }

    return nullptr;
}

void AppCore::on_pushButton_Search_clicked()
{
    addToLogs("Search started");
    emit sendToQml("Search started");
    _btdevices.clear();
    this->_discoveryAgent->start();
    connect(this->_discoveryAgent, SIGNAL(deviceDiscovered(QBluetoothDeviceInfo)), this, SLOT(captureDeviceProperties(QBluetoothDeviceInfo)));
}

void AppCore::on_pushButton_Connect_clicked()
{
        addToLogs("Initialising connection.");
        emit sendToQml("Initialising connection.");
        static const QString serviceUuid(QStringLiteral("00001101-0000-1000-8000-00805F9B34FB"));
        this->_socket->connectToService(QBluetoothAddress(QBluetoothAddress()), QBluetoothUuid(serviceUuid), QIODevice::ReadWrite);
        addToLogs("Connecting to device/address: " /*+ portList.first() + " / " + portList.last()*/);
        emit sendToQml("Connecting to device.");
}

void AppCore::connect_toDevice_clicked(QString name)
{
    on_pushButton_Disconnect_clicked();
    addToLogs("Initialising connection.");
    emit sendToQml("Initialising connection.");
    static const QString serviceUuid(QStringLiteral("00001101-0000-1000-8000-00805F9B34FB"));
    this->_socket->connectToService(QBluetoothAddress(_btdevices[name]), QBluetoothUuid(serviceUuid), QIODevice::ReadWrite);
    addToLogs("Connecting to device/address:" + name + " / " + _btdevices[name]);
    emit sendToQml("Connecting to device.");
}

void AppCore::sendMessageToDevice(QString message)
{
    QByteArray sendArray;
    uint8_t idCmd = 1;

#if 1//ascii
    sendArray = QByteArray::fromStdString(message.toStdString());
#else
    QStringList byteList = message.split(" ");
#if 0//hex
    for(QString byte : byteList)
    {
        sendArray += byte.toUInt(nullptr, 16);
    }
#else//dec
    for(QString byte : byteList)
    {
        sendArray += byte.toUInt(nullptr, 10);
    }
#endif
#endif

    sentCommand(idCmd, sendArray);
}

void AppCore::on_pushButton_Disconnect_clicked()
{
    addToLogs("Closing connection.");
    emit sendToQml("Closing connection.");
    this->_socket->disconnectFromService();
    emit sendToQml("Disconnected");
}
