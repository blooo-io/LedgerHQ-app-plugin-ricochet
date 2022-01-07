#include "ricochet_plugin.h"

// function to compare array elements
char compare_array(uint8_t a[], uint8_t b[], int size) {
    int i;
    for (i = 0; i < size; i++) {
        if (a[i] != b[i]) return 1;
    }
    return 0;
}

// // to rework
// void handle_tokens_downgrade(ethPluginFinalize_t *msg, context_t *context) {
//     int index;

//     for (index = 0; index < 10; index++) {
//         if (compare_array(super_token_collection[index].super_token_address,
//                           context->contract_address_sent,
//                           ADDRESS_LENGTH) == 0) {
//             msg->tokenLookup1 = super_token_collection[index].token_address;
//         }
//     }
// }

// void handle_tokens_upgrade(ethPluginFinalize_t *msg, context_t *context) {
//     int index;

//     for (index = 0; index < SUPER_TOKEN_COLLECTION; index++) {
//         if (compare_array(super_token_collection[index].super_token_address,
//                           context->contract_address_received,
//                           ADDRESS_LENGTH) == 0) {
//             memset(context->contract_address_sent, 0, sizeof(context->contract_address_sent));
//             memcpy(context->contract_address_sent,
//                    super_token_collection[index].token_address,
//                    sizeof(context->contract_address_sent));
//             break;
//         }
//     }
// }

void handle_finalize(void *parameters) {
    ethPluginFinalize_t *msg = (ethPluginFinalize_t *) parameters;
    context_t *context = (context_t *) msg->pluginContext;

    if (context->valid) {
        msg->numScreens = 2;

        if (!ADDRESS_IS_NETWORK_TOKEN(context->contract_address_received)) {
            msg->tokenLookup1 = context->contract_address_received;
            PRINTF("Setting address sent to: %.*H\n",
                   ADDRESS_LENGTH,
                   context->contract_address_received);
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