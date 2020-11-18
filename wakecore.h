#pragma once

#include <QCoreApplication>

constexpr uint8_t FEND{0xC0};       /* Frame END */
constexpr uint8_t FESC{0xDB};       /* Frame ESCape */
constexpr uint8_t TFEND{0xDC};      /* Transposed Frame END */
constexpr uint8_t TFESC{0xDD};      /* Transposed Frame ESCape */

constexpr uint8_t CRC_INIT{0xDE};   /* Crc init value */
constexpr uint8_t FRAME_SIZE{255};  /* Max payload size */
constexpr size_t SEND_SIZE{2 + 2 * (3 + FRAME_SIZE)};

constexpr uint8_t ADDR_MASK{0x80};  /* Mask of address bit */

enum class RcvState
{
    RCV_FEND,   /* waiting receive FEND */
    RCV_ADDR,   /* waiting receive ADDRESS */
    RCV_CMD,    /* waiting receive COMMAND ID */
    RCV_NBT,    /* waiting receive NUMBER OF DATA BYTES */
    RCV_DATA,   /* receive DATA */
    RCV_CRC,    /* waiting receive CRC */
};

enum class ParseResult
{
    PARSE_SUCCESS,
    PARSE_ERROR,
    PARSE_CONTINUE
};

class WakeCore
{
public:    
    WakeCore();
    ParseResult byteParse(uint8_t rcvByte);
    size_t dataPrepare(uint8_t cmd, uint8_t *data, uint8_t size, uint8_t addr = 0);
    uint8_t *getSndData();
    uint8_t *getRcvData();
    uint8_t getRcvSize();
    uint8_t getRcvCmd();
    uint8_t getRcvAddr();

private:
    bool _escSequence;
    RcvState _rcvState;

    uint8_t _rcvAddr;
    uint8_t _rcvCmd;
    uint8_t _rcvSize;
    uint8_t _rcvDataPtr;
    uint8_t _rcvData[FRAME_SIZE];
    uint8_t _rcvCrc;

    uint8_t _sndData[SEND_SIZE];
};
