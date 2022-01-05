#include "ricochet_plugin.h"

void handle_finalize(void *parameters) {
    ethPluginFinalize_t *msg = (ethPluginFinalize_t *) parameters;
    context_t *context = (context_t *) msg->pluginContext;

    // PRINTF("Setting address sent to2: %.*H\n", ADDRESS_LENGTH, context->contract_address_sent);

    // uint8_t *eth_amount = msg->pluginSharedRO->txContent->chainID.value;
    // PRINTF("Setting address sent to4: %d \n", eth_amount);
    PRINTF("Setting address sent to (finalize): %.*H \n\n",
           msg->pluginSharedRO->txContent->gasprice.value);
    PRINTF("Setting address sent to (finalize): %.*H \n\n",
           msg->pluginSharedRO->txContent->value.value);
    PRINTF("Setting address sent to (finalize): %.*H \n\n",
           msg->pluginSharedRO->txContent->nonce.value);
    PRINTF("Setting address sent to (finalize): %.*H \n\n",
           msg->pluginSharedRO->txContent->startgas.value);
    PRINTF("Setting address sent to (finalize): %.*H \n\n",
           msg->pluginSharedRO->txContent->chainID.value);

    PRINTF("Setting address sent to (finalize): %.*H \n\n",
           msg->pluginSharedRO->txContent->destination);

    PRINTF("Setting address sent to (finalize): %.*H \n\n",
           msg->pluginSharedRO->txContent->destinationLength);

    PRINTF("Setting address sent to (finalize): %.*H \n\n",
           msg->pluginSharedRO->txContent->vLength);
    PRINTF("Setting address sent to (finalize): %.*H \n\n",
           msg->pluginSharedRO->txContent->dataPresent);
    PRINTF("Setting address sent to (finalize): %.*H \n\n", msg->result);
    PRINTF("Setting address sent to (finalize): %.*H \n\n", msg->numScreens);
    PRINTF("What a lovely buffer:\n %.*H \n\n", ADDRESS_LENGTH, msg->address);

    if (!ADDRESS_IS_NETWORK_TOKEN(msg->address)) {
        // Address is not network token (0xeee...) so we will need to look up the token in the
        // CAL.
        msg->numScreens = 2;
        // msg->tokenLookup1 = context->contract_address_sent;
        msg->tokenLookup1 = msg->address;

        // msg->tokenLookup1 = msg->pluginSharedRO->txContent->value;
        // PRINTF("Setting address sent to2: %.*H\n", ADDRESS_LENGTH,
        // context->contract_address_sent);
        // PRINTF("Setting address sent to3: %d \n", msg->pluginSharedRO->txContent->to);

        // The user is not swapping ETH, so make sure there's no ETH being sent in this tx.
        if (!allzeroes(msg->pluginSharedRO->txContent->value.value,
                       msg->pluginSharedRO->txContent->value.length)) {
            PRINTF("ETH attached to tx when token being swapped is %.*H\n",
                   sizeof(msg->address),
                   msg->address);
            msg->result = ETH_PLUGIN_RESULT_ERROR;
        }
    } else {
        msg->tokenLookup1 = msg->address;  // ADDRESS_IS_NETWORK_TOKEN
    }

    // if (!ADDRESS_IS_NETWORK_TOKEN(context->contract_address_received)) {
    //     // Address is not network token (0xeee...) so we will need to look up the token in the
    //     // CAL.
    //     PRINTF("Setting address receiving to: %.*H\n",
    //            ADDRESS_LENGTH,
    //            context->contract_address_received);
    //     msg->tokenLookup2 = context->contract_address_received;
    // } else {
    //     msg->tokenLookup2 = NULL;
    // }

    msg->uiType = ETH_UI_TYPE_GENERIC;
    msg->result = ETH_PLUGIN_RESULT_OK;
}
