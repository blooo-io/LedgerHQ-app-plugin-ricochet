#pragma once

#include "eth_internals.h"
#include "eth_plugin_interface.h"
#include <string.h>

#define NUM_SELECTORS        2
#define PLUGIN_NAME          "Ricochet"
#define TOKEN_FOUND          1 << 1
#define SELECTOR_SIZE        4
#define PARAMETER_LENGTH     32
#define RUN_APPLICATION      1
#define TOKEN_SENT_FOUND     1
#define TOKEN_RECEIVED_FOUND 1 << 1
#define DEFAULT_TICKER       ""

#define SUPER_TOKEN_COLLECTION 9

typedef enum { DOWNGRADE, DOWNGRADE_TO_ETH } selector_t;

// Enumeration used to parse the smart contract data.
#define AMOUNT 0
#define WAD    1
#define NONE   2

typedef enum { SEND_SCREEN, RECEIVE_SCREEN, ERROR } screens_t;

extern const uint8_t *const RICOCHET_SELECTORS[NUM_SELECTORS];

// Number of decimals used when the token wasn't found in the CAL.
#define DEFAULT_DECIMAL WEI_TO_ETHER

// uses `0xeeeee` as a dummy address to represent ETH.
extern const uint8_t RICOCHET_ETH_ADDRESS[ADDRESS_LENGTH];

// Adress 0x00000... used to indicate that the beneficiary is the sender.
extern const uint8_t NULL_ETH_ADDRESS[ADDRESS_LENGTH];

extern const uint8_t DAI_TEST[ADDRESS_LENGTH];

extern const uint8_t DAIX_TEST[ADDRESS_LENGTH];

// Returns 1 if corresponding address is the Ricochet address for the chain token (ETH, BNB, MATIC,
// etc.. are 0xeeeee...).
#define ADDRESS_IS_NETWORK_TOKEN(_addr) (!memcmp(_addr, RICOCHET_ETH_ADDRESS, ADDRESS_LENGTH))

typedef struct super_token_ticker {
    uint8_t token_address[ADDRESS_LENGTH];
    uint8_t super_token_address[ADDRESS_LENGTH];
    char ticker_token[MAX_TICKER_LEN];
    char ticker_super_token[MAX_TICKER_LEN];

} super_token_ticker;

extern const super_token_ticker super_token_collection[SUPER_TOKEN_COLLECTION];

typedef struct context_t {
    // For display.
    uint8_t amount[INT256_LENGTH];
    uint8_t wad[INT256_LENGTH];
    uint8_t contract_address_sent[ADDRESS_LENGTH];
    uint8_t contract_address_received[ADDRESS_LENGTH];
    char ticker_sent[MAX_TICKER_LEN];
    char ticker_received[MAX_TICKER_LEN];

    uint16_t offset;
    uint16_t checkpoint;
    uint8_t next_param;
    uint8_t tokens_found;
    uint8_t valid;
    uint8_t decimals;
    uint8_t decimals_received;
    uint8_t selectorIndex;
    uint8_t array_len;
    uint8_t skip;
} context_t;

// Piece of code that will check that the above structure is not bigger than 5 * 32. Do not remove
// this check.
_Static_assert(sizeof(context_t) <= 5 * 32, "Structure of parameters too big.");

void handle_init_contract(void *parameters);
void handle_provide_parameter(void *parameters);
void handle_query_contract_ui(void *parameters);
void handle_finalize(void *parameters);
void handle_provide_token(void *parameters);
void handle_query_contract_id(void *parameters);