#include "ricochet_plugin.h"

void handle_query_contract_id(void *parameters) {
    ethQueryContractID_t *msg = (ethQueryContractID_t *) parameters;
    const context_t *context = (context_t *) msg->pluginContext;

    print_bytes(context->contract_address_received, sizeof(context->contract_address_received));
    print_bytes(msg->pluginSharedRO->txContent->value.value,
                sizeof(msg->pluginSharedRO->txContent->value.value));

    strlcpy(msg->name, PLUGIN_NAME, msg->nameLength);
    switch (context->selectorIndex) {
        case DOWNGRADE:
            strlcpy(msg->version, "Downgrade", msg->versionLength);
            break;
        case DOWNGRADE_TO_ETH:
            strlcpy(msg->version, "DowngradeToETH", msg->versionLength);
            break;
        case DISTRIBUTE:
            strlcpy(msg->version, "Distribute", msg->versionLength);
            break;
        default:
            PRINTF("Selector index: %d not supported\n", context->selectorIndex);
            msg->result = ETH_PLUGIN_RESULT_ERROR;
            return;
    }
    msg->result = ETH_PLUGIN_RESULT_OK;
}