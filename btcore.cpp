#include "btcore.h"
#include "wakecore.h"

#include <QDebug>
#include <QDateTime>

void pause(qint32 ms)
{
    QTime pauseEnd = QTime::currentTime().addMSecs(ms);
    while (QTime::currentTime() < pauseEnd)
        QCoreApplication::processEvents(QEventLoop::AllEvents, 100);
}

BTcore::BTcore(QObject *parent)
    : QObject(parent)
{
    this->discoveryAgent = new QBluetoothDeviceDiscoveryAgent(this);
    this->socket = new QBluetoothSocket(QBluetoothServiceInfo::RfcommProtocol, this);

    connect(this->discoveryAgent, SIGNAL(deviceDiscovered(QBluetoothDeviceInfo)), this, SLOT(captureDeviceProperties(QBluetoothDeviceInfo)));
    connect(this->discoveryAgent, SIGNAL(finished()), this, SLOT(searchFinished()));

    connect(this->socket, SIGNAL(connected()), this, SLOT(connectionEstablished()));
    connect(this->socket, SIGNAL(disconnected()), this, SLOT(connectionInterrupted()));
    connect(this->socket, SIGNAL(readyRead()), this, SLOT(sockectReadyToRead()));
}

BTcore::~BTcore()
{
    delete discoveryAgent;
}

void BTcore::captureDeviceProperties(const QBluetoothDeviceInfo &device)
{
//    ui->comboBox_Devices->addItem(device.name() + "  >>>  " + device.address().toString());
    qDebug() << "device found. name: " << device.name() << " and address: " << device.address().toString();
    this->addToLogs("device found...\n  name/address: " + device.name() + " / " + device.address().toString());
}

void BTcore::searchFinished()
{
//    ui->pushButton_Search->setEnabled(true);
    this->addToLogs("Search finished.");
}

void BTcore::connectionEstablished()
{
    this->addToLogs("connected");
    emit sendToQml("connected");
}

void BTcore::connectionInterrupted()
{
    this->addToLogs("Connection interrupted.");
}

void BTcore::sockectReadyToRead()
{
/*    while (this->socket->canReadLine())*/
    pause(200);

    QByteArray line = this->socket->readLine();

//    if (line.length() > 0)
//    {
//        QString terminator = "\r";

//        int pos = line.lastIndexOf(terminator);
////        line = line.left(pos);
//        this->addToLogs(line);
//        emit sendToQml(line);
//    }
    WakeCore WKread;
    for (uint8_t ch : line)
    {
        if (WKread.byteParse(ch))
        {
            this->addToLogs(WKread.get_dat());
        }
    }
}

void BTcore::on_pushButton_Search_clicked()
{
    this->addToLogs("Search started.");
//    ui->pushButton_Search->setEnabled(false);
//    ui->comboBox_Devices->clear();

    this->discoveryAgent->start();
    connect(this->discoveryAgent, SIGNAL(deviceDiscovered(QBluetoothDeviceInfo)), this, SLOT(captureDeviceProperties(QBluetoothDeviceInfo)));
}

void BTcore::on_pushButton_Connect_clicked()
{
        this->addToLogs("Initialising connection.");
        emit sendToQml("Initialising connection.");
        static const QString serviceUuid(QStringLiteral("00001101-0000-1000-8000-00805F9B34FB"));
        this->socket->connectToService(QBluetoothAddress(QBluetoothAddress()), QBluetoothUuid(serviceUuid), QIODevice::ReadWrite);
        this->addToLogs("Connecting to device/address: " /*+ portList.first() + " / " + portList.last()*/);
        emit sendToQml("Connecting to device.");
}

void BTcore::addToLogs(QString message)
{
//    QString currentDateTime = QDateTime::currentDateTime().toString("yyyy.MM.dd hh:mm:ss");
    QString currentDateTime = QDateTime::currentDateTime().toString("hh:mm:ss");
    qDebug() << (currentDateTime + "\t" + message);
}

void BTcore::sendMessageToDevice(QString message)
{
    sendWakePackToDevice(0, 1, message);

//    if (this->socket->isOpen() && this->socket->isWritable()) {
//        this->addToLogs("Sending message to device : " + message);
//        this->socket->write(message.toStdString().c_str());
//    } else {
//        this->addToLogs("Cannot send message. No open connection.");
//        emit sendToQml("Cannot send message. No open connection.");
//    }
}

void BTcore::sendWakePackToDevice(uint8_t addr, uint8_t idCmd, QString message)
{
    WakeCore WKsend;
    size_t sendSize = 0;
    uint8_t crc = CRC_INIT;
    uint8_t msgLen = message.length();
//    uint8_t *msgData = reinterpret_cast<uint8_t*>(message.toStdString().c_str());

    WKsend.get_sendMass()[sendSize++] = FEND;
    sendSize += WKsend.byteStuff(&addr, 1, &WKsend.get_sendMass()[sendSize]);
    sendSize += WKsend.byteStuff(&idCmd, 1, &WKsend.get_sendMass()[sendSize]);
    sendSize += WKsend.byteStuff(&msgLen, 1, &WKsend.get_sendMass()[sendSize]);
    sendSize += WKsend.byteStuff((uint8_t*)message.toStdString().c_str(), msgLen, &WKsend.get_sendMass()[sendSize]);

    for (size_t i = 0; i < sendSize; i++)
    {
        WKsend.do_crc8(WKsend.get_sendMass()[i], &crc);
    }
    sendSize += WKsend.byteStuff(&crc, 1, &WKsend.get_sendMass()[sendSize]);

    if (this->socket->isOpen() && this->socket->isWritable()) {
        this->addToLogs("Sending message to device : " + message);
        this->socket->write((char*)WKsend.get_sendMass(), sendSize);
    } else {
        this->addToLogs("Cannot send message. No open connection.");
        emit sendToQml("Cannot send message. No open connection.");
    }
}

void BTcore::on_pushButton_Disconnect_clicked()
{
    this->addToLogs("Closing connection.");
    emit sendToQml("Closing connection.");
    this->socket->disconnectFromService();
    emit sendToQml("Disconnected");
}
