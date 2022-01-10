#include "ricochet_plugin.h"

void handle_ticker_super_token(ethPluginProvideToken_t *msg, context_t *context) {
    int index;
    PRINTF("RICOCHET TICKET provide token: 0x%p\n", msg->token1);
    for (index = 0; index < SUPER_TOKEN_COLLECTION; index++) {
        if (compare_array(super_token_collection[index].super_token_address,
                          context->contract_address_sent,
                          ADDRESS_LENGTH) == 0) {
            strlcpy(context->ticker_sent,
                    (char *) super_token_collection[index].ticker_super_token,
                    sizeof(context->ticker_sent));
            break;
        }
    }
}

void handle_ticker_token(ethPluginProvideToken_t *msg, context_t *context) {
    int index;
    for (index = 0; index < SUPER_TOKEN_COLLECTION; index++) {
        if (compare_array(super_token_collection[index].token_address,
                          context->contract_address_received,
                          ADDRESS_LENGTH) == 0) {
            strlcpy(context->ticker_received,
                    (char *) super_token_collection[index].ticker_token,
                    sizeof(context->ticker_received));
            break;
        }
    }
}

void handle_provide_token(void *parameters) {
    ethPluginProvideToken_t *msg = (ethPluginProvideToken_t *) parameters;
    context_t *context = (context_t *) msg->pluginContext;

    PRINTF("RICOCHET plugin provide token: 0x%p\n", msg->token1);

    if (ADDRESS_IS_NETWORK_TOKEN(context->contract_address_received)) {
        context->decimals = WEI_TO_ETHER;
        context->tokens_found |= TOKEN_SENT_FOUND;
        handle_ticker_super_token(msg, context);
    } else if (msg->token1 != NULL) {
        context->decimals = msg->token1->decimals;
        strlcpy(context->ticker_received,
                (char *) msg->token1->ticker,
                sizeof(context->ticker_received));
        context->tokens_found |= TOKEN_SENT_FOUND;
        handle_ticker_super_token(msg, context);
    } else {
        context->decimals = DEFAULT_DECIMAL;
        print_bytes(context->contract_address_received, sizeof(context->contract_address_received));
        handle_ticker_token(msg, context);
        if (strlen(context->ticker_received) == 0) {
            strlcpy(context->ticker_received, "???", sizeof(context->ticker_received));
            msg->additionalScreens++;
        } else {
            handle_ticker_super_token(msg, context);
        }
    }

    msg->result = ETH_PLUGIN_RESULT_OK;
}
