<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\PushNotificationLog;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;

class PushNotificationController extends Controller
{
    public function __construct(private readonly Messaging $messaging) {}

    /**
     * 發送推播訊息（群體或指定會員）
     */
    public function send(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'title' => ['required', 'string', 'max:100'],
            'body' => ['required', 'string', 'max:500'],
            'category' => ['required', 'string', 'in:payment,success,announcement,activity,membership,other'],
            'target_type' => ['required', 'in:all,single'],
            'user_id' => ['required_if:target_type,single', 'nullable', 'integer', 'exists:users,id'],
        ]);

        $admin = $request->user();
        if ($admin->isShareholder()) {
            return response()->json(['message' => '股東管理者無權限發送推播'], 403);
        }

        $query = User::where('role', 'member')->whereNotNull('fcm_token');

        if ($admin->isStoreManager()) {
            if (! $admin->store_id) {
                return response()->json(['message' => '店家管理者尚未綁定店家'], 400);
            }
            $query->where('store_id', $admin->store_id);
        }

        if ($validated['target_type'] === 'single') {
            $member = User::findOrFail($validated['user_id']);
            if ($admin->isStoreManager() && $member->store_id !== $admin->store_id) {
                abort(403);
            }
            $targets = collect([$member]);
        } else {
            $targets = $query->get();
        }

        if ($targets->isEmpty()) {
            return response()->json(['message' => '無符合條件的發送對象（或對象皆未開啟推播）'], 400);
        }

        DB::beginTransaction();
        try {
            foreach ($targets as $user) {
                PushNotificationLog::create([
                    'admin_id' => $admin->id,
                    'user_id' => $user->id,
                    'title' => $validated['title'],
                    'body' => $validated['body'],
                    'category' => $validated['category'],
                    'target_type' => $validated['target_type'],
                ]);

                if ($user->fcm_token) {
                    $message = CloudMessage::new()
                        ->withToken($user->fcm_token)
                        ->withNotification(Notification::create($validated['title'], $validated['body']))
                        ->withData(['category' => $validated['category']]);
                    $this->messaging->send($message);
                }
            }
            DB::commit();
        } catch (\Throwable $e) {
            DB::rollBack();
            return response()->json(['message' => '發送失敗：' . $e->getMessage()], 500);
        }

        $count = $targets->count();
        return response()->json([
            'message' => "推播已發送，共 {$count} 位會員",
            'sent_count' => $count,
        ]);
    }

    /**
     * 後台發送「立即定位」靜默推播給指定會員
     */
    public function requestLocation(Request $request): JsonResponse
    {
        $request->validate([
            'user_id' => ['required', 'integer', 'exists:users,id'],
        ]);

        $user = User::findOrFail($request->user_id);

        if (! $user->fcm_token) {
            return response()->json(['message' => '該會員尚未開啟推播通知'], 400);
        }

        try {
            $message = CloudMessage::new()
                ->withToken($user->fcm_token)
                ->withData(['type' => 'location_request']);
            $this->messaging->send($message);

            $user->update(['location_requested_at' => now()]);
        } catch (\Throwable $e) {
            return response()->json(['message' => '發送失敗：' . $e->getMessage()], 500);
        }

        return response()->json(['message' => '立即定位請求已發送']);
    }
}
