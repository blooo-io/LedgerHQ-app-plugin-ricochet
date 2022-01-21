#include "ricochet_plugin.h"


void handle_downgrade_tokens(ethPluginProvideToken_t *msg, context_t *context) {

    super_token_ticker_t *currentToken = NULL;
    for (uint8_t i = 0; i < NUM_SUPER_TOKEN_COLLECTION; i++) {
        currentToken = (super_token_ticker_t *) PIC(&SUPER_TOKEN_COLLECTION[i]);
        if (memcmp(currentToken->super_token_address,
                   context->contract_address_received,
                   ADDRESS_LENGTH) == 0) {

            strlcpy(context->ticker_sent,
                    (char *) currentToken->ticker_super_token,
                    sizeof(context->ticker_sent));
            strlcpy(context->ticker_received,
                    (char *) currentToken->ticker_token,
                    sizeof(context->ticker_received));
            break;
        }
    }
}


void handle_upgrade_tokens(ethPluginProvideToken_t *msg, context_t *context) {

    super_token_ticker_t *currentToken = NULL;
    for (uint8_t i = 0; i < NUM_SUPER_TOKEN_COLLECTION; i++) {
        currentToken = (super_token_ticker_t *) PIC(&SUPER_TOKEN_COLLECTION[i]);
        if (memcmp(currentToken->super_token_address,
                   context->contract_address_received,
                   ADDRESS_LENGTH) == 0) {

            strlcpy(context->ticker_sent,
                    (char *) currentToken->ticker_token,
                    sizeof(context->ticker_sent));
            strlcpy(context->ticker_received,
                    (char *) currentToken->ticker_super_token,
                    sizeof(context->ticker_received));
            break;
        }
    }
}


void handle_received_address(ethPluginProvideToken_t *msg, context_t *context) {
    memset(context->contract_address_received, 0, sizeof(context->contract_address_received));
    memcpy(context->contract_address_received,
           msg->pluginSharedRO->txContent->destination,
           sizeof(context->contract_address_received));
}

void handle_provide_token(void *parameters) {
    ethPluginProvideToken_t *msg = (ethPluginProvideToken_t *) parameters;
    context_t *context = (context_t *) msg->pluginContext;

    handle_received_address(msg, context);

    switch (context->selectorIndex) {
        case DOWNGRADE:
        case DOWNGRADE_TO_ETH:
            context->decimals = DEFAULT_DECIMAL;
            handle_downgrade_tokens(msg, context);
            break;
        case UPGRADE:
        case UPGRADE_TO_ETH:
            handle_upgrade_tokens(msg, context);
            break;
        default:
            break;
    }

    msg->result = ETH_PLUGIN_RESULT_OK;
}
