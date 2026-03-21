<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Coupon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CouponController extends Controller
{
    /**
     * 優惠券列表（super_admin 全店，store_manager 僅所屬店家）
     */
    public function index(Request $request): JsonResponse
    {
        $admin = $request->user();
        $query = Coupon::with('store');

        if ($admin->isStoreManager() && $admin->store_id) {
            $query->where(function ($q) use ($admin) {
                $q->where('store_id', $admin->store_id)
                    ->orWhereNull('store_id');
            });
        }

        $coupons = $query->orderBy('created_at', 'desc')->get();

        return response()->json(['coupons' => $coupons]);
    }

    /**
     * 新增優惠券
     */
    public function store(Request $request): JsonResponse
    {
        $admin = $request->user();
        $validated = $request->validate([
            'code' => ['required', 'string', 'max:50', 'unique:coupons,code'],
            'name' => ['nullable', 'string', 'max:255'],
            'interest_discount_percent' => ['required', 'numeric', 'min:0', 'max:100'],
            'store_id' => ['nullable', 'integer', 'exists:stores,id'],
            'valid_from' => ['nullable', 'date'],
            'valid_until' => ['nullable', 'date', 'after_or_equal:valid_from'],
            'usage_limit' => ['nullable', 'integer', 'min:1'],
            'is_active' => ['sometimes', 'boolean'],
        ]);

        if ($admin->isStoreManager()) {
            if (isset($validated['store_id']) && (int) $validated['store_id'] !== (int) $admin->store_id) {
                return response()->json(['message' => '店長僅可建立所屬店家或全店通用的優惠券'], 403);
            }
            $validated['store_id'] = $validated['store_id'] ?? $admin->store_id;
        }

        $validated['is_active'] = $request->boolean('is_active', true);

        $coupon = Coupon::create($validated);

        return response()->json([
            'message' => '優惠券已新增',
            'coupon' => $coupon->load('store'),
        ], 201);
    }

    /**
     * 更新優惠券
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $admin = $request->user();
        $coupon = Coupon::findOrFail($id);

        if ($admin->isStoreManager()) {
            if ($coupon->store_id !== null && (int) $coupon->store_id !== (int) $admin->store_id) {
                abort(403);
            }
        }

        $validated = $request->validate([
            'code' => ['sometimes', 'string', 'max:50', 'unique:coupons,code,' . $id],
            'name' => ['nullable', 'string', 'max:255'],
            'interest_discount_percent' => ['sometimes', 'numeric', 'min:0', 'max:100'],
            'store_id' => ['nullable', 'integer', 'exists:stores,id'],
            'valid_from' => ['nullable', 'date'],
            'valid_until' => ['nullable', 'date'],
            'usage_limit' => ['nullable', 'integer', 'min:0'],
            'is_active' => ['sometimes', 'boolean'],
        ]);

        if ($admin->isStoreManager() && isset($validated['store_id'])) {
            if ((int) $validated['store_id'] !== (int) $admin->store_id) {
                $validated['store_id'] = $admin->store_id;
            }
        }

        $coupon->update($validated);

        return response()->json([
            'message' => '已更新',
            'coupon' => $coupon->fresh()->load('store'),
        ]);
    }

    /**
     * 刪除優惠券
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $admin = $request->user();
        $coupon = Coupon::findOrFail($id);

        if ($admin->isStoreManager()) {
            if ($coupon->store_id !== null && (int) $coupon->store_id !== (int) $admin->store_id) {
                abort(403);
            }
        }

        $coupon->delete();

        return response()->json(['message' => '已刪除']);
    }
}
