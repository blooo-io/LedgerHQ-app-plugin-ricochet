#include "ricochet_plugin.h"

// Copies the whole parameter (32 bytes long) from `src` to `dst`.
// Useful for numbers, data...
static void copy_parameter(uint8_t *dst, size_t dst_len, uint8_t *src) {
    // Take the minimum between dst_len and parameter_length to make sure we don't overwrite memory.
    size_t len = MIN(dst_len, PARAMETER_LENGTH);
    memcpy(dst, src, len);
}

// Copy amount sent parameter to amoun
static void handle_amount(const ethPluginProvideParameter_t *msg, context_t *context) {
    copy_parameter(context->amount, sizeof(context->amount), msg->parameter);
}

void handle_provide_parameter(void *parameters) {
    ethPluginProvideParameter_t *msg = (ethPluginProvideParameter_t *) parameters;
    context_t *context = (context_t *) msg->pluginContext;

    memset(context->contract_address_received, 0, sizeof(context->contract_address_received));
    memcpy(context->contract_address_received,
           msg->pluginSharedRO->txContent->destination,
           sizeof(context->contract_address_received));

    uint8_t i;
    super_token_ticker_t *currentToken = NULL;
    for (i = 0; i < NUM_SUPER_TOKEN_COLLECTION; i++) {
        currentToken = (super_token_ticker_t *) PIC(&SUPER_TOKEN_COLLECTION[i]);
        if (memcmp(currentToken->token_address,
                   context->contract_address_received,
                   ADDRESS_LENGTH) == 0 &&
            (context->selectorIndex == DOWNGRADE || context->selectorIndex == DOWNGRADE_TO_ETH)) {
            memset(context->contract_address_sent, 0, sizeof(context->contract_address_sent));
            memcpy(context->contract_address_sent,
                   currentToken->super_token_address,
                   sizeof(context->contract_address_sent));
            break;
        } else if (memcmp(currentToken->super_token_address,
                          context->contract_address_received,
                          ADDRESS_LENGTH) == 0 &&
                   context->selectorIndex == UPGRADE) {
            memset(context->contract_address_sent, 0, sizeof(context->contract_address_sent));
            memcpy(context->contract_address_sent,
                   currentToken->token_address,
                   sizeof(context->contract_address_sent));
            break;
        }
    }

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
            case DOWNGRADE_TO_ETH:
            case UPGRADE:
                handle_amount(msg, context);
                break;
            default:
                PRINTF("Selector Index not supported: %d\n", context->selectorIndex);
                msg->result = ETH_PLUGIN_RESULT_ERROR;
                break;
        }
    }
}
