<?php
/**
 * Simple script which clears the complete apc cache
 * if apc is available
 */
if (function_exists('apc_clear_cache')) {
    apc_clear_cache('user');
    apc_clear_cache('opcode');
    apc_clear_cache();
}
clearstatcache(true);

exit(0);