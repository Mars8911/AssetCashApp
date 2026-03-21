<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\LocationPoint;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LocationController extends Controller
{
    /**
     * 會員上傳定位點（Flutter APP 背景服務呼叫）
     * 需 Bearer Token 認證，僅能上傳自己的定位
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'accuracy' => ['nullable', 'numeric', 'min:0'],
            'altitude' => ['nullable', 'numeric'],
            'speed' => ['nullable', 'numeric', 'min:0'],
        ]);

        $lat = $request->input('latitude') ?? $request->input('lat');
        $lng = $request->input('longitude') ?? $request->input('lng');

        if (! is_numeric($lat) || (float) $lat < -90 || (float) $lat > 90) {
            return response()->json(['message' => 'latitude 或 lat 必須為 -90~90'], 422);
        }
        if (! is_numeric($lng) || (float) $lng < -180 || (float) $lng > 180) {
            return response()->json(['message' => 'longitude 或 lng 必須為 -180~180'], 422);
        }

        $point = LocationPoint::create([
            'user_id' => $request->user()->id,
            'latitude' => (float) $lat,
            'longitude' => (float) $lng,
            'accuracy' => $request->input('accuracy'),
            'altitude' => $request->input('altitude'),
            'speed' => $request->input('speed'),
        ]);

        return response()->json(['message' => 'ok', 'id' => $point->id], 201);
    }
}
