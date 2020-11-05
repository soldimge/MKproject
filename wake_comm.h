/*
* wake_comm.h
*
*  Created on: 7 ???. 2019 ?.
*      Author: Mikhail Kalina
*/

#ifndef APP_WAKE_COMM_H_
#define APP_WAKE_COMM_H_

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include "wake.h"

#define RX_ADDR     0
#define TX_ADDR     0

#define CONSEC_PACK_MAX 2
#define SET_NEXT_CONTEXT(context_ptr)   ((context_ptr + 1 >= CONSEC_PACK_MAX) ? context_ptr = 0 : context_ptr++)
#define GET_NEXT_CONTEXT(context_ptr)   ((context_ptr + 1 >= CONSEC_PACK_MAX) ? 0 : context_ptr + 1)

typedef uint8_t (*wake_comm_io_func_t)(uint8_t *data, uint8_t size);

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

/**
* \brief   Structure that holds the state of receive and transmit blocks
*/
typedef struct
{
  uint8_t sta;        /* state */
  uint8_t pre;        /* previous byte */
  uint8_t add;        /* address */
  uint8_t cmd;        /* command id */
  uint8_t nbt;        /* number of data bytes */
  uint8_t dat[FRAME]; /* data array */
  uint8_t crc;        /* control value */
  uint8_t ptr;        /* pointer to the end of the data */
} wake_comm_context_t;

/**
* \brief   Structure that holds the global variables for wake module
*/
typedef struct
{
  wake_comm_context_t rx_context[CONSEC_PACK_MAX];
  wake_comm_context_t tx_context[CONSEC_PACK_MAX];
  uint8_t rx_context_ptr;
  uint8_t tx_context_rd;
  uint8_t tx_context_wr;

  wake_comm_io_func_t wake_comm_send_func;
  wake_comm_io_func_t wake_comm_recv_func;
} T_WAKE_GLOB_STRUCT;

/**
* \brief   Results of parsing
*/
enum
{
  PARSE_CONTINUE,
  PARSE_ERROR,
  PARSE_SUCCESS
};

/**
* \brief           Send command
* \param addr      Device address (0 if not in use)
* \param cmd       Command identifier of packet
* \param payload   Pointer to memory to send
* \param len       Length of transmitted data in bytes
* \return          non zero if errors occur, otherwise zero
*
*                  Not for calling from interrupt context, main thread context only
*
*/
uint8_t wake_comm_send_cmd(uint8_t addr, uint8_t cmd, void const *payload, uint16_t len);


/**
* \brief					Protocol input processing
* \return					True when an input packet is detected, otherwise false
*/
bool wake_comm_input_process(void);


/**
* \brief					Protocol output processing
* \return					True when an output packet is detected, otherwise false
*/
bool wake_comm_output_process(void);


/**
* \brief                       Initialize wake module
* \param send_func             A pointer to uart send function
* \param recv_func             A pointer to uart receive function
* \return                      None
*/
void wake_comm_init(wake_comm_io_func_t send_func, wake_comm_io_func_t recv_func);

/**
* \brief                       Packet send callback function
* \return                      None
*/
void wake_comm_send_callback_func(void);

/**
* \brief                        Packet receive callback function
* \param id_cmd                 Command identifier of packet
* \param data                   A pointer to receive data
* \param size                   Size of receive data
* \return                       None
*/
void wake_comm_recv_callback_func(uint8_t id_cmd, uint8_t *data, uint8_t size);

#endif /* APP_WAKE_COMM_H_ */
