<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Loan extends Model
{
    protected $fillable = [
       'user_id',
        'store_id',
        'loan_amount',
        'remaining_amount',
        'interest_rate',
        'repayment_type'
    ];

    // 每一筆貸款都屬於一個店家
    public function store() {
        return $this->belongsTo(Store::class);
    }
}
