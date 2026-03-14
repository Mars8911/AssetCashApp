<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PushNotificationLog;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    /**
     * 取得登入會員的推播通知列表（需 Bearer Token 認證）
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        if (! $user || $user->role !== 'member') {
            return response()->json(['message' => '未授權'], 401);
        }

        $notifications = PushNotificationLog::where('user_id', $user->id)
            ->orderByDesc('created_at')
            ->limit(100)
            ->get();

        $items = $notifications->map(fn ($n) => [
            'id' => $n->id,
            'subject' => $n->title,
            'description' => $n->body,
            'valid_period' => $n->created_at->format('Y/m/d'),
            'category' => $n->category,
            'is_read' => $n->read_at !== null,
            'created_at' => $n->created_at->toIso8601String(),
        ]);

        return response()->json([
            'status' => 'success',
            'data' => [
                'notifications' => $items,
            ],
        ]);
    }

    /**
     * 標記通知為已讀
     */
    public function markAsRead(Request $request, int $id): JsonResponse
    {
        $user = $request->user();
        if (! $user || $user->role !== 'member') {
            return response()->json(['message' => '未授權'], 401);
        }

        $notification = PushNotificationLog::where('user_id', $user->id)
            ->where('id', $id)
            ->firstOrFail();

        $notification->update(['read_at' => now()]);

        return response()->json([
            'status' => 'success',
            'message' => '已標記為已讀',
        ]);
    }
}
