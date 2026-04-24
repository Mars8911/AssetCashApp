<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\LocationPoint;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LocationController extends Controller
{
    /**
     * Flutter App 輪詢：檢查後台是否有「立即定位」請求
     * 有請求時回傳 pending=true，App 收到後立即抓 GPS 上傳，並清除請求
     */
    public function checkRequest(Request $request): JsonResponse
    {
        $user = $request->user();

        if (! $user->location_requested_at) {
            return response()->json(['pending' => false]);
        }

        // 超過 5 分鐘的請求自動失效（避免舊請求一直觸發）
        if ($user->location_requested_at->diffInMinutes(now()) > 5) {
            $user->update(['location_requested_at' => null]);
            return response()->json(['pending' => false]);
        }

        // 清除請求（避免重複觸發）
        $user->update(['location_requested_at' => null]);

        return response()->json(['pending' => true]);
    }

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
