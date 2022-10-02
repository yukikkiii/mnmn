<?php

namespace App\Helpers;

use Illuminate\Validation\Rules\Password;

class ValidationRules {
    public static function latLong($required = true): array
    {
        $validations = [
            'lat' => ['regex:/^[-]?(([0-8]?[0-9])\.(\d+))|(90(\.0+)?)$/'],
            'long' => ['regex:/^[-]?((((1[0-7][0-9])|([0-9]?[0-9]))\.(\d+))|180(\.0+)?)$/'],
        ];
        if ($required) {
            $validations['lat'][] = 'required';
            $validations['long'][] = 'required';
        }

        return $validations;
    }

    public static function password($withConfirmation = false): array
    {
        $rules = [
            'required',
            'string',
            Password::min(8)->mixedCase()->numbers(),
        ];
        if ($withConfirmation) {
            array_push($rules, 'confirmed');
        }
        return $rules;
    }
}
