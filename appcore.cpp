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
    switch (messageType)
    {
    case CmdType::ASCII:
        return QString(byte);
    case CmdType::HEX:
        return QString::number(byte, 16);
    case CmdType::DEC:
        return QString::number(byte, 10);
        break;
    default:
        return "";
    }
}

QString convertBytesToString(QByteArray array, CmdType messageType)
{
    QString str{};

    if (messageType == CmdType::ASCII)
    {
        str = QString::fromStdString(array.toStdString());
    }
    else
    {
        for (auto byte: array)
        {
            str += convertByteToString(byte, messageType) + " ";
        }
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
                                    _clipboard{QGuiApplication::clipboard()}
{
    _msInLogs = _settings.value("msInLogs").toBool();
    _cmdType = static_cast<CmdType>(_settings.value("cmdType").toInt());

#ifdef Q_OS_ANDROID
    _localDevice = new QBluetoothLocalDevice(this);
    _localDevice->powerOn();
#endif

    _discoveryAgent = new QBluetoothDeviceDiscoveryAgent(this);
    _socket = new QBluetoothSocket(QBluetoothServiceInfo::RfcommProtocol, this);

    connect(this->_discoveryAgent, SIGNAL(deviceDiscovered(QBluetoothDeviceInfo)), this, SLOT(captureDeviceProperties(QBluetoothDeviceInfo)));
    connect(this->_discoveryAgent, SIGNAL(finished()), this, SLOT(searchFinished()));

    connect(this->_socket, SIGNAL(connected()), this, SLOT(connectionEstablished()));
    connect(this->_socket, SIGNAL(disconnected()), this, SLOT(connectionInterrupted()));
    connect(this->_socket, SIGNAL(readyRead()), this, SLOT(sockectReadyToRead()));
}

AppCore::~AppCore()
{
    on_pushButton_Disconnect_clicked();

    _settings.setValue("msInLogs", _msInLogs);
    _settings.setValue("cmdType", static_cast<qint16>(_cmdType));
    _settings.sync();

#ifdef Q_OS_ANDROID
    _localDevice->setHostMode(QBluetoothLocalDevice::HostPoweredOff);
#endif

    delete _discoveryAgent;
}

void AppCore::copyToBuffer(QString text)
{
    _clipboard->setText(text);
}

void AppCore::setCmdType(qint16 cmdTypeFromQml)
{
    _cmdType = static_cast<CmdType>(cmdTypeFromQml);
}

void AppCore::setAppSettings(bool ms)
{
    _msInLogs = ms;   
}

void AppCore::addToLogs(QString message)
{
    QString currentDateTime;
    if (_msInLogs)
        currentDateTime = QDateTime::currentDateTime().toString("hh:mm:ss:zzz");
    else
        currentDateTime = QDateTime::currentDateTime().toString("hh:mm:ss");
    qDebug() << (currentDateTime + ":   " + message);
    emit addLog(currentDateTime + ":   " + message);
}

void AppCore::captureDeviceProperties(const QBluetoothDeviceInfo &device)
{
    if (_btdevices.find(device.name()) == _btdevices.end())
    {
        QString logStr;

#ifdef Q_OS_ANDROID
        logStr = "device found, name/address/rssi:\n" + device.name() + " / " + device.address().toString() + QString(" / %1 dBm").arg(device.rssi());
        _btdevices[device.name()] = std::make_pair(device.address().toString(), device.rssi());
#else
        logStr = "device found, name/address:\n" + device.name() + " / " + device.address().toString();
        _btdevices[device.name()] = std::make_pair(device.address().toString(), device.rssi());
#endif
        addToLogs(logStr);
    }
}

void AppCore::searchFinished()
{
    addToLogs("Search finished");
    emit endOfSearch();
    for(auto i : _btdevices)
    {
        qDebug() << (i.first + " --- " + i.second.first);

        QString name;
        i.first == "" ? name = i.second.first : name = i.first;

#ifdef Q_OS_ANDROID
        qint16 dBm = i.second.second;

        if (dBm >= -50)
            dBm = 4;
        else if (dBm < -50 && dBm > -65)
            dBm = 3;
        else if (dBm <= -65 && dBm > -75)
            dBm = 2;
        else if (dBm <= -75 && dBm > -85)
            dBm = 1;
        else if (dBm <= -85 && dBm >= -100)
            dBm = 0;

        emit addDevice(name + " (" + QString::number(dBm) + ")");
#else
        emit addDevice(name);
#endif
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
            uint8_t rcvAddr = _wake.getRcvAddr();
            uint8_t rcvCmd = _wake.getRcvCmd();
            QByteArray rcvArray = QByteArray((char*)_wake.getRcvData(), _wake.getRcvSize());

            QString logStr = "RX " + convertByteToString(rcvCmd, CmdType::DEC) + ": " + convertBytesToString(rcvArray, _cmdType);
            addToLogs(logStr);
            emit addMes(logStr);

            std::unique_lock<std::mutex> lock(_mtx);
            if (_reqIsActive && _reqCmd == rcvCmd && _reqAddr == rcvAddr)
            {
                _reqIsActive = false;
                _answer = rcvArray;
            }
        }
    }
}

QByteArray AppCore::sendCommand(uint8_t cmd, QByteArray data, uint8_t addr)
{
    size_t sendSize = _wake.dataPrepare(cmd, (uint8_t*)data.data(), data.length(), addr);

    if (this->_socket->isOpen() && this->_socket->isWritable())
    {
        QString logStr = "TX " + convertByteToString(cmd, CmdType::DEC) + ": " + convertBytesToString(data, _cmdType);
        addToLogs(logStr);
        emit addMes(logStr);

        if (this->_socket->write((char*)_wake.getSndData(), sendSize) == (qint64)sendSize)
        {
            std::unique_lock<std::mutex> lock(_mtx);
            _reqIsActive = true;
            _reqAddr = addr;
            _reqCmd = cmd;

            size_t timeout = 0;
            while(_reqIsActive && timeout < TIMEOUT_MS)
            {
                lock.unlock();
                pause(PAUSE_MS);
                lock.lock();
                timeout += PAUSE_MS;
            }

            if (!_reqIsActive)
            {
                addToLogs("Send message success");
                //success recieving
                return _answer;
            }
            else
            {
                addToLogs("Send message error: timeout");
                _reqIsActive = false;
                //error timeout
            }
        }
    }
    else
    {
        addToLogs("Cannot send message.\nNo open connection");
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
    this->_socket->connectToService(QBluetoothAddress(_btdevices[name].first), QBluetoothUuid(serviceUuid), QIODevice::ReadWrite);
    addToLogs("Connecting to device/address:\n" + name + " / " + _btdevices[name].first);
    emit sendToQml("Connecting to device");
}

void AppCore::sendMessageToDevice(QString idCmd, QString message, qint16 messageType)
{
    QByteArray sendArray;

    if (!message.isEmpty())
    {
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
