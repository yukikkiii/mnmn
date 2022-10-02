<?php

namespace App\Enums;

use BenSampo\Enum\Enum;

/**
 * @method static static DRAFT()
 * @method static static SENT()
 */
final class MessageStatus extends Enum
{
    const DRAFT = 1;
    const UNOPENED = 2;
    const SENT = 3;
}
