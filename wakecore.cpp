#include "wakecore.h"

namespace
{
void do_crc8(uint8_t b, uint8_t *crc)
{
  for(char i = 0; i < 8; b = b >> 1, i++)
  {
    if((b ^ *crc) & 1)
    {
        *crc = ((*crc ^ 0x18) >> 1) | 0x80;
    }
    else
    {
        *crc = (*crc >> 1) & ~0x80;
    }
  }
}

size_t byteStuff(uint8_t *data, size_t size, uint8_t *dataStuff)
{
    size_t ind = 0;

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
}

WakeCore::WakeCore() : sta{rcvState::WAIT_FEND}
{

}

bool WakeCore::byteParse(uint8_t data_byte)
{
    bool result = false;

    if(data_byte == FEND)/* start frame*/
    {
        escSequence = false;
        sta = rcvState::WAIT_ADDR;
        crc = CRC_INIT;
        do_crc8(data_byte, &crc);
        return false;
    }

    if(sta == rcvState::WAIT_FEND)
    {
      return false;
    }

    if(escSequence)
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
        sta = rcvState::WAIT_FEND;
        return 0;
      }
    }
    else if(data_byte == FESC)
    {
        escSequence = true;
        return 0;
    }

    switch(sta)
    {
    case rcvState::WAIT_ADDR:
      {
        if(data_byte & ADDR_MASK)
        {
            data_byte &= (~ADDR_MASK);
            addr = data_byte;
            do_crc8(data_byte, &crc);
            sta = rcvState::WAIT_CMD;
            break;
        }
      }
      /* no break */
    case rcvState::WAIT_CMD:
      {
        if(data_byte & ADDR_MASK)
        {
            sta = rcvState::WAIT_FEND;
        }
        else
        {
            cmd = data_byte;
            do_crc8(data_byte, &crc);
            sta = rcvState::WAIT_NBT;
        }
        break;
      }
    case rcvState::WAIT_NBT:
      {
        if(data_byte > FRAME_SIZE)
        {
            sta = rcvState::WAIT_FEND;
        }
        else
        {
            nbt = data_byte;
            do_crc8(data_byte, &crc);
            dataPtr = 0;
            sta = rcvState::WAIT_DATA;
        }
        break;
      }
    case rcvState::WAIT_DATA:
      {
        if(dataPtr < nbt)
        {
          rcvData[dataPtr++] = data_byte;
          do_crc8(data_byte, &crc);
        }
        if (dataPtr == nbt)
        {
            sta = rcvState::WAIT_CRC;
        }
        break;
      }
      /* no break */
    case rcvState::WAIT_CRC:
      {
        if(data_byte == crc)
        {
          result = true;
        }
        sta = rcvState::WAIT_FEND;
        break;
      }
    default:
        break;
    }

    return result;
}

size_t WakeCore::dataPrepare(uint8_t addr, uint8_t cmd, uint8_t *data, uint8_t size)
{
    size_t sendSize = 0;
    uint8_t crc = CRC_INIT;

    do_crc8(FEND, &crc);
    do_crc8(addr, &crc);
    do_crc8(cmd, &crc);
    do_crc8(size, &crc);
    for (size_t i = 0; i < size; i++)
    {
        do_crc8(data[i], &crc);
    }

    addr |= ADDR_MASK;

    sndData[sendSize++] = FEND;
    sendSize += byteStuff(&addr, 1, &sndData[sendSize]);
    sendSize += byteStuff(&cmd, 1, &sndData[sendSize]);
    sendSize += byteStuff(&size, 1, &sndData[sendSize]);
    sendSize += byteStuff(data, size, &sndData[sendSize]);
    sendSize += byteStuff(&crc, 1, &sndData[sendSize]);

    return sendSize;
}

uint8_t *WakeCore::getSndData()
{
    return sndData;
}

uint8_t *WakeCore::getRcvData()
{
    return rcvData;
}


uint8_t WakeCore::getRcvSize()
{
    return dataPtr;
}


uint8_t WakeCore::getRcvCmd()
{
    return cmd;
}
