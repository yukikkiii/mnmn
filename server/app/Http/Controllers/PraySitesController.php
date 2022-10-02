<?php

namespace App\Http\Controllers;

use App\Models\PraySite;

class PraySitesController extends Controller
{
    /**
     * List all Pray sites.
     */
    public function index()
    {
        $items = PraySite::with('prefecture')
            ->get();
        return [
            'items' => $items,
        ];
    }
}
