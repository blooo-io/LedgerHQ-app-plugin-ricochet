#include "ricochet_plugin.h"

// Copies the whole parameter (32 bytes long) from `src` to `dst`.
// Useful for numbers, data...
static void copy_parameter(uint8_t *dst, size_t dst_len, uint8_t *src) {
    // Take the minimum between dst_len and parameter_length to make sure we don't overwrite memory.
    size_t len = MIN(dst_len, PARAMETER_LENGTH);
    memcpy(dst, src, len);
}

// Copy amount sent parameter to amount_sent
static void handle_amount(const ethPluginProvideParameter_t *msg, context_t *context) {
    copy_parameter(context->amount, sizeof(context->amount), msg->parameter);
}

// Copy amount sent parameter to amount_received
static void handle_amount_received(const ethPluginProvideParameter_t *msg, context_t *context) {
    copy_parameter(context->amount, sizeof(context->amount), msg->parameter);
}

// static void handle_token_sent(const ethPluginProvideParameter_t *msg, context_t *context) {
//     memset(context->contract_address_sent, 0, sizeof(context->contract_address_sent));
//     memcpy(context->contract_address_sent,
//            &msg->parameter[PARAMETER_LENGTH - ADDRESS_LENGTH],
//            sizeof(context->contract_address_sent));
//     PRINTF("TOKEN SENT: %.*H\n", ADDRESS_LENGTH, context->contract_address_sent);
// }

// static void handle_token_received(const ethPluginProvideParameter_t *msg, context_t *context) {
//     memset(context->contract_address_received, 0, sizeof(context->contract_address_received));
//     memcpy(context->contract_address_received,
//            &msg->parameter[PARAMETER_LENGTH - ADDRESS_LENGTH],
//            sizeof(context->contract_address_received));
//     PRINTF("TOKEN RECEIVED: %.*H\n", ADDRESS_LENGTH, context->contract_address_received);
// }

static void handle_upgrade_downgrade(ethPluginProvideParameter_t *msg, context_t *context) {
    // PRINTF("Setting address sent to (provide param): %d\n",
    //        msg->pluginSharedRO->txContent->gasprice.value);
    // PRINTF("Setting address sent to (provide param): %d\n",
    //        msg->pluginSharedRO->txContent->value.value);
    // PRINTF("Setting address sent to (provide param): %d\n",
    //        msg->pluginSharedRO->txContent->nonce.value);
    // PRINTF("Setting address sent to (provide param): %d\n",
    //        msg->pluginSharedRO->txContent->startgas.value);
    // PRINTF("Setting address sent to (provide param): %d\n",
    //        msg->pluginSharedRO->txContent->chainID.value);

    // PRINTF("Setting address sent to (provide param): %d\n", msg->parameterOffset);

    switch (context->next_param) {
        case AMOUNT:
            handle_amount(msg, context);
            context->next_param = AMOUNT_RECEIVED;
            break;
        case AMOUNT_RECEIVED:
            handle_amount_received(msg, context);
            context->next_param = NONE;
            break;
        // case TOKEN_SENT:
        //     handle_token_sent(msg, context);
        //     context->next_param = TOKEN_RECEIVE;
        // case TOKEN_RECEIVE:
        //     handle_token_received(msg, context);
        //     context->next_param = NONE;
        case NONE:
            break;
        default:
            PRINTF("Param not supported\n");
            msg->result = ETH_PLUGIN_RESULT_ERROR;
            break;
    }
}

void handle_provide_parameter(void *parameters) {
    ethPluginProvideParameter_t *msg = (ethPluginProvideParameter_t *) parameters;
    context_t *context = (context_t *) msg->pluginContext;

    msg->result = ETH_PLUGIN_RESULT_OK;

    if (context->skip) {
        // Skip this step, and don't forget to decrease skipping counter.
        context->skip--;
    } else {
        if ((context->offset) && msg->parameterOffset != context->checkpoint + context->offset) {
            PRINTF("offset: %d, checkpoint: %d, parameterOffset: %d\n",
                   context->offset,
                   context->checkpoint,
                   msg->parameterOffset);
            return;
        }
        context->offset = 0;  // Reset offset
        switch (context->selectorIndex) {
            case DOWNGRADE:
                handle_upgrade_downgrade(msg, context);
                break;
            case UPGRADE:
                handle_upgrade_downgrade(msg, context);
                break;
            default:
                PRINTF("Selector Index not supported: %d\n", context->selectorIndex);
                msg->result = ETH_PLUGIN_RESULT_ERROR;
                break;
        }
    }
}
