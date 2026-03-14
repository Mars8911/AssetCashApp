<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Admin\AuthController;
use App\Http\Controllers\Admin\ApiController as AdminApiController;
use App\Http\Controllers\Admin\MemberController;
use App\Http\Controllers\Admin\LoanController;
use App\Http\Controllers\Admin\LoanRepaymentController;
use App\Http\Controllers\Admin\PushNotificationController;
use App\Http\Controllers\Admin\AdminController;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/api/dashboard', [DashboardController::class, 'index']);

// 管理後台 API（供 Vue 使用，Session 認證）
Route::prefix('api/admin')->middleware(['web', 'auth', 'admin'])->group(function () {
    Route::get('user', [AdminApiController::class, 'user']);
    Route::get('dashboard', [AdminApiController::class, 'dashboard']);
    Route::get('members', [MemberController::class, 'index']);
    Route::get('members/{id}', [MemberController::class, 'show']);
    Route::put('members/{id}', [MemberController::class, 'update']);
    Route::post('members/{id}/loans', [LoanController::class, 'store']);
    Route::put('loans/{id}', [LoanController::class, 'update']);
    Route::delete('loans/{id}', [LoanController::class, 'destroy']);
    Route::get('loans/{id}/repayments', [LoanRepaymentController::class, 'index']);
    Route::post('loans/{id}/repayments', [LoanRepaymentController::class, 'store']);
    Route::delete('repayments/{id}', [LoanRepaymentController::class, 'destroy']);
    Route::post('push-notifications/send', [PushNotificationController::class, 'send']);

    // 管理者管理（僅 super_admin 可存取）
    Route::middleware('super_admin')->group(function () {
        Route::get('admins', [AdminController::class, 'index']);
        Route::get('admins/stores/list', [AdminController::class, 'stores']);
        Route::post('admins', [AdminController::class, 'store']);
        Route::put('admins/{id}', [AdminController::class, 'update']);
        Route::delete('admins/{id}', [AdminController::class, 'destroy']);
    });
});

// 管理後台（Vue SPA）
Route::prefix('admin')->name('admin.')->group(function () {
    Route::post('login', [AuthController::class, 'login'])->name('login.submit');
    Route::post('logout', [AuthController::class, 'logout'])->name('logout');

    // Vue SPA 掛載點（所有 GET /admin/* 皆回傳同一 view，含 /admin/login）
    Route::get('/{path?}', function () {
        return view('admin.spa');
    })->where('path', '.*')->name('dashboard');
});
