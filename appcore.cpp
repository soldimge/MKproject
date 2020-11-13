#include "appcore.h"

#include <QDebug>
#include <QDateTime>

namespace
{
void pause(qint32 ms)
{
    QTime pauseEnd = QTime::currentTime().addMSecs(ms);
    while (QTime::currentTime() < pauseEnd)
    {
        QCoreApplication::processEvents(QEventLoop::AllEvents, 100);
    }
}

QString convertByteToString(uint8_t byte, CmdType messageType)
{
    QString str{};

    switch (messageType)
    {
    case CmdType::ASCII:
        str = byte;
        break;
    case CmdType::HEX:
        str = QString::number(byte, 16);
        break;
    case CmdType::DEC:
        str = QString::number(byte, 10);
        break;
    }

    return str;
}

QString convertBytesToString(QByteArray array, CmdType messageType)
{
    QString str{};

    switch (messageType)
    {
    case CmdType::ASCII:
        str = QString::fromStdString(array.toStdString());
        break;

    case CmdType::HEX:
        for (auto byte: array)
        {
            str += QString::number(byte, 16) + " ";
        }
        break;

    case CmdType::DEC:
        for (auto byte: array)
        {
            str += QString::number(byte, 10) + " ";
        }
        break;
    }

    if (str.length())
    {
        str = str.left(str.lastIndexOf(" "));
    }

    return str;
}
}

AppCore::AppCore(QObject *parent) : QObject{parent},
                                    _reqIsActive{0},
                                    _clipboard{QGuiApplication::clipboard()},
                                    _msInLogs{false},
                                    _cmdType{CmdType::ASCII}
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

void AppCore::copyToBuffer(QString text)
{
    _clipboard->setText(text);
}

void AppCore::setAppSettings(bool ms, qint16 cmdTypeFromQml)
{
    _msInLogs = ms;
    _cmdType = static_cast<CmdType>(cmdTypeFromQml);
}

void AppCore::addToLogs(QString message)
{
    QString currentDateTime;
//    QString currentDateTime = QDateTime::currentDateTime().toString("yyyy.MM.dd hh:mm:ss");
    if(_msInLogs)
        currentDateTime = QDateTime::currentDateTime().toString("hh:mm:ss:zzz");
    else
        currentDateTime = QDateTime::currentDateTime().toString("hh:mm:ss");
    qDebug() << (currentDateTime + ":   " + message);
    emit addLog(currentDateTime + ":   " + message);
}


void AppCore::captureDeviceProperties(const QBluetoothDeviceInfo &device)
{
    static QBluetoothDeviceInfo temp;
    if(temp != device)
    {
//        addToLogs("device found\n name: " + device.name() + "\n and address: " + device.address().toString());
        addToLogs("device found, name/address:\n" + device.name() + " / " + device.address().toString());
        _btdevices[device.name()] = device.address().toString();
    }
    temp = device;
}

void AppCore::searchFinished()
{
    addToLogs("Search finished");
    emit endOfSearch();
    for(auto i : _btdevices)
    {
        qDebug() << (i.first + " --- " + i.second);
        emit addDevice(i.first);
    }
}

void AppCore::connectionEstablished()
{
    addToLogs("Connected");
    emit sendToQml("Connected");
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

            addToLogs("CMD " + convertByteToString(rcvCmd, CmdType::DEC) + ": " + convertBytesToString(rcvArray, _cmdType));
//            emit sendToQml("RX " + convertByteToString(rcvCmd, CmdType::DEC) + ": " + convertBytesToString(rcvArray, _cmdType));
            emit addMes("RX " + convertByteToString(rcvCmd, CmdType::DEC) + ": " + convertBytesToString(rcvArray, _cmdType));
            if (_reqIsActive && _reqCmd == rcvCmd)
            {
                _reqIsActive = false;
                _answer = rcvArray;
            }
            sendCommand(rcvCmd, rcvArray);
        }
    }
}

QByteArray AppCore::sendCommand(uint8_t cmd, QByteArray data, uint8_t addr)
{
    size_t sendSize = _wake.dataPrepare(cmd, (uint8_t*)data.data(), data.length(), addr);

    if (this->_socket->isOpen() && this->_socket->isWritable())
    {
        addToLogs("Send CMD " + convertByteToString(cmd, CmdType::DEC) + ": " + convertBytesToString(data, _cmdType));
//        emit sendToQml("TX " + convertByteToString(cmd, CmdType::DEC) + ": " + convertBytesToString(data, _cmdType));
        emit addMes("TX " + convertByteToString(cmd, CmdType::DEC) + ": " + convertBytesToString(data, _cmdType));
        if (this->_socket->write((char*)_wake.getSndData(), sendSize) == (qint64)sendSize)
        {
            _reqIsActive = true;
            size_t timeout = 0;
            while(_reqIsActive && timeout < TIMEOUT_MS)
            {
                pause(PAUSE_MS);
                timeout += PAUSE_MS;
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
        addToLogs("Cannot send message. No open connection");
        emit sendToQml("Error:\nNo open connection");
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
        addToLogs("Initialising connection");
        emit sendToQml("Initialising connection");
        static const QString serviceUuid(QStringLiteral("00001101-0000-1000-8000-00805F9B34FB"));
        this->_socket->connectToService(QBluetoothAddress(QBluetoothAddress()), QBluetoothUuid(serviceUuid), QIODevice::ReadWrite);
        addToLogs("Connecting to device/address: " /*+ portList.first() + " / " + portList.last()*/);
        emit sendToQml("Connecting to device");
}

void AppCore::connect_toDevice_clicked(QString name)
{
    on_pushButton_Disconnect_clicked();
    addToLogs("Initialising connection");
    emit sendToQml("Initialising connection");
    static const QString serviceUuid(QStringLiteral("00001101-0000-1000-8000-00805F9B34FB"));
    this->_socket->connectToService(QBluetoothAddress(_btdevices[name]), QBluetoothUuid(serviceUuid), QIODevice::ReadWrite);
    addToLogs("Connecting to device/address:\n" + name + " / " + _btdevices[name]);
    emit sendToQml("Connecting to device");
}

void AppCore::sendMessageToDevice(QString idCmd, QString message, qint16 messageType)
{
    QByteArray sendArray;
    switch (static_cast<CmdType>(messageType))
    {
    case CmdType::ASCII:
        sendArray = QByteArray::fromStdString(message.toStdString());
        break;

    case CmdType::HEX:
    {
        QStringList byteList = message.split(" ");
        for(QString byte : byteList)
        {
            sendArray += byte.toUInt(nullptr, 16);
        }
    }
        break;

    case CmdType::DEC:
    {
        QStringList byteList = message.split(" ");
        for(QString byte : byteList)
        {
            sendArray += byte.toUInt(nullptr, 10);
        }
    }
        break;
    }

    sendCommand(idCmd.toInt(), sendArray);
}

void AppCore::on_pushButton_Disconnect_clicked()
{
    addToLogs("Closing connection");
    emit sendToQml("Closing connection");
    this->_socket->disconnectFromService();
    emit sendToQml("Disconnected");
}
