#include "ricochet_plugin.h"
// Set UI for the "Send" screen.

static void set_amount_ui(ethQueryContractUI_t *msg, context_t *context) {
    strlcpy(msg->title, "Send", msg->titleLength);

    // if (ADDRESS_IS_NETWORK_TOKEN(context->contract_address_sent)) {
    //     strlcpy(context->ticker_sent, msg->network_ticker, sizeof(context->ticker_sent));
    // }

    amountToString(context->amount,
                   sizeof(context->amount),
                   0,
                   context->ticker_sent,
                   msg->msg,
                   msg->msgLength);
}

// Set UI for "Warning" screen.
static void set_warning_ui(ethQueryContractUI_t *msg,
                           const context_t *context __attribute__((unused))) {
    strlcpy(msg->title, "WARNING", msg->titleLength);
    strlcpy(msg->msg, "Unknown token", msg->msgLength);
}

static void set_receive_ui(ethQueryContractUI_t *msg, context_t *context) {
    strlcpy(msg->title, "Receive", msg->titleLength);
    // if (ADDRESS_IS_NETWORK_TOKEN(context->contract_address_received)) {
    //     strlcpy(context->ticker_received, msg->network_ticker, sizeof(context->ticker_received));
    // }

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
}