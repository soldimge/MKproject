/**
* \file
*         Application communication protocol
* \author
*         Mikhail Kalina
*/

#include "wake_comm.h"

static T_WAKE_GLOB_STRUCT wake_glob =
{
  .rx_context_ptr = 0,
  .tx_context_rd = 0,
  .tx_context_wr = 0,

  .wake_comm_send_func = NULL,
  .wake_comm_recv_func = NULL
};

static void do_crc8(uint8_t b, uint8_t *crc);
static uint8_t wake_comm_parse(uint8_t data_byte, wake_comm_context_t *context);
static void wake_comm_stuffing_output_byte(uint8_t byte);

/*---------------------------------------------------------------------------*/
static void do_crc8(uint8_t b, uint8_t *crc)
{
  for(char i = 0; i < 8; b = b >> 1, i++)
    if((b ^ *crc) & 1) *crc = ((*crc ^ 0x18) >> 1) | 0x80;
    else *crc = (*crc >> 1) & ~0x80;
}
/*---------------------------------------------------------------------------*/
static uint8_t wake_comm_parse(uint8_t data_byte, wake_comm_context_t *pContext)
{
  if(data_byte == FEND)/* start frame*/
  {
    pContext->sta = WAIT_ADDR;
    pContext->crc = CRC_INIT;
    pContext->pre = data_byte;
    do_crc8(data_byte, &pContext->crc);
    return PARSE_CONTINUE;
  }

  if(pContext->sta == WAIT_FEND)
  {
    return PARSE_CONTINUE;
  }

  uint8_t pre = pContext->pre;
  pContext->pre = data_byte;
  if(pre == FESC)
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
      pContext->sta = WAIT_FEND;
      return PARSE_ERROR;
    }
  }
  else if(data_byte == FESC)
  {
    return PARSE_CONTINUE;
  }

  switch(pContext->sta)
  {
  case WAIT_ADDR:
    {
      if(data_byte & 0x80)
      {
        data_byte &= (~0x80);
        if(data_byte == 0 || data_byte == pContext->add)
        {
          do_crc8(data_byte, &pContext->crc);
          pContext->sta = WAIT_CMD;
          break;
        }
        pContext->sta = WAIT_FEND;
        break;
      }
      pContext->sta = WAIT_CMD;
    }
    /* no break */
  case WAIT_CMD:
    {
      if(data_byte & 0x80)
      {
        pContext->sta = WAIT_FEND;
        return PARSE_ERROR;
      }
      pContext->cmd = data_byte;
      do_crc8(data_byte, &pContext->crc);
      pContext->sta = WAIT_NBT;
      break;
    }
  case WAIT_NBT:
    {
      if(data_byte > FRAME)
      {
        pContext->sta = WAIT_FEND;
        return PARSE_ERROR;
      }
      pContext->nbt = data_byte;
      do_crc8(data_byte, &pContext->crc);
      pContext->ptr = 0;
      pContext->sta = WAIT_DATA;
      break;
    }
  case WAIT_DATA:
    {
      if(pContext->ptr < pContext->nbt)
      {
        pContext->dat[pContext->ptr++] = data_byte;
        do_crc8(data_byte, &pContext->crc);
        break;
      }
      pContext->sta = WAIT_CRC;
    }
    /* no break */
  case WAIT_CRC:
    {
      if(data_byte != pContext->crc)
      {
        pContext->sta = WAIT_FEND;
        return PARSE_ERROR;
      }
      pContext->sta = WAIT_FEND;
      return PARSE_SUCCESS;
    }
  }

  return PARSE_CONTINUE;
}
/*---------------------------------------------------------------------------*/
static void wake_comm_stuffing_output_byte(uint8_t byte)
{
  static uint8_t send_data[2];
  uint8_t data_size = 0;

  if(byte == FEND)
  {
    send_data[data_size++] = FESC;
    send_data[data_size++] = TFEND;
  }
  else if(byte == FESC)
  {
    send_data[data_size++] = FESC;
    send_data[data_size++] = TFESC;
  }
  else
  {
    send_data[data_size++] = byte;
  }

  if(wake_glob.wake_comm_send_func != NULL)
  {
    wake_glob.wake_comm_send_func(send_data, data_size);
  }
}
/*---------------------------------------------------------------------------*/
uint8_t wake_comm_send_cmd(uint8_t addr, uint8_t cmd, void const *payload, uint16_t len)
{
  wake_comm_context_t *p_context;

  if(GET_NEXT_CONTEXT(wake_glob.tx_context_wr) == wake_glob.tx_context_rd)
  {
    return 1;
  }

  p_context = &wake_glob.tx_context[wake_glob.tx_context_wr];

  p_context->add = addr;
  p_context->cmd = cmd;
  if(len > 0 && len <= FRAME && payload != NULL)
  {
    memcpy(p_context->dat, payload, len);
    p_context->nbt = len;
  }
  else
  {
    p_context->nbt = 0;
  }
  p_context->crc = CRC_INIT;

  SET_NEXT_CONTEXT(wake_glob.tx_context_wr);

  wake_comm_send_callback_func();

  return 0;
}
/*---------------------------------------------------------------------------*/
bool wake_comm_input_process(void)
{
  uint8_t parse_result, data;
  wake_comm_context_t *pContext = &wake_glob.rx_context[wake_glob.rx_context_ptr];

  if(wake_glob.wake_comm_recv_func == NULL)
  {
    return false;
  }

  while(wake_glob.wake_comm_recv_func(&data, 1))
  {
    if((parse_result = wake_comm_parse(data, pContext)) != PARSE_CONTINUE)
    {
      if(parse_result == PARSE_SUCCESS)
      {
        wake_comm_recv_callback_func(pContext->cmd, pContext->dat, pContext->nbt);
        SET_NEXT_CONTEXT(wake_glob.rx_context_ptr);
        return true;
      }
      else if(parse_result == PARSE_ERROR)
      {
        wake_comm_send_cmd(TX_ADDR, CMD_ERR, NULL, 0);
      }
    }
  }
  return false;
}
/*---------------------------------------------------------------------------*/
bool wake_comm_output_process(void)
{
  static uint8_t send_byte;
  wake_comm_context_t *pContext = &wake_glob.tx_context[wake_glob.tx_context_rd];

  if(wake_glob.tx_context_wr == wake_glob.tx_context_rd)
  {
    return false;
  }

  /* sending start byte first - FEND without stuffing */
  send_byte = FEND;
  if(wake_glob.wake_comm_send_func != NULL)
  {
    wake_glob.wake_comm_send_func(&send_byte, 1);
  }
  do_crc8(FEND, &pContext->crc);

  /* sending device address if no zero */
  if(pContext->add)
  {
    wake_comm_stuffing_output_byte(pContext->add);
    do_crc8(pContext->add, &pContext->crc);
  }

  /* sending command identifier */
  wake_comm_stuffing_output_byte(pContext->cmd);
  do_crc8(pContext->cmd, &pContext->crc);

  /* sending number of payload bytes */
  wake_comm_stuffing_output_byte(pContext->nbt);
  do_crc8(pContext->nbt, &pContext->crc);

  if(pContext->nbt)
  {
    pContext->ptr = 0;
    while(pContext->ptr < pContext->nbt)
    {
      wake_comm_stuffing_output_byte(pContext->dat[pContext->ptr]);
      do_crc8(pContext->dat[pContext->ptr], &pContext->crc);
      pContext->ptr++;
    }
  }

  /* sending CRC */
  wake_comm_stuffing_output_byte(pContext->crc);

  SET_NEXT_CONTEXT(wake_glob.tx_context_rd);
  return true;
}
/*---------------------------------------------------------------------------*/
void wake_comm_init(wake_comm_io_func_t send_func, wake_comm_io_func_t recv_func)
{
  wake_glob.wake_comm_send_func = send_func;
  wake_glob.wake_comm_recv_func = recv_func;

  for(uint8_t i = 0; i < CONSEC_PACK_MAX; i++)
  {
    wake_glob.rx_context[i].add = RX_ADDR;
  }
}
/*---------------------------------------------------------------------------*/
 void wake_comm_send_callback_func(void)
{
}
/*---------------------------------------------------------------------------*/
 void wake_comm_recv_callback_func(uint8_t id_cmd, uint8_t *data, uint8_t size)
{
}
