<?php

namespace App\Http\Controllers;

use App\Helpers\Utils;
use App\Helpers\ValidationRules;
use App\Models\UserLocation;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Validator;

class UserLocationController extends Controller
{
    public function index(Request $request)
    {
        if ($request->routeIs('my.locations')) {
            $user = \Auth::user();
            $locations = UserLocation::where('user_id', $user->id)
                ->orderByDesc('id')
                ->where('updated_at', '>=', Carbon::now()->subDays(7))
                ->paginate(10);
            return array_merge(
                ['success' => true],
                Utils::paginatorToArray($locations),
            );
        }

        return [];
    }

    public function update(Request $request)
    {
        $user = $request->user();
        $input = $request->only('lat', 'long');
        // Warning: potential SQL injection without this validation
        $validator = Validator::make($input, ValidationRules::latLong());
        if ($validator->fails()) {
            return [
                'success' => false,
                'errors' => $validator->errors(),
            ];
        }

        $lat = $input['lat'];
        $long = $input['long'];
        $point = "POINT($long, $lat)";

        // 25m以内に登録済みの位置情報が存在する場合、更新する
        /** @var UserLocation|null */
        $location = UserLocation::whereRaw("st_distance_sphere(point, $point) <= 25")
            ->where('user_id', $user->id)
            ->orderByRaw("st_distance_sphere(point, $point)")
            ->first();
        if ($location) {
            $location->update([
                'updated_at' => Carbon::now(),
            ]);
        } else {
            UserLocation::create([
                'user_id' => $user->id,
                'point' => DB::raw($point),
            ]);
        }

        return [
            'success' => true,
        ];
    }
}
