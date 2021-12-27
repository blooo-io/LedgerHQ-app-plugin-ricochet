#include "poap_plugin.h"

// Copies the whole parameter (32 bytes long) from `src` to `dst`.
// Useful for numbers, data...
static void copy_parameter(uint8_t *dst, uint8_t *src) {
    memcpy(dst, src, PARAMETER_LENGTH);
}

// Copy token sent parameter to token_id
static void handle_token(const ethPluginProvideParameter_t *msg, context_t *context) {
    copy_parameter(context->token_id, msg->parameter);
}

static void handle_beneficiary(const ethPluginProvideParameter_t *msg, context_t *context) {
    memset(context->beneficiary, 0, sizeof(context->beneficiary));
    memcpy(context->beneficiary,
           &msg->parameter[PARAMETER_LENGTH - ADDRESS_LENGTH],
           sizeof(context->beneficiary));
    PRINTF("BENEFICIARY: %.*H\n", ADDRESS_LENGTH, context->beneficiary);
}

static void handle_from_address(const ethPluginProvideParameter_t *msg, context_t *context) {
    memset(context->from_address, 0, sizeof(context->from_address));
    memcpy(context->from_address,
           &msg->parameter[PARAMETER_LENGTH - ADDRESS_LENGTH],
           sizeof(context->from_address));
    PRINTF("FROM_ADDRESS: %.*H\n", ADDRESS_LENGTH, context->from_address);
}
static void handle_mint_token(ethPluginProvideParameter_t *msg, context_t *context) {
    switch (context->next_param) {
        case EVENT_ID:
            context->next_param = TOKEN;
            break;
        case TOKEN:  // id of the token received
            handle_token(msg, context);
            context->next_param = BENEFICIARY;
            break;
        case BENEFICIARY:  // to
            handle_beneficiary(msg, context);
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
static void handle_safe_transfer(ethPluginProvideParameter_t *msg, context_t *context) {
    switch (context->next_param) {
        case FROM_ADDRESS:  // from_address
            handle_from_address(msg, context);
            context->next_param = BENEFICIARY;
            break;
        case BENEFICIARY:  // to
            handle_beneficiary(msg, context);
            context->next_param = TOKEN;
            break;
        case TOKEN:  // id of the token received
            handle_token(msg, context);
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
            case MINT_TOKEN:
                handle_mint_token(msg, context);
                break;
            case SAFE_TRANSFER:
                handle_safe_transfer(msg, context);
                break;
            default:
                PRINTF("Selector Index not supported: %d\n", context->selectorIndex);
                msg->result = ETH_PLUGIN_RESULT_ERROR;
                break;
        }
    }
}
