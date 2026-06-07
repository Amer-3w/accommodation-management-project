<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\BookingController;
use App\Http\Controllers\FavoriteController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\ListingController;
use App\Http\Controllers\MessageController;
use App\Http\Controllers\PaymentController;
use App\Http\Controllers\SupportMessageController;
use App\Http\Controllers\PropertyImageController;
use App\Http\Controllers\UserWhatsappNumberController;
use App\Http\Controllers\ReviewController;
use Illuminate\Support\Facades\Route;

Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);
Route::post('/support-messages', [SupportMessageController::class, 'store']);
Route::post('/support/messages', [SupportMessageController::class, 'store']);

Route::get('/properties', [ListingController::class, 'index']);
Route::get('/properties/{listing}', [ListingController::class, 'show']);
Route::get('/listings', [ListingController::class, 'index']);
Route::get('/listings/{listing}', [ListingController::class, 'show']);

Route::middleware('auth:sanctum')->group(function (): void {
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::get('/me', [AuthController::class, 'me']);
    Route::get('/me/stats', [AuthController::class, 'stats']);
    Route::put('/auth/me', [AuthController::class, 'updateProfile']);
    Route::put('/me', [AuthController::class, 'updateProfile']);
    Route::post('/me/photo', [AuthController::class, 'uploadPhoto']);
    Route::post('/auth/logout', [AuthController::class, 'logout']);

    Route::get('/user-whatsapp-numbers', [UserWhatsappNumberController::class, 'index']);
    Route::post('/user-whatsapp-numbers', [UserWhatsappNumberController::class, 'store']);
    Route::put('/user-whatsapp-numbers/{userWhatsappNumber}', [UserWhatsappNumberController::class, 'update']);
    Route::delete('/user-whatsapp-numbers/{userWhatsappNumber}', [UserWhatsappNumberController::class, 'destroy']);
    Route::post('/me/whatsapp-numbers', [UserWhatsappNumberController::class, 'store']);
    Route::put('/me/whatsapp-numbers/{userWhatsappNumber}', [UserWhatsappNumberController::class, 'update']);
    Route::delete('/me/whatsapp-numbers/{userWhatsappNumber}', [UserWhatsappNumberController::class, 'destroy']);

    Route::get('/favorites', [FavoriteController::class, 'index']);
    Route::post('/favorites', [FavoriteController::class, 'store']);
    Route::delete('/favorites/{favorite}', [FavoriteController::class, 'destroy']);
    Route::post('/favorites/toggle', [FavoriteController::class, 'toggle']);

    Route::get('/support-messages', [SupportMessageController::class, 'index']);
    Route::get('/support-messages/{supportMessage}', [SupportMessageController::class, 'show']);
    Route::put('/support-messages/{supportMessage}', [SupportMessageController::class, 'update']);
    Route::delete('/support-messages/{supportMessage}', [SupportMessageController::class, 'destroy']);
    Route::get('/support/admin-contact', [SupportMessageController::class, 'adminContact']);

    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::post('/notifications/mark-all-read', [NotificationController::class, 'markAllRead']);

    Route::post('/properties', [ListingController::class, 'store']);
    Route::put('/properties/{listing}', [ListingController::class, 'update']);
    Route::delete('/properties/{listing}', [ListingController::class, 'destroy']);

    Route::post('/listings', [ListingController::class, 'store']);
    Route::put('/listings/{listing}', [ListingController::class, 'update']);
    Route::delete('/listings/{listing}', [ListingController::class, 'destroy']);

    Route::get('/properties/{listing}/images', [PropertyImageController::class, 'index']);
    Route::post('/properties/{listing}/images', [PropertyImageController::class, 'store']);
    Route::put('/property-images/{propertyImage}', [PropertyImageController::class, 'update']);
    Route::delete('/property-images/{propertyImage}', [PropertyImageController::class, 'destroy']);

    Route::get('/bookings', [BookingController::class, 'index']);
    Route::get('/bookings/{booking}', [BookingController::class, 'show']);
    Route::post('/bookings', [BookingController::class, 'store']);
    Route::put('/bookings/{booking}', [BookingController::class, 'update']);
    Route::delete('/bookings/{booking}', [BookingController::class, 'destroy']);
    Route::get('/booking', [BookingController::class, 'index']);
    Route::get('/booking/{booking}', [BookingController::class, 'show']);
    Route::post('/booking', [BookingController::class, 'store']);
    Route::put('/booking/{booking}', [BookingController::class, 'update']);
    Route::delete('/booking/{booking}', [BookingController::class, 'destroy']);
    Route::post('/booking/{booking}/cancel', [BookingController::class, 'cancel']);
    Route::put('/booking/{booking}/status', [BookingController::class, 'status']);

    Route::get('/reviews', [ReviewController::class, 'index']);
    Route::get('/reviews/{review}', [ReviewController::class, 'show']);
    Route::post('/reviews', [ReviewController::class, 'store']);
    Route::put('/reviews/{review}', [ReviewController::class, 'update']);
    Route::delete('/reviews/{review}', [ReviewController::class, 'destroy']);
    Route::get('/owner/reviews', [ReviewController::class, 'index']);

    Route::get('/messages', [MessageController::class, 'index']);
    Route::get('/messages/{message}', [MessageController::class, 'show']);
    Route::post('/messages', [MessageController::class, 'store']);
    Route::put('/messages/{message}', [MessageController::class, 'update']);
    Route::delete('/messages/{message}', [MessageController::class, 'destroy']);
    Route::post('/message', [MessageController::class, 'store']);
    Route::get('/conversations', [MessageController::class, 'conversations']);

    Route::get('/payments', [PaymentController::class, 'index']);
    Route::get('/payments/{payment}', [PaymentController::class, 'show']);
    Route::post('/payments', [PaymentController::class, 'store']);
    Route::put('/payments/{payment}', [PaymentController::class, 'update']);
    Route::delete('/payments/{payment}', [PaymentController::class, 'destroy']);

    Route::get('/owner/properties', function (Illuminate\Http\Request $request) {
        $request->merge(['owner_id' => $request->user()?->id]);
        return app(ListingController::class)->index($request);
    });

    Route::get('/owner/reports', function (Illuminate\Http\Request $request) {
        $user = $request->user();
        $properties = \App\Models\Listing::query()->where('owner_id', $user?->id)->count();
        $activeBookings = \App\Models\Booking::query()->whereHas('property', fn($query) => $query->where('owner_id', $user?->id))->whereIn('status', ['approved', 'confirmed', 'paid'])->count();
        $pendingBookings = \App\Models\Booking::query()->whereHas('property', fn($query) => $query->where('owner_id', $user?->id))->where('status', 'pending')->count();
        $revenue = \App\Models\Payment::query()->whereHas('booking.property', fn($query) => $query->where('owner_id', $user?->id))->sum('amount');
        $reviews = \App\Models\Review::query()->whereHas('property', fn($query) => $query->where('owner_id', $user?->id))->count();
        $unreadMessages = \App\Models\Message::query()->where('receiver_id', $user?->id)->whereNull('read_at')->count();

        return response()->json([
            'data' => [
                'properties' => $properties,
                'active_bookings' => $activeBookings,
                'pending_bookings' => $pendingBookings,
                'revenue' => $revenue,
                'reviews' => $reviews,
                'unread_messages' => $unreadMessages,
            ],
        ]);
    });
});
