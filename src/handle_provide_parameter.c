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

static void handle_upgrade(ethPluginProvideParameter_t *msg, context_t *context) {
    switch (context->next_param) {
        case AMOUNT:
            handle_amount(msg, context);
            context->next_param = NONE;
            break;
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

    memset(context->contract_address_received, 0, sizeof(context->contract_address_received));
    memcpy(context->contract_address_received,
           DAI_TEST,
           sizeof(context->contract_address_received));
    // PRINTF("Contract Addr: %.*H\n", ADDRESS_LENGTH, context->contract_address_received);

    // print_bytes(msg->pluginSharedRO->txContent->destination,
    //             sizeof(msg->pluginSharedRO->txContent->destination));

    // PRINTF("Destination: %.*H\n", ADDRESS_LENGTH, msg->pluginSharedRO->txContent->destination);

    // PRINTF("DAI_TEST: %.*H\n", ADDRESS_LENGTH, DAI_TEST);
    // print_bytes(DAI_TEST, sizeof(DAI_TEST));

    memset(context->contract_address_sent, 0, sizeof(context->contract_address_sent));
    memcpy(context->contract_address_sent, DAI_TEST, sizeof(context->contract_address_sent));

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
            // case DOWNGRADE:
            //     handle_upgrade_downgrade(msg, context);
            // break;
            case UPGRADE:
                handle_upgrade(msg, context);
                break;
            default:
                PRINTF("Selector Index not supported: %d\n", context->selectorIndex);
                msg->result = ETH_PLUGIN_RESULT_ERROR;
                break;
        }
    }
}
