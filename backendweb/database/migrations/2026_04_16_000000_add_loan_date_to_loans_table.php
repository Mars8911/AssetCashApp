<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('loans', function (Blueprint $table) {
            // 貸款起始日（借貸資訊表左上角日期）
            $table->date('loan_date')->nullable()->after('store_id');
            // 前扣期數（前扣 N 個月）
            $table->unsignedTinyInteger('prepaid_months')->default(0)->after('interest_collection');
            // 前扣總金額（月還款 × prepaid_months）
            $table->decimal('prepaid_amount', 15, 2)->nullable()->after('prepaid_months');
        });
    }

    public function down(): void
    {
        Schema::table('loans', function (Blueprint $table) {
            $table->dropColumn(['loan_date', 'prepaid_months', 'prepaid_amount']);
        });
    }
};
