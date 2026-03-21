<?php

namespace App\Services;

use App\Models\Coupon;
use App\Models\User;

class CouponService
{
    /**
     * 驗證優惠碼並取得可用優惠券（供註冊使用）
     *
     * @return array{valid: bool, coupon: Coupon|null, message: string}
     */
    public function validateForRegistration(string $code, int $storeId): array
    {
        $coupon = Coupon::where('code', $code)->first();

        if (! $coupon) {
            return [
                'valid' => false,
                'coupon' => null,
                'message' => '優惠碼不存在',
            ];
        }

        if (! $coupon->isUsable($storeId)) {
            $message = '優惠碼無法使用';
            if (! $coupon->is_active) {
                $message = '優惠碼已停用';
            } elseif ($coupon->usage_limit !== null && $coupon->used_count >= $coupon->usage_limit) {
                $message = '優惠碼已達使用上限';
            } elseif ($coupon->valid_until !== null && now()->gt($coupon->valid_until)) {
                $message = '優惠碼已過期';
            } elseif ($coupon->store_id !== null && (int) $coupon->store_id !== $storeId) {
                $message = '此優惠碼不適用於所選店家';
            }

            return [
                'valid' => false,
                'coupon' => null,
                'message' => $message,
            ];
        }

        return [
            'valid' => true,
            'coupon' => $coupon,
            'message' => "成功！享有利息 {$coupon->interest_discount_percent}% 折抵",
        ];
    }

    /**
     * 套用優惠券至新註冊會員
     */
    public function applyToUser(User $user, Coupon $coupon): void
    {
        $user->update([
            'interest_discount_percent' => $coupon->interest_discount_percent,
            'coupon_id' => $coupon->id,
        ]);
        $coupon->increment('used_count');
    }
}
