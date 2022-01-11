#include "ricochet_plugin.h"

void handle_ticker_super_token(ethPluginProvideToken_t *msg, context_t *context) {
    uint8_t i;

    super_token_ticker_t *currentSuperToken = NULL;
    for (i = 0; i < NUM_SUPER_TOKEN_COLLECTION; i++) {
        currentSuperToken = (super_token_ticker_t *) PIC(&SUPER_TOKEN_COLLECTION[i]);
        if (memcmp(currentSuperToken->super_token_address,
                   context->contract_address_sent,
                   ADDRESS_LENGTH) == 0) {
            strlcpy(context->ticker_sent,
                    (char *) currentSuperToken->ticker_super_token,
                    sizeof(context->ticker_sent));
            break;
        }
    }
}

void handle_ticker_token(ethPluginProvideToken_t *msg, context_t *context) {
    uint8_t i;
    super_token_ticker_t *currentToken = NULL;
    for (i = 0; i < NUM_SUPER_TOKEN_COLLECTION; i++) {
        currentToken = (super_token_ticker_t *) PIC(&SUPER_TOKEN_COLLECTION[i]);
        if (memcmp(currentToken->token_address,
                   context->contract_address_received,
                   ADDRESS_LENGTH) == 0) {
            strlcpy(context->ticker_received,
                    (char *) currentToken->ticker_token,
                    sizeof(context->ticker_received));
            break;
        }
    }
}

void handle_upgrade_token(ethPluginProvideToken_t *msg, context_t *context) {
    uint8_t i;
    super_token_ticker_t *currentToken = NULL;
    for (i = 0; i < NUM_SUPER_TOKEN_COLLECTION; i++) {
        currentToken = (super_token_ticker_t *) PIC(&SUPER_TOKEN_COLLECTION[i]);
        if (memcmp(currentToken->super_token_address,
                   context->contract_address_received,
                   ADDRESS_LENGTH) == 0 &&
            memcmp(currentToken->token_address, context->contract_address_sent, ADDRESS_LENGTH) ==
                0) {
            strlcpy(context->ticker_received,
                    (char *) currentToken->ticker_super_token,
                    sizeof(context->ticker_received));
            strlcpy(context->ticker_sent,
                    (char *) currentToken->ticker_token,
                    sizeof(context->ticker_sent));
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
    } else if (msg->token1 != NULL) {
        context->decimals = msg->token1->decimals;
        strlcpy(context->ticker_received,
                (char *) msg->token1->ticker,
                sizeof(context->ticker_received));
        context->tokens_found |= TOKEN_SENT_FOUND;
        handle_ticker_super_token(msg, context);
    } else if (context->selectorIndex == DOWNGRADE ||
               context->selectorIndex == DOWNGRADE_TO_ETH) {  // WETH, IDLE, MATIC tokens not found
        context->decimals = DEFAULT_DECIMAL;
        handle_ticker_token(msg, context);
        handle_ticker_super_token(msg, context);
    } else if (context->selectorIndex == UPGRADE) {
        handle_upgrade_token(msg, context);
    } else {
        strlcpy(context->ticker_received, "???", sizeof(context->ticker_received));
        strlcpy(context->ticker_sent, "???", sizeof(context->ticker_sent));
        msg->additionalScreens++;
    }

    msg->result = ETH_PLUGIN_RESULT_OK;
}
