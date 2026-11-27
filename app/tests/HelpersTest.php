<?php

use PHPUnit\Framework\TestCase;

require_once __DIR__ . '/../src/helpers.php';

final class HelpersTest extends TestCase
{
    public function testConfigIsCompleteWhenAllValuesArePresent(): void
    {
        $this->assertTrue(db_config_is_complete(['host', 'db', 'user', 'pass']));
    }

    public function testConfigIsIncompleteWhenAValueIsMissing(): void
    {
        $this->assertFalse(db_config_is_complete(['host', false, 'user', 'pass']));
    }
}
