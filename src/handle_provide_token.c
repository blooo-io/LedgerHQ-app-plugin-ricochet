#include "ricochet_plugin.h"

void handle_provide_token(void *parameters) {
    ethPluginProvideToken_t *msg = (ethPluginProvideToken_t *) parameters;
    context_t *context = (context_t *) msg->pluginContext;

    if (msg->token1 != NULL) {
        context->decimals = msg->token1->decimals;
        strlcpy(context->ticker, (char *) msg->token1->ticker, sizeof(context->ticker));
        context->tokens_found |= TOKEN_FOUND;
    } else {
        // CAL did not find the token and token is not ETH.
        context->decimals = DEFAULT_DECIMAL;
        // We will need an additional screen to display a warning message.
        msg->additionalScreens++;
    }

    msg->result = ETH_PLUGIN_RESULT_OK;
}