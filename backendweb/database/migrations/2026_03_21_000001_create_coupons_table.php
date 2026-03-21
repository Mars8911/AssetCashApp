<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('coupons', function (Blueprint $table) {
            $table->id();
            $table->string('code', 50)->unique()->comment('優惠碼');
            $table->string('name')->nullable()->comment('優惠券名稱');
            $table->decimal('interest_discount_percent', 5, 2)->default(0)->comment('利息折抵百分比（如 2 表示折抵 2%）');
            $table->foreignId('store_id')->nullable()->constrained()->nullOnDelete()->comment('限定店家，null 表示全店通用');
            $table->timestamp('valid_from')->nullable()->comment('有效起始日');
            $table->timestamp('valid_until')->nullable()->comment('有效截止日');
            $table->unsignedInteger('usage_limit')->nullable()->comment('總使用次數上限，null 表示無限制');
            $table->unsignedInteger('used_count')->default(0)->comment('已使用次數');
            $table->boolean('is_active')->default(true)->comment('是否啟用');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('coupons');
    }
};
