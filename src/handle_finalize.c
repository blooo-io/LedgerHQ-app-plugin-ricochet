#include "ricochet_plugin.h"

void handle_finalize(void *parameters) {
    ethPluginFinalize_t *msg = (ethPluginFinalize_t *) parameters;
    context_t *context = (context_t *) msg->pluginContext;

    if (context->valid) {
        msg->numScreens = 2;

        switch (context->selectorIndex) {
            case DOWNGRADE:
            case DOWNGRADE_TO_ETH:
                if (!ADDRESS_IS_NETWORK_TOKEN(context->contract_address_received)) {
                    msg->tokenLookup1 = context->contract_address_received;
                    PRINTF("Setting address received to: %.*H\n",
                           ADDRESS_LENGTH,
                           context->contract_address_received);
                } else {
                    msg->tokenLookup1 = NULL;
                }
                break;
            case UPGRADE:
            case UPGRADE_TO_ETH:
                if (!ADDRESS_IS_NETWORK_TOKEN(context->contract_address_sent)) {
                    msg->tokenLookup1 = context->contract_address_sent;
                    PRINTF("Setting address sent to: %.*H\n",
                           ADDRESS_LENGTH,
                           context->contract_address_sent);
                } else {
                    msg->tokenLookup1 = NULL;
                }
                break;
            case CALL_AGREEMENT:
                if (!ADDRESS_IS_NETWORK_TOKEN(context->contract_address_sent)) {
                    msg->tokenLookup1 = context->contract_address_sent;
                    PRINTF("Setting address sent to: %.*H\n",
                           ADDRESS_LENGTH,
                           context->contract_address_sent);
                } else {
                    msg->tokenLookup1 = NULL;
                }
                break;
            default:
                PRINTF("Missing selectorIndex: %d\n", context->selectorIndex);
                msg->result = ETH_PLUGIN_RESULT_ERROR;
                return;
        }

        msg->uiType = ETH_UI_TYPE_GENERIC;
        msg->result = ETH_PLUGIN_RESULT_OK;
    } else {
        PRINTF("Context not valid\n");
        msg->result = ETH_PLUGIN_RESULT_FALLBACK;
    }
}