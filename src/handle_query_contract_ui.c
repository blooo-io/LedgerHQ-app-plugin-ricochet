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

static unsigned long long amountToDecimal(context_t *context, int size) {
    long long int value = 0;
    for (uint8_t i = 0; i < size; i++) {
        value = value * 256 + context->amount[i];
    }
    return value;
}

static void decimalToAmount(unsigned long long value, context_t *context) {
    uint8_t i = 0, rem;
    memset(context->amount, 0, sizeof(context->amount));
    do {
        rem = (int) (value % 256);
        value /= 256;
        context->amount[sizeof(context->amount) - i - 1] = rem;
        i++;
    } while (value != 0);
}

static void set_amount_ui(ethQueryContractUI_t *msg, context_t *context) {
    strlcpy(msg->title, "Send", msg->titleLength);

    amountToString(context->amount,
                   sizeof(context->amount),
                   DEFAULT_DECIMAL,
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

    if (context->method_id != STOP_STREAM) {
        unsigned long long value = amountToDecimal(context, sizeof(context->amount));
        value *= 2592000;  // switch from token per sec to token per month for UX only.
        decimalToAmount(value, context);

        amountToString(context->amount,
                       sizeof(context->amount),
                       DEFAULT_DECIMAL,
                       context->ticker_sent,
                       msg->msg,
                       msg->msgLength);

        strlcat(msg->msg, " per month", msg->msgLength);

    } else {
        strlcpy(msg->msg, context->ticker_sent, msg->msgLength);
    }
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

static void set_batch_call_from_ui(ethQueryContractUI_t *msg, context_t *context) {
    strlcpy(msg->title, "From", msg->titleLength);

    contract_address_ticker_t *currentTicker = NULL;

    for (uint8_t i = 0; i < NUM_CONTRACT_ADDRESS_COLLECTION; i++) {
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

    unsigned long long value = amountToDecimal(context, sizeof(context->amount));
    value *= 2592000;  // switch from token per sec to token per month for UX only.

    decimalToAmount(value, context);

    amountToString(context->amount,
                   sizeof(context->amount),
                   DEFAULT_DECIMAL,
                   context->ticker_sent,
                   msg->msg,
                   msg->msgLength);

    strlcat(msg->msg, " per month", msg->msgLength);

}

static void set_batch_call_to_ui(ethQueryContractUI_t *msg, context_t *context) {
    strlcpy(msg->title, "To", msg->titleLength);

    contract_address_ticker_t *currentTicker = NULL;

    for (uint8_t i = 0; i < NUM_CONTRACT_ADDRESS_COLLECTION; i++) {
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

static void set_receive_ui(ethQueryContractUI_t *msg, context_t *context) {
    strlcpy(msg->title, "Receive", msg->titleLength);
    amountToString(context->amount,
                   sizeof(context->amount),
                   DEFAULT_DECIMAL,
                   context->ticker_received,
                   msg->msg,
                   msg->msgLength);
}

// Helper function that returns the enum corresponding to the screen that should be displayed.
static screens_t get_screen(const ethQueryContractUI_t *msg) {
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

    screens_t screen = get_screen(msg);

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

        case BATCH_CALL:
            switch (screen) {
                case SEND_SCREEN:
                    set_batch_call_from_ui(msg, context);
                    break;
                case RECEIVE_SCREEN:
                    set_batch_call_to_ui(msg, context);
                    break;
                default:
                    break;
            }

        default:
            PRINTF("Missing selectorIndex: %d\n", context->selectorIndex);
            msg->result = ETH_PLUGIN_RESULT_ERROR;
            return;
    }
}