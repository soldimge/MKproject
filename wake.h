/*
 * wake.h
 *
 *  Created on: Oct 8, 2019
 *      Author: Mikhail Kalina
 */

#ifndef APP_WAKE_WAKE_H_
#define APP_WAKE_WAKE_H_

#define FEND        0xC0    /* Frame END */
#define FESC        0xDB    /* Frame ESCape */
#define TFEND       0xDC    /* Transposed Frame END */
#define TFESC       0xDD    /* Transposed Frame ESCape */

#define CRC_INIT    0xDE   /* Innitial CRC value */
#define FRAME       255     /* Max pack len */

/* COMMAND ID list */
#define CMD_NO_OP   0       /* no operation */
#define CMD_ERR     1       /* packet error */
#define CMD_ECHO    2       /* send echo */
#define CMD_INFO    3       /* send device information */

/* ERROR list */
#define ERR_NO 0x00   /* no error */
#define ERR_TX 0x01   /* Rx/Tx error */
#define ERR_BU 0x02   /* device busy error */
#define ERR_RE 0x03   /* device not ready error */
#define ERR_PA 0x04   /* parameters value error */
#define ERR_NR 0x05   /* no replay */

#endif /* APP_WAKE_WAKE_H_ */
