#include "btcore.h"

#include <QDebug>
#include <QDateTime>

#include "wake.h"

/**
* \brief   RX process states:
*/
enum
{
  WAIT_FEND,     /* waiting receive FEND */
  WAIT_ADDR,     /* waiting receive ADDRESS */
  WAIT_CMD,      /* waiting receive COMMAND ID */
  WAIT_NBT,      /* waiting receive NUMBER OF DATA BYTES */
  WAIT_DATA,     /* receive DATA */
  WAIT_CRC,      /* waiting receive CRC */
};

void pause(qint32 ms)
{
    QTime pauseEnd = QTime::currentTime().addMSecs(ms);
    while (QTime::currentTime() < pauseEnd)
        QCoreApplication::processEvents(QEventLoop::AllEvents, 100);
}

void do_crc8(uint8_t b, uint8_t *crc)
{
  for(char i = 0; i < 8; b = b >> 1, i++)
    if((b ^ *crc) & 1) *crc = ((*crc ^ 0x18) >> 1) | 0x80;
    else *crc = (*crc >> 1) & ~0x80;
}

std::size_t byteStuff(uint8_t *data, std::size_t size, uint8_t *dataStuff)
{
    std::size_t ind = 0;

    for (size_t i = 0; i < size; i++)
    {
        if(data[i] == FEND)
        {
          dataStuff[ind++] = FESC;
          dataStuff[ind++] = TFEND;
        }
        else if(data[i] == FESC)
        {
          dataStuff[ind++] = FESC;
          dataStuff[ind++] = TFESC;
        }
        else
        {
            dataStuff[ind++] = data[i];
        }
    }

    return ind;
}

static uint8_t cmd, nbt, ptr;
static char dat[256];

bool byteParse(uint8_t data_byte)
{
    static uint8_t sta = WAIT_FEND;
    static uint8_t crc = 0;
    static uint8_t pre;

    if(data_byte == FEND)/* start frame*/
    {
      sta = WAIT_ADDR;
      crc = CRC_INIT;
      pre = data_byte;
      do_crc8(data_byte, &crc);
      return false;
    }

    if(sta == WAIT_FEND)
    {
      return false;
    }

    uint8_t checkPre = pre;
    pre = data_byte;
    if(checkPre == FESC)
    {
      if(data_byte == TFESC)
      {
        data_byte = FESC;
      }
      else if(data_byte == TFEND)
      {
        data_byte = FEND;
      }
      else
      {
        sta = WAIT_FEND;
        return 0;
      }
    }
    else if(data_byte == FESC)
    {
        return 0;
    }

    switch(sta)
    {
    case WAIT_ADDR:
      {
        if(data_byte & 0x80)
        {
          data_byte &= (~0x80);
//          if(data_byte == 0 || data_byte == 1)
          {
            do_crc8(data_byte, &crc);
            sta = WAIT_CMD;
            break;
          }
          sta = WAIT_FEND;
          break;
        }
        sta = WAIT_CMD;
      }
      /* no break */
    case WAIT_CMD:
      {
        if(data_byte & 0x80)
        {
          sta = WAIT_FEND;
          return false;
        }
        cmd = data_byte;
        do_crc8(data_byte, &crc);
        sta = WAIT_NBT;
        break;
      }
    case WAIT_NBT:
      {
        if(data_byte > FRAME)
        {
          sta = WAIT_FEND;
          return false;
        }
        nbt = data_byte;
        do_crc8(data_byte, &crc);
        ptr = 0;
        sta = WAIT_DATA;
        break;
      }
    case WAIT_DATA:
      {
        if(ptr < nbt)
        {
          dat[ptr++] = data_byte;
          do_crc8(data_byte, &crc);
        }
        if (ptr == nbt)
        {
            sta = WAIT_CRC;
        }
        break;
      }
      /* no break */
    case WAIT_CRC:
      {
        if(data_byte != crc)
        {
          sta = WAIT_FEND;
          return false;
        }
        sta = WAIT_FEND;
        return true;
      }
    }

    return false;
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

    for (uint8_t ch : line)
    {
        if (byteParse(ch))
        {
            this->addToLogs(dat);
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
    static uint8_t sendMass[1+512];
    std::size_t sendSize = 0;
    uint8_t crc = CRC_INIT;
    uint8_t msgLen = message.length();
//    uint8_t *msgData = reinterpret_cast<uint8_t*>(message.toStdString().c_str());

    sendMass[sendSize++] = FEND;
    sendSize += byteStuff(&addr, 1, &sendMass[sendSize]);
    sendSize += byteStuff(&idCmd, 1, &sendMass[sendSize]);
    sendSize += byteStuff(&msgLen, 1, &sendMass[sendSize]);
    sendSize += byteStuff((uint8_t*)message.toStdString().c_str(), msgLen, &sendMass[sendSize]);

    for (size_t i = 0; i < sendSize; i++)
    {
        do_crc8(sendMass[i], &crc);
    }
    sendSize += byteStuff(&crc, 1, &sendMass[sendSize]);

    if (this->socket->isOpen() && this->socket->isWritable()) {
        this->addToLogs("Sending message to device : " + message);
        this->socket->write((char*)sendMass, sendSize);
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
