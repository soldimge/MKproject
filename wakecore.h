#pragma once

#include "wake.h"
#include <QCoreApplication>

constexpr qint16 DATASIZE{256};
constexpr qint16 MASSIZE{1+512};

class WakeCore
{
public:
    WakeCore();
    void do_crc8(uint8_t b, uint8_t *crc);
    size_t byteStuff(uint8_t *data, size_t size, uint8_t *dataStuff);
    bool byteParse(uint8_t data_byte);
    char* get_dat();
    uint8_t* get_sendMass();

private:
    uint8_t cmd;
    uint8_t nbt;
    uint8_t ptr;
    uint8_t sta;
    uint8_t crc;
    uint8_t pre;
    char dat[DATASIZE];
    uint8_t sendMass[MASSIZE];
};


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
