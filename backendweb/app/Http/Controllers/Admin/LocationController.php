<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\LocationPoint;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Messaging\AndroidConfig;
use Kreait\Firebase\Messaging\ApnsConfig;
use Kreait\Firebase\Messaging\CloudMessage;

class LocationController extends Controller
{
    /**
     * 取得會員定位紀錄（供管理後台地圖顯示）
     * 依權限隔離：store_manager 僅能查看同店會員
     */
    public function index(Request $request, int $id): JsonResponse
    {
        $admin = $request->user();
        $member = User::where('role', 'member')->findOrFail($id);

        if ($admin->isStoreManager() && $member->store_id !== $admin->store_id) {
            abort(403);
        }

        $since = $request->query('since');
        $limit = min((int) $request->query('limit', 500), 1000);

        $query = LocationPoint::where('user_id', $id)
            ->orderBy('created_at', 'asc');

        if ($since) {
            $query->whereDate('created_at', '>=', $since);
        }

        $points = $query->limit($limit)->get();

        return response()->json([
            'member' => [
                'id' => $member->id,
                'name' => $member->name,
                'phone' => $member->phone,
            ],
            'points' => $points,
        ]);
    }

    /**
     * 後台對指定會員發出「立即定位」請求
     * Flutter App 輪詢時會收到此請求並立即回傳 GPS
     */
    public function requestNow(Request $request, int $id): JsonResponse
    {
        $admin = $request->user();
        $member = User::where('role', 'member')->findOrFail($id);

        if ($admin->isStoreManager() && $member->store_id !== $admin->store_id) {
            abort(403);
        }

        $member->update(['location_requested_at' => now()]);

        // FCM 靜默推播，讓手機立即回傳定位（不需等 30 秒 polling）
        if ($member->fcm_token) {
            try {
                $message = CloudMessage::new()
                    ->withToken($member->fcm_token)
                    ->withData(['type' => 'location_request'])
                    ->withAndroidConfig(
                        AndroidConfig::new()->withHighMessagePriority()
                    )
                    ->withApnsConfig(
                        ApnsConfig::fromArray([
                            'headers' => [
                                'apns-priority' => '10',
                                'apns-push-type' => 'background',
                            ],
                            'payload' => [
                                'aps' => ['content-available' => 1],
                            ],
                        ])
                    );
                app(Messaging::class)->send($message);
            } catch (\Throwable) {
                // FCM 失敗仍依賴原有 polling 機制作為備援
            }
        }

        return response()->json([
            'status' => 'success',
            'message' => '定位請求已發出，等待 App 回傳位置',
        ]);
    }

    /**
     * 取得會員最新一筆定位（供後台即時顯示）
     */
    public function latest(Request $request, int $id): JsonResponse
    {
        $admin = $request->user();
        $member = User::where('role', 'member')->findOrFail($id);

        if ($admin->isStoreManager() && $member->store_id !== $admin->store_id) {
            abort(403);
        }

        $point = LocationPoint::where('user_id', $id)
            ->orderByDesc('created_at')
            ->first();

        return response()->json([
            'point' => $point,
        ]);
    }
}
