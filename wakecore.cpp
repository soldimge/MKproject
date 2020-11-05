#include "wakecore.h"

WakeCore::WakeCore() : sta{WAIT_FEND},
                       crc{0}
{

}

void WakeCore::do_crc8(uint8_t b, uint8_t *crc)
{
  for(char i = 0; i < 8; b = b >> 1, i++)
    if((b ^ *crc) & 1) *crc = ((*crc ^ 0x18) >> 1) | 0x80;
    else *crc = (*crc >> 1) & ~0x80;
}

size_t WakeCore::byteStuff(uint8_t *data, size_t size, uint8_t *dataStuff)
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

bool WakeCore::byteParse(uint8_t data_byte)
{
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

char* WakeCore::get_dat(){return this->dat;}

uint8_t* WakeCore::get_sendMass(){return this->sendMass;}
