<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Coupon extends Model
{
    protected $fillable = [
        'code',
        'name',
        'interest_discount_percent',
        'store_id',
        'valid_from',
        'valid_until',
        'usage_limit',
        'used_count',
        'is_active',
    ];

    protected $casts = [
        'valid_from' => 'datetime',
        'valid_until' => 'datetime',
        'is_active' => 'boolean',
    ];

    public function store()
    {
        return $this->belongsTo(Store::class);
    }

    public function users()
    {
        return $this->hasMany(User::class, 'coupon_id');
    }

    /**
     * 檢查優惠券是否可用（有效、未達上限）
     */
    public function isUsable(?int $storeId = null): bool
    {
        if (! $this->is_active) {
            return false;
        }
        if ($this->usage_limit !== null && $this->used_count >= $this->usage_limit) {
            return false;
        }
        $now = now();
        if ($this->valid_from !== null && $now->lt($this->valid_from)) {
            return false;
        }
        if ($this->valid_until !== null && $now->gt($this->valid_until)) {
            return false;
        }
        if ($this->store_id !== null && $storeId !== null && (int) $this->store_id !== (int) $storeId) {
            return false;
        }

        return true;
    }
}
