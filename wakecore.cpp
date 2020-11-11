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

WakeCore::WakeCore()
    : _rcvState{RcvState::RCV_FEND}
{

}

ParseResult WakeCore::byteParse(uint8_t rcvByte)
{
    ParseResult result = ParseResult::PARSE_CONTINUE;

    if(rcvByte == FEND)
    {
        // start frame
        _escSequence = false;
        _rcvCrc = CRC_INIT;
        do_crc8(rcvByte, &_rcvCrc);
        _rcvState = RcvState::RCV_ADDR;
        return result;
    }

    if(_rcvState == RcvState::RCV_FEND)
    {
      return result;
    }

    if(_escSequence)
    {
      if(rcvByte == TFESC)
      {
        rcvByte = FESC;
      }
      else if(rcvByte == TFEND)
      {
        rcvByte = FEND;
      }
      else
      {
        _rcvState = RcvState::RCV_FEND;
        return ParseResult::PARSE_ERROR;
      }
    }
    else if(rcvByte == FESC)
    {
        _escSequence = true;
        return result;
    }

    switch(_rcvState)
    {
    case RcvState::RCV_ADDR:
        if(rcvByte & ADDR_MASK)
        {
            // clear Addr bit
            rcvByte &= ~ADDR_MASK;
            _rcvAddr = rcvByte;
            do_crc8(rcvByte, &_rcvCrc);
            _rcvState = RcvState::RCV_CMD;
            break;
        }
        else
        {
            _rcvAddr = 0;
            // addr not exist it packet - go to RCV_CMD state right now
        }
      /* no break */
    case RcvState::RCV_CMD:
        if(rcvByte & ADDR_MASK)
        {
            result = ParseResult::PARSE_ERROR;
            _rcvState = RcvState::RCV_FEND;
        }
        else
        {
            _rcvCmd = rcvByte;
            do_crc8(rcvByte, &_rcvCrc);
            _rcvState = RcvState::RCV_NBT;
        }
        break;
    case RcvState::RCV_NBT:
        if(rcvByte > FRAME_SIZE)
        {
            result = ParseResult::PARSE_ERROR;
            _rcvState = RcvState::RCV_FEND;
        }
        else
        {
            _rcvSize = rcvByte;
            do_crc8(rcvByte, &_rcvCrc);
            _rcvDataPtr = 0;
            if (_rcvSize)
            {
                _rcvState = RcvState::RCV_DATA;
            }
            else
            {
                _rcvState = RcvState::RCV_CRC;
            }
        }
        break;
    case RcvState::RCV_DATA:
        if(_rcvDataPtr < _rcvSize)
        {
          _rcvData[_rcvDataPtr++] = rcvByte;
          do_crc8(rcvByte, &_rcvCrc);
        }
        if (_rcvDataPtr == _rcvSize)
        {
            _rcvState = RcvState::RCV_CRC;
        }
        break;
      /* no break */
    case RcvState::RCV_CRC:
        if(rcvByte == _rcvCrc)
        {
            result = ParseResult::PARSE_SUCCESS;
        }
        else
        {
            result = ParseResult::PARSE_ERROR;
        }
        _rcvState = RcvState::RCV_FEND;
        break;
    default:
        break;
    }

    return result;
}

size_t WakeCore::dataPrepare(uint8_t cmd, uint8_t *data, uint8_t size, uint8_t addr)
{
    size_t sendSize = 0;
    uint8_t crc = CRC_INIT;

    // prepare FEND
    do_crc8(FEND, &crc);
    _sndData[sendSize++] = FEND;

    // prepare ADDR
    if (addr)
    {
        // clear Addr bit
        addr &= ~ADDR_MASK;
        do_crc8(addr, &crc);
        // set Addr bit
        addr |= ADDR_MASK;
        sendSize += byteStuff(&addr, 1, &_sndData[sendSize]);
    }

    // prepare CMD
    // clear Addr bit
    cmd &= ~ADDR_MASK;
    do_crc8(cmd, &crc);
    sendSize += byteStuff(&cmd, 1, &_sndData[sendSize]);

    // prepare SIZE
    do_crc8(size, &crc);
    sendSize += byteStuff(&size, 1, &_sndData[sendSize]);

    // prepare DATA
    for (size_t i = 0; i < size; i++)
    {
        do_crc8(data[i], &crc);
    }
    sendSize += byteStuff(data, size, &_sndData[sendSize]);

    // prepare CRC
    sendSize += byteStuff(&crc, 1, &_sndData[sendSize]);

    return sendSize;
}

uint8_t *WakeCore::getSndData()
{
    return _sndData;
}

uint8_t *WakeCore::getRcvData()
{
    return _rcvData;
}


uint8_t WakeCore::getRcvSize()
{
    return _rcvSize;
}


uint8_t WakeCore::getRcvCmd()
{
    return _rcvCmd;
}
