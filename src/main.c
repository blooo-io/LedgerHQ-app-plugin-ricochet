/*******************************************************************************
 *   Ethereum 2 Deposit Application
 *   (c) 2020 Ledger
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ********************************************************************************/

#include <stdbool.h>
#include <stdint.h>
#include <string.h>

#include "os.h"
#include "cx.h"

#include "ricochet_plugin.h"

// Function: upgrade(uint256 amount)
// Selector: 0x45977d03
static const uint8_t UPGRADE_SELECTOR[SELECTOR_SIZE] = {0x45, 0x97, 0x7d, 0x03};

// Function: downgrade(uint256 amount)
// Selector: 0x11bcc81e
static const uint8_t DOWNGRADE_SELECTOR[SELECTOR_SIZE] = {0x11, 0xbc, 0xc8, 0x1e};

// Array of all the different ricochet selectors.
const uint8_t *const RICOCHET_SELECTORS[NUM_SELECTORS] = {UPGRADE_SELECTOR, DOWNGRADE_SELECTOR};

// Paraswap uses `0xeeeee` as a dummy address to represent ETH.
const uint8_t RICOCHET_ETH_ADDRESS[ADDRESS_LENGTH] = {0xee, 0xee, 0xee, 0xee, 0xee, 0xee, 0xee,
                                                      0xee, 0xee, 0xee, 0xee, 0xee, 0xee, 0xee,
                                                      0xee, 0xee, 0xee, 0xee, 0xee, 0xee};

// const super_token_ticker super_token_collection[10] = {
//     {{0x27, 0x91, 0xbc, 0xa1, 0xf2, 0xde, 0x46, 0x61, 0xed, 0x88,
//       0xa3, 0x0c, 0x99, 0xa7, 0xa9, 0x44, 0x9a, 0xa8, 0x41, 0x74},
//      {0x13, 0x05, 0xf6, 0xb6, 0xdf, 0x9d, 0xc4, 0x71, 0x59, 0xd1,
//       0x2e, 0xb7, 0xac, 0x28, 0x04, 0xd4, 0xa3, 0x31, 0x73, 0xc2},
//      "DAIx"}};

const super_token_ticker super_token_collection[SUPER_TOKEN_COLLECTION] = {
    {{0x8f, 0x3c, 0xf7, 0xad, 0x23, 0xcd, 0x3c, 0xad, 0xbd, 0x97,
      0x35, 0xaf, 0xf9, 0x58, 0x02, 0x32, 0x39, 0xc6, 0xa0, 0x63},
     {0x13, 0x05, 0xf6, 0xb6, 0xdf, 0x9d, 0xc4, 0x71, 0x59, 0xd1,
      0x2e, 0xb7, 0xac, 0x28, 0x04, 0xd4, 0xa3, 0x31, 0x73, 0xc2},
     "DAIx"}};

const uint8_t DAI_TEST[ADDRESS_LENGTH] = {0x8f, 0x3c, 0xf7, 0xad, 0x23, 0xcd, 0x3c,
                                          0xad, 0xbd, 0x97, 0x35, 0xaf, 0xf9, 0x58,
                                          0x02, 0x32, 0x39, 0xc6, 0xa0, 0x63};

// Function to dispatch calls from the ethereum app.
void dispatch_plugin_calls(int message, void *parameters) {
    switch (message) {
        case ETH_PLUGIN_INIT_CONTRACT:
            handle_init_contract(parameters);
            break;
        case ETH_PLUGIN_PROVIDE_PARAMETER:
            handle_provide_parameter(parameters);
            break;
        case ETH_PLUGIN_PROVIDE_TOKEN:
            handle_provide_token(parameters);
            break;
        case ETH_PLUGIN_FINALIZE:
            handle_finalize(parameters);
            break;
        case ETH_PLUGIN_QUERY_CONTRACT_ID:
            handle_query_contract_id(parameters);
            break;
        case ETH_PLUGIN_QUERY_CONTRACT_UI:
            handle_query_contract_ui(parameters);
            break;
        default:
            PRINTF("Unhandled message %d\n", message);
            break;
    }
}

// Calls the ethereum app.
void call_app_ethereum() {
    unsigned int libcall_params[3];
    libcall_params[0] = (unsigned int) "Ethereum";
    libcall_params[1] = 0x100;
    libcall_params[2] = RUN_APPLICATION;
    os_lib_call((unsigned int *) &libcall_params);
}

// Weird low-level black magic. No need to edit this.
__attribute__((section(".boot"))) int main(int arg0) {
    // Exit critical section
    __asm volatile("cpsie i");

    // Ensure exception will work as planned
    os_boot();

    // Try catch block. Please read the docs for more information on how to use those!
    BEGIN_TRY {
        TRY {
            // Low-level black magic.
            check_api_level(CX_COMPAT_APILEVEL);

            // Check if we are called from the dashboard.
            if (!arg0) {
                // Called from dashboard, launch Ethereum app
                call_app_ethereum();
                return 0;
            } else {
                // Not called from dashboard: called from the ethereum app!
                unsigned int *args = (unsigned int *) arg0;

                // If `ETH_PLUGIN_CHECK_PRESENCE` is set, this means the caller is just trying to
                // know whether this app exists or not. We can skip `dispatch_plugin_calls`.
                if (args[0] != ETH_PLUGIN_CHECK_PRESENCE) {
                    dispatch_plugin_calls(args[0], (void *) args[1]);
                }

                // Call `os_lib_end`, go back to the ethereum app.
                os_lib_end();
            }
        }
        FINALLY {
        }
    }
    END_TRY;

    // Will not get reached.
    return 0;
}
