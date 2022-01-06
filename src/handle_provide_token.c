#include "ricochet_plugin.h"

void handle_tokens(ethPluginProvideToken_t *msg, context_t *context) {
    int index;

    for (index = 0; index < SUPER_TOKEN_COLLECTION; index++) {
        if (compare_array(super_token_collection[index].super_token_address,
                          context->contract_address_sent,
                          ADDRESS_LENGTH) == 0) {
            strlcpy(context->ticker_received,
                    (char *) super_token_collection[index].ticker,
                    sizeof(context->ticker_received));
            break;
        }
    }
}

void handle_provide_token(void *parameters) {
    ethPluginProvideToken_t *msg = (ethPluginProvideToken_t *) parameters;
    context_t *context = (context_t *) msg->pluginContext;

    PRINTF("RICOCHET plugin provide token: 0x%p\n", msg->token1);

    if (ADDRESS_IS_NETWORK_TOKEN(context->contract_address_sent)) {
        context->decimals = WEI_TO_ETHER;
        context->tokens_found |= TOKEN_SENT_FOUND;
    } else if (msg->token1 != NULL) {
        context->decimals = msg->token1->decimals;
        strlcpy(context->ticker_sent, (char *) msg->token1->ticker, sizeof(context->ticker_sent));
        context->tokens_found |= TOKEN_SENT_FOUND;
    } else {
        context->decimals = DEFAULT_DECIMAL;
        strlcpy(context->ticker_sent, "???", sizeof(context->ticker_sent));
        msg->additionalScreens++;
    }
    // else {
    //     PRINTF("RICOCHET plugin provide token3: 0x%p\n", msg->token1);
    //     // CAL did not find the token and token is not ETH.
    //     context->decimals = DEFAULT_DECIMAL;
    //     // We will need an additional screen to display a warning message.
    //     msg->additionalScreens++;

    // handle_tokens(msg, context);
    // }

    msg->result = ETH_PLUGIN_RESULT_OK;
}
