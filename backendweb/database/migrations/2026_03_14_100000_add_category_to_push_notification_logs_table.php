<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('push_notification_logs', function (Blueprint $table) {
            $table->string('category', 50)->default('announcement')->after('body');
            $table->timestamp('read_at')->nullable()->after('target_type');
        });
    }

    public function down(): void
    {
        Schema::table('push_notification_logs', function (Blueprint $table) {
            $table->dropColumn(['category', 'read_at']);
        });
    }
};
