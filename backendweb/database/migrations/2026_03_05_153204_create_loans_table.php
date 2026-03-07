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
        Schema::create('loans', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained(); // 客戶
            $table->foreignId('store_id')->constrained(); // 所屬店家
            $table->decimal('loan_amount', 15, 2);
            $table->decimal('remaining_amount', 15, 2);
            $table->float('interest_rate');
            $table->enum('repayment_type', ['interest_only', 'amortization']);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('loans');
    }
};
