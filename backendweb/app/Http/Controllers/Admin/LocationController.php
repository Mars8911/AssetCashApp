<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\LocationPoint;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

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

        $since = $request->query('since'); // 可選：YYYY-MM-DD 篩選起始日
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
}
