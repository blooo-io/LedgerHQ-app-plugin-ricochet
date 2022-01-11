#include "ricochet_plugin.h"

// function to compare array elements
char compare_array(uint8_t a[], uint8_t b[], int size) {
    int i;
    for (i = 0; i < size; i++) {
        if (a[i] != b[i]) return 1;
    }
    return 0;
}

void handle_finalize(void *parameters) {
    ethPluginFinalize_t *msg = (ethPluginFinalize_t *) parameters;
    context_t *context = (context_t *) msg->pluginContext;

    if (context->valid) {
        msg->numScreens = 2;

        if (context->selectorIndex == DISTRIBUTE) {
            msg->numScreens--;
        }

        if (!ADDRESS_IS_NETWORK_TOKEN(context->contract_address_received) &&
            (context->selectorIndex == DOWNGRADE || context->selectorIndex == DOWNGRADE_TO_ETH)) {
            msg->tokenLookup1 = context->contract_address_received;
            PRINTF("Setting address sent to: %.*H\n",
                   ADDRESS_LENGTH,
                   context->contract_address_received);
        } else if (!ADDRESS_IS_NETWORK_TOKEN(context->contract_address_sent) &&
                   context->selectorIndex == UPGRADE) {
            msg->tokenLookup1 = context->contract_address_sent;
            PRINTF("Setting address sent to: %.*H\n",
                   ADDRESS_LENGTH,
                   context->contract_address_sent);
        } else {
            msg->tokenLookup1 = NULL;
        }

        msg->uiType = ETH_UI_TYPE_GENERIC;
        msg->result = ETH_PLUGIN_RESULT_OK;
    } else {
        PRINTF("Context not valid\n");
        msg->result = ETH_PLUGIN_RESULT_FALLBACK;
    }
}