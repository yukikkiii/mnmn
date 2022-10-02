<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Storage;

class ImageUploadController extends Controller
{
    /**
     * Handle the incoming request.
     */
    public function __invoke(Request $request)
    {
        $request->validate([
            'image' => 'required',
        ]);

        $path = $request->file('image')->store('images', 'public');
        $path = '/storage/' . $path;

        return [
            'success' => true,
            'path' => $path,
        ];
    }
}
