#include "poap_plugin.h"

void handle_finalize(void *parameters) {
    ethPluginFinalize_t *msg = (ethPluginFinalize_t *) parameters;
    context_t *context = (context_t *) msg->pluginContext;

    msg->uiType = ETH_UI_TYPE_GENERIC;

    // 2 additional screens are required to display the `token and `beneficiary` fields
    msg->numScreens = 2;
    msg->result = ETH_PLUGIN_RESULT_OK;

    if (context->selectorIndex == SAFE_TRANSFER) {
        // An additional screen is required to display the `token` field for safe_transfer method.
        msg->numScreens += 1;
    }
}
