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

static void handle_agreement_class(const ethPluginProvideParameter_t *msg, context_t *context) {
    memset(context->contract_address_sent, 0, sizeof(context->contract_address_sent));
    memcpy(context->contract_address_sent,
           &msg->parameter[PARAMETER_LENGTH - ADDRESS_LENGTH],
           sizeof(context->contract_address_sent));
}

static void handle_method_cfa(ethPluginProvideParameter_t *msg, context_t *context) {
    memset(context->method_cfa, 0, sizeof(context->method_cfa));
    memcpy(context->method_cfa, &msg->parameter[0], sizeof(context->method_cfa));
}

static void handle_token_first_part(ethPluginProvideParameter_t *msg, context_t *context) {
    memset(context->token_address, 0, sizeof(context->token_address));
    memcpy(context->token_address,
           &msg->parameter[PARAMETER_LENGTH - ADDRESS_LENGTH + SELECTOR_SIZE],
           sizeof(context->token_address) - SELECTOR_SIZE);
}

static void handle_token_second_part(ethPluginProvideParameter_t *msg, context_t *context) {
    // memset(context->token_address, 0, sizeof(context->token_address));
    memcpy(&context->token_address[ADDRESS_LENGTH - SELECTOR_SIZE],
           &msg->parameter[0],
           SELECTOR_SIZE);
}

static void handle_sent_address_first_part(ethPluginProvideParameter_t *msg, context_t *context) {
    memset(context->contract_address_sent, 0, sizeof(context->contract_address_sent));
    memcpy(context->contract_address_sent,
           &msg->parameter[PARAMETER_LENGTH - ADDRESS_LENGTH + SELECTOR_SIZE],
           sizeof(context->contract_address_sent) - SELECTOR_SIZE);
}

static void handle_sent_address_second_part(ethPluginProvideParameter_t *msg, context_t *context) {
    memcpy(&context->contract_address_sent[ADDRESS_LENGTH - SELECTOR_SIZE],
           &msg->parameter[0],
           SELECTOR_SIZE);
}

static void handle_receive_address_first_part(ethPluginProvideParameter_t *msg,
                                              context_t *context) {
    memset(context->contract_address_received, 0, sizeof(context->contract_address_received));
    memcpy(context->contract_address_received,
           &msg->parameter[PARAMETER_LENGTH - ADDRESS_LENGTH + SELECTOR_SIZE],
           sizeof(context->contract_address_received) - SELECTOR_SIZE);
}

static void handle_receive_address_second_part(ethPluginProvideParameter_t *msg,
                                               context_t *context) {
    memcpy(&context->contract_address_received[ADDRESS_LENGTH - SELECTOR_SIZE],
           &msg->parameter[0],
           SELECTOR_SIZE);
}

static void handle_call_agreement(ethPluginProvideParameter_t *msg, context_t *context) {
    if (context->go_to_offset == 1) {
        if (msg->parameterOffset != context->offset + SELECTOR_SIZE) {
            return;
        }
        context->go_to_offset = 0;
    }

    switch (context->next_param) {
        case AGREEMENT_CLASS:
            handle_agreement_class(msg, context);
            context->next_param = PATH_OFFSET;
            break;
        case PATH_OFFSET:
            context->offset = U2BE(msg->parameter, PARAMETER_LENGTH - sizeof(context->offset));
            context->next_param = PATH_LENGTH;
            context->skip++;
            break;
        case PATH_LENGTH:
            context->array_len =
                U2BE(msg->parameter, PARAMETER_LENGTH - sizeof(context->array_len));
            context->offset = msg->parameterOffset - SELECTOR_SIZE + PARAMETER_LENGTH;
            context->next_param = CALL_DATA;
            break;
        case CALL_DATA:

            // Parse Second ABI Encoded Input Data
            if (msg->parameterOffset == 132) {
                handle_method_cfa(msg, context);
                handle_token_first_part(msg, context);
            }
            if (msg->parameterOffset == 164) {
                handle_token_second_part(msg, context);
                handle_sent_address_first_part(msg, context);
            }
            if (msg->parameterOffset == 196) {
                handle_sent_address_second_part(msg, context);
                handle_receive_address_first_part(msg, context);
            }
            if (msg->parameterOffset == 228) {
                handle_receive_address_second_part(msg, context);
            }

            if (msg->parameterOffset >= (context->offset + context->array_len)) {
                context->next_param = NONE;
            } else {
                context->next_param = CALL_DATA;
            }
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
        switch (context->selectorIndex) {
            case DOWNGRADE:
            case DOWNGRADE_TO_ETH:
            case UPGRADE:
                handle_amount(msg, context);
                break;
            case CALL_AGREEMENT:
                handle_call_agreement(msg, context);
                break;
            default:
                PRINTF("Selector Index not supported: %d\n", context->selectorIndex);
                msg->result = ETH_PLUGIN_RESULT_ERROR;
                break;
        }
    }
}
