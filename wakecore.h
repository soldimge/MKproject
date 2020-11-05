#pragma once

#include "wake.h"
#include <QCoreApplication>

#define FEND        0xC0    /* Frame END */
#define FESC        0xDB    /* Frame ESCape */
#define TFEND       0xDC    /* Transposed Frame END */
#define TFESC       0xDD    /* Transposed Frame ESCape */

#define CRC_INIT    0xDE   /* Innitial CRC value */
#define FRAME_SIZE       255     /* Max pack len */

constexpr uint8_t ADDR_MASK{0x80};

enum class rcvState
{
  WAIT_FEND,     /* waiting receive FEND */
  WAIT_ADDR,     /* waiting receive ADDRESS */
  WAIT_CMD,      /* waiting receive COMMAND ID */
  WAIT_NBT,      /* waiting receive NUMBER OF DATA BYTES */
  WAIT_DATA,     /* receive DATA */
  WAIT_CRC,      /* waiting receive CRC */
};

class WakeCore
{
public:    
    WakeCore();
    bool byteParse(uint8_t data_byte);
    size_t dataPrepare(uint8_t addr, uint8_t cmd, uint8_t *data, uint8_t size);
    uint8_t *getSndData();
    uint8_t *getRcvData();
    uint8_t getRcvSize();
    uint8_t getRcvCmd();

private:
    bool escSequence;
    uint8_t cmd;
    uint8_t nbt;
    uint8_t addr;
    uint8_t dataPtr;
    rcvState sta;
    uint8_t crc;
    uint8_t rcvData[FRAME_SIZE];

    uint8_t sndData[2 * FRAME_SIZE];
};
