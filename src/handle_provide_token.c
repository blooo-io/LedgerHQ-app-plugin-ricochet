#include "ricochet_plugin.h"

void handle_provide_token(void *parameters) {
    ethPluginProvideToken_t *msg = (ethPluginProvideToken_t *) parameters;
    context_t *context = (context_t *) msg->pluginContext;

    //  PRINTF("Setting address sent to5: %.*H\n", ADDRESS_LENGTH, msg->token1->address);

    PRINTF("Setting address sent to (provide): %.*H \n\n",
           msg->pluginSharedRO->txContent->gasprice.value);
    PRINTF("Setting address sent to (provide): %.*H \n\n",
           msg->pluginSharedRO->txContent->value.value);
    PRINTF("Setting address sent to (provide): %.*H \n\n",
           msg->pluginSharedRO->txContent->nonce.value);
    PRINTF("Setting address sent to (provide): %.*H \n\n",
           msg->pluginSharedRO->txContent->startgas.value);
    PRINTF("Setting address sent to (provide): %.*H \n\n",
           msg->pluginSharedRO->txContent->chainID.value);

    // if (ADDRESS_IS_NETWORK_TOKEN(context->contract_address_sent)) {
    //     context->decimals_sent = WEI_TO_ETHER;
    //     context->tokens_found |= TOKEN_SENT_FOUND;
    // } else
    // if (msg->token1 != NULL) {
    //     context->decimals_sent = msg->token1->decimals;
    //     strlcpy(context->ticker_sent, (char *) msg->token1->ticker,
    //     sizeof(context->ticker_sent)); PRINTF("Setting address sent to5: %c\n",
    //     context->ticker_sent); context->tokens_found |= TOKEN_SENT_FOUND;
    // } else {
    //     // CAL did not find the token and token is not ETH.
    //     context->decimals_sent = DEFAULT_DECIMAL;
    //     // We will need an additional screen to display a warning message.
    //     // msg->additionalScreens++;
    // }
    if (msg->token1) {
        // The Ethereum App found the information for the requested token!
        // Store its decimals.
        context->decimals = msg->token1->decimals;
        // Store its ticker.
        strlcpy(context->ticker, (char *) msg->token1->ticker, sizeof(context->ticker));
        PRINTF("Setting address sent to (finalize if )");
        // Keep track of the token found.
        context->token_found = true;
    } else {
        // The Ethereum App did not manage to find
        // the info for the requested token.
        context->token_found = false;

        // Default to ETH decimals (for wei).
        context->decimals = 18;
        // Default to "???" when information was not found.
        strlcpy(context->ticker, "???", sizeof(context->ticker));

        // If we wanted to add a screen, say a warning screen for example,
        // then we tell the Ethereum app to add an additional screen
        // by setting `msg->additionalScreens` here, just like so:
        // msg->additionalScreens = 1;
    }

    msg->result = ETH_PLUGIN_RESULT_OK;
}
