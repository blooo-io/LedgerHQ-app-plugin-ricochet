#include "ricochet_plugin.h"
// Set UI for the "Send" screen.

// function to compare array elements
char compare_array(uint8_t a[], uint8_t b[], int size) {
    int i;
    for (i = 0; i < size; i++) {
        if (a[i] != b[i]) return 1;
    }
    return 0;
}

static void set_amount_ui(ethQueryContractUI_t *msg, context_t *context) {
    strlcpy(msg->title, "Send", msg->titleLength);

    amountToString(context->amount,
                   sizeof(context->amount),
                   0,
                   context->ticker_sent,
                   msg->msg,
                   msg->msgLength);
}

static void set_cfa_from_ui(ethQueryContractUI_t *msg, context_t *context) {
    strlcpy(msg->title, "From", msg->titleLength);

    uint8_t i;
    contract_address_ticker_t *currentTicker = NULL;

    for (i = 0; i < NUM_CONTRACT_ADDRESS_COLLECTION; i++) {
        currentTicker = (contract_address_ticker_t *) PIC(&CONTRACT_ADDRESS_COLLECTION[i]);
        if (compare_array(currentTicker->contract_address,
                          context->contract_address_received,
                          ADDRESS_LENGTH) == 0) {
            strlcpy(context->ticker_sent,
                    (char *) currentTicker->ticker_sent,
                    sizeof(context->ticker_sent));
            break;
        }
    }
    strlcpy(msg->msg, context->ticker_sent, msg->msgLength);
}

static void set_cfa_to_ui(ethQueryContractUI_t *msg, context_t *context) {
    strlcpy(msg->title, "To", msg->titleLength);

    uint8_t i;
    contract_address_ticker_t *currentTicker = NULL;

    for (i = 0; i < NUM_CONTRACT_ADDRESS_COLLECTION; i++) {
        currentTicker = (contract_address_ticker_t *) PIC(&CONTRACT_ADDRESS_COLLECTION[i]);
        if (compare_array(currentTicker->contract_address,
                          context->contract_address_received,
                          ADDRESS_LENGTH) == 0) {
            strlcpy(context->ticker_received,
                    (char *) currentTicker->ticker_received,
                    sizeof(context->ticker_received));
            break;
        }
    }
    strlcpy(msg->msg, context->ticker_received, msg->msgLength);
}

static void set_upgrade_to_eth_send_ui(ethQueryContractUI_t *msg, context_t *context) {
    strlcpy(msg->title, "Send", msg->titleLength);

    amountToString(msg->pluginSharedRO->txContent->value.value,
                   msg->pluginSharedRO->txContent->value.length,
                   DEFAULT_DECIMAL,
                   context->ticker_sent,
                   msg->msg,
                   msg->msgLength);
}

static void set_upgrade_to_eth_received_ui(ethQueryContractUI_t *msg, context_t *context) {
    strlcpy(msg->title, "Receive", msg->titleLength);

    amountToString(msg->pluginSharedRO->txContent->value.value,
                   msg->pluginSharedRO->txContent->value.length,
                   DEFAULT_DECIMAL,
                   context->ticker_received,
                   msg->msg,
                   msg->msgLength);
}

// static void set_distribute_received_ui(ethQueryContractUI_t *msg, context_t *context) {
//     strlcpy(msg->title, "Receive", msg->titleLength);

//     uint8_t i;
//     contract_address_ticker *currentTicker = NULL;

//     for (i = 0; i < NUM_CONTRACT_ADDRESS_COLLECTION; i++) {
//         currentTicker = (contract_address_ticker *) PIC(&CONTRACT_ADDRESS_COLLECTION[i]);
//         if (compare_array(currentTicker->contract_address,
//                           msg->pluginSharedRO->txContent->destination,
//                           ADDRESS_LENGTH) == 0) {
//             strlcpy(context->ticker_received,
//                     (char *) currentTicker->ticker_received,
//                     sizeof(context->ticker_received));
//             break;
//         }
//     }
//     strlcpy(msg->msg, context->ticker_received, msg->msgLength);
// }

static void set_receive_ui(ethQueryContractUI_t *msg, context_t *context) {
    strlcpy(msg->title, "Receive", msg->titleLength);
    amountToString(context->amount,
                   sizeof(context->amount),
                   0,
                   context->ticker_received,
                   msg->msg,
                   msg->msgLength);
}

// Helper function that returns the enum corresponding to the screen that should be displayed.
static screens_t get_screen(const ethQueryContractUI_t *msg, const context_t *context) {
    uint8_t index = msg->screenIndex;

    switch (index) {
        case 0:
            return SEND_SCREEN;
            break;
        case 1:
            return RECEIVE_SCREEN;
            break;
        default:
            return ERROR;
            break;
    }
}

void handle_query_contract_ui(void *parameters) {
    ethQueryContractUI_t *msg = (ethQueryContractUI_t *) parameters;
    context_t *context = (context_t *) msg->pluginContext;

    memset(msg->title, 0, msg->titleLength);
    memset(msg->msg, 0, msg->msgLength);
    msg->result = ETH_PLUGIN_RESULT_OK;

    screens_t screen = get_screen(msg, context);

    switch (context->selectorIndex) {
        case DOWNGRADE:
        case DOWNGRADE_TO_ETH:
        case UPGRADE:
            switch (screen) {
                case SEND_SCREEN:
                    set_amount_ui(msg, context);
                    break;
                case RECEIVE_SCREEN:
                    set_receive_ui(msg, context);
                    break;
                default:
                    PRINTF("Received an invalid screenIndex\n");
                    msg->result = ETH_PLUGIN_RESULT_ERROR;
                    return;
            }
            break;
        case CALL_AGREEMENT:
            PRINTF("CALL_AGREEMENT: QUERY CONTRACT UI\n");

            switch (screen) {
                case SEND_SCREEN:
                    set_cfa_from_ui(msg, context);
                    break;
                case RECEIVE_SCREEN:
                    set_cfa_to_ui(msg, context);
                    break;
                default:
                    PRINTF("Received an invalid screenIndex\n");
                    msg->result = ETH_PLUGIN_RESULT_ERROR;
                    return;
            }
            break;
        case UPGRADE_TO_ETH:
            switch (screen) {
                case SEND_SCREEN:
                    set_upgrade_to_eth_send_ui(msg, context);
                    break;
                case RECEIVE_SCREEN:
                    set_upgrade_to_eth_received_ui(msg, context);
                default:
                    PRINTF("Received an invalid screenIndex\n");
                    msg->result = ETH_PLUGIN_RESULT_ERROR;
                    return;
            }
            break;
        default:
            PRINTF("Missing selectorIndex: %d\n", context->selectorIndex);
            msg->result = ETH_PLUGIN_RESULT_ERROR;
            return;
    }
}