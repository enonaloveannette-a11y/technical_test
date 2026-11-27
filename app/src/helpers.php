<?php

// Returns true only when none of the database settings is missing.
function db_config_is_complete(array $values): bool
{
    return !in_array(false, $values, true);
}
