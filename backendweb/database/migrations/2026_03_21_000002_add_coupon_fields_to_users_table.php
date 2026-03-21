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
        Schema::table('users', function (Blueprint $table) {
            $table->decimal('interest_discount_percent', 5, 2)->default(0)->after('points')
                ->comment('註冊優惠券折抵之利息百分比');
            $table->foreignId('coupon_id')->nullable()->after('interest_discount_percent')
                ->constrained()->nullOnDelete()->comment('註冊時使用的優惠券');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropForeign(['coupon_id']);
            $table->dropColumn(['interest_discount_percent', 'coupon_id']);
        });
    }
};
