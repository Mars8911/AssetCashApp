<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Store extends Model
{
    // 允許批量寫入的欄位
    protected $fillable = ['name', 'branch_name'];
    // 定義關聯：一家店有很多貸款案
    public function loans() {
        return $this->hasMany(Loan::class);
    }
}
