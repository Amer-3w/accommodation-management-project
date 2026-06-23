
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

// ==========================================
// 1. PUBLIC ROUTES (No Auth Required)
// ==========================================
Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);
Route::post('/support-messages', [SupportMessageController::class, 'store']);
Route::post('/support/messages', [SupportMessageController::class, 'store']);

Route::get('/properties', [ListingController::class, 'index']);
Route::get('/properties/{listing}', [ListingController::class, 'show']);
Route::get('/listings', [ListingController::class, 'index']);
Route::get('/listings/{listing}', [ListingController::class, 'show']);

// ==========================================
// 2. AUTHENTICATED ROUTES (Sanctum Protected)
// ==========================================
Route::middleware('auth:sanctum')->group(function (): void {

    // ------------------------------------------
    // SECURE ROLE-PROTECTED ADMIN ENDPOINTS
    // ------------------------------------------
    Route::prefix('admin')->group(function () {

        // Unified Analytics, Dashboard & Reports Data Aggregation
        Route::get('/analytics', function (Illuminate\Http\Request $request) {
            if (!$request->user()?->isAdmin()) {
                abort(403);
            }

            $summary = [
                'total_users' => (int) \App\Models\User::where('role', 'user')->count(),
                'total_owners' => (int) \App\Models\User::where('role', 'owner')->count(),
                'total_properties' => (int) \App\Models\Listing::count(),
                'active_properties' => (int) \App\Models\Listing::where('status', 'active')->count(),
                'pending_properties' => (int) \App\Models\Listing::where('status', 'draft')->count(),
                'total_bookings' => (int) \App\Models\Booking::count(),
                'pending_bookings' => (int) \App\Models\Booking::where('status', 'pending')->count(),
                'approved_bookings' => (int) \App\Models\Booking::where('status', 'approved')->count(),
                'cancelled_bookings' => (int) \App\Models\Booking::where('status', 'cancelled')->count(),
                'total_payments' => (int) \App\Models\Payment::count(),
                'revenue' => (float) \App\Models\Payment::sum('amount'),
                'reviews' => (int) \App\Models\Review::count(),
                'support_messages' => (int) \App\Models\SupportMessage::count(),
                'unread_notifications' => (int) \Illuminate\Support\Facades\DB::table('notifications')->whereNull('read_at')->count(),
            ];

            return response()->json([
                'data' => [
                    'summary' => $summary,
                    'booking_statuses' => [
                        'Pending' => (int) \App\Models\Booking::where('status', 'pending')->count(),
                        'Approved' => (int) \App\Models\Booking::where('status', 'approved')->count(),
                        'Cancelled' => (int) \App\Models\Booking::where('status', 'cancelled')->count(),
                    ],
                    'payment_statuses' => [
                        'Paid' => (int) \App\Models\Payment::where('status', 'paid')->count(),
                        'Pending' => (int) \App\Models\Payment::where('status', 'pending')->count(),
                    ],
                    'users_by_role' => [
                        'Users' => (int) \App\Models\User::where('role', 'user')->count(),
                        'Owners' => (int) \App\Models\User::where('role', 'owner')->count(),
                        'Admins' => (int) \App\Models\User::where('role', 'admin')->count(),
                    ],
                    'properties_by_city' => [
                        'Gaza' => (int) \App\Models\Listing::where('city', 'Gaza')->count(),
                        'Nablus' => (int) \App\Models\Listing::where('city', 'Nablus')->count(),
                        'Ramallah' => (int) \App\Models\Listing::where('city', 'Ramallah')->count(),
                    ],
                    'top_cities' => [],
                    'top_properties' => [],
                    'top_owners' => [],
                    'payments_summary' => [],
                    'bookings_by_month' => ['June' => (int) \App\Models\Booking::count()],
                    'users_growth' => ['June' => (int) \App\Models\User::count()],
                ]
            ]);
        });

        // Dashboard Aggregation Fallback
        Route::get('/dashboard', function (Illuminate\Http\Request $request) {
            if (!$request->user()?->isAdmin()) {
                abort(403);
            }

            $summary = [
                'total_users' => (int) \App\Models\User::where('role', 'user')->count(),
                'total_owners' => (int) \App\Models\User::where('role', 'owner')->count(),
                'total_properties' => (int) \App\Models\Listing::count(),
                'active_properties' => (int) \App\Models\Listing::where('status', 'active')->count(),
                'pending_properties' => (int) \App\Models\Listing::where('status', 'draft')->count(),
                'total_bookings' => (int) \App\Models\Booking::count(),
                'pending_bookings' => (int) \App\Models\Booking::where('status', 'pending')->count(),
                'approved_bookings' => (int) \App\Models\Booking::where('status', 'approved')->count(),
                'cancelled_bookings' => (int) \App\Models\Booking::where('status', 'cancelled')->count(),
                'total_payments' => (int) \App\Models\Payment::count(),
                'revenue' => (float) \App\Models\Payment::sum('amount'),
                'reviews' => (int) \App\Models\Review::count(),
                'support_messages' => (int) \App\Models\SupportMessage::count(),
                'unread_notifications' => (int) \Illuminate\Support\Facades\DB::table('notifications')->whereNull('read_at')->count(),
            ];

            return response()->json([
                'data' => [
                    'summary' => $summary,
                    'booking_statuses' => [
                        'Pending' => (int) \App\Models\Booking::where('status', 'pending')->count(),
                        'Approved' => (int) \App\Models\Booking::where('status', 'approved')->count(),
                        'Cancelled' => (int) \App\Models\Booking::where('status', 'cancelled')->count(),
                    ],
                    'payment_statuses' => [
                        'Paid' => (int) \App\Models\Payment::where('status', 'paid')->count(),
                        'Pending' => (int) \App\Models\Payment::where('status', 'pending')->count(),
                    ],
                    'users_by_role' => [
                        'Users' => (int) \App\Models\User::where('role', 'user')->count(),
                        'Owners' => (int) \App\Models\User::where('role', 'owner')->count(),
                        'Admins' => (int) \App\Models\User::where('role', 'admin')->count(),
                    ],
                    'properties_by_city' => [
                        'Gaza' => (int) \App\Models\Listing::where('city', 'Gaza')->count(),
                        'Nablus' => (int) \App\Models\Listing::where('city', 'Nablus')->count(),
                        'Ramallah' => (int) \App\Models\Listing::where('city', 'Ramallah')->count(),
                    ],
                    'top_cities' => [],
                    'top_properties' => [],
                    'top_owners' => [],
                    'payments_summary' => [],
                    'bookings_by_month' => ['June' => (int) \App\Models\Booking::count()],
                    'users_growth' => ['June' => (int) \App\Models\User::count()],
                ]
            ]);
        });

        // Reports Aggregation Fallback
        Route::get('/reports', function (Illuminate\Http\Request $request) {
            if (!$request->user()?->isAdmin()) {
                abort(403);
            }

            $summary = [
                'total_users' => (int) \App\Models\User::where('role', 'user')->count(),
                'total_owners' => (int) \App\Models\User::where('role', 'owner')->count(),
                'total_properties' => (int) \App\Models\Listing::count(),
                'active_properties' => (int) \App\Models\Listing::where('status', 'active')->count(),
                'pending_properties' => (int) \App\Models\Listing::where('status', 'draft')->count(),
                'total_bookings' => (int) \App\Models\Booking::count(),
                'pending_bookings' => (int) \App\Models\Booking::where('status', 'pending')->count(),
                'approved_bookings' => (int) \App\Models\Booking::where('status', 'approved')->count(),
                'cancelled_bookings' => (int) \App\Models\Booking::where('status', 'cancelled')->count(),
                'total_payments' => (int) \App\Models\Payment::count(),
                'revenue' => (float) \App\Models\Payment::sum('amount'),
                'reviews' => (int) \App\Models\Review::count(),
                'support_messages' => (int) \App\Models\SupportMessage::count(),
                'unread_notifications' => (int) \Illuminate\Support\Facades\DB::table('notifications')->whereNull('read_at')->count(),
            ];

            return response()->json([
                'data' => [
                    'summary' => $summary,
                    'booking_statuses' => [
                        'Pending' => (int) \App\Models\Booking::where('status', 'pending')->count(),
                        'Approved' => (int) \App\Models\Booking::where('status', 'approved')->count(),
                        'Cancelled' => (int) \App\Models\Booking::where('status', 'cancelled')->count(),
                    ],
                    'payment_statuses' => [
                        'Paid' => (int) \App\Models\Payment::where('status', 'paid')->count(),
                        'Pending' => (int) \App\Models\Payment::where('status', 'pending')->count(),
                    ],
                    'users_by_role' => [
                        'Users' => (int) \App\Models\User::where('role', 'user')->count(),
                        'Owners' => (int) \App\Models\User::where('role', 'owner')->count(),
                        'Admins' => (int) \App\Models\User::where('role', 'admin')->count(),
                    ],
                    'properties_by_city' => [
                        'Gaza' => (int) \App\Models\Listing::where('city', 'Gaza')->count(),
                        'Nablus' => (int) \App\Models\Listing::where('city', 'Nablus')->count(),
                        'Ramallah' => (int) \App\Models\Listing::where('city', 'Ramallah')->count(),
                    ],
                    'top_cities' => [],
                    'top_properties' => [],
                    'top_owners' => [],
                    'payments_summary' => [],
                    'bookings_by_month' => ['June' => (int) \App\Models\Booking::count()],
                    'users_growth' => ['June' => (int) \App\Models\User::count()],
                ]
            ]);
        });



        // Direct-Fetch Bookings Layer (Fixes Infinite Loading)
        Route::get('/bookings', function (Illuminate\Http\Request $request) {
            if (!$request->user()?->isAdmin()) {
                abort(403);
            }
            $bookings = \App\Models\Booking::with(['user', 'property'])->latest()->get();
            return response()->json(['data' => $bookings]);
        });

        // Direct-Fetch Payments Layer (Fixes Infinite Loading)
        Route::get('/payments', function (Illuminate\Http\Request $request) {
            if (!$request->user()?->isAdmin()) {
                abort(403);
            }
            $payments = \App\Models\Payment::with(['booking.user', 'booking.property'])->latest()->get();
            return response()->json(['data' => $payments]);
        });

        // Notifications Layer
        Route::get('/notifications', function (Illuminate\Http\Request $request) {
            if (!$request->user()?->isAdmin()) {
                abort(403);
            }
            $notifications = \Illuminate\Support\Facades\DB::table('notifications')->latest()->get();
            return response()->json(['data' => $notifications]);
        });

        Route::post('/notifications/mark-all-read', function (Illuminate\Http\Request $request) {
            if (!$request->user()?->isAdmin()) {
                abort(403);
            }
            \Illuminate\Support\Facades\DB::table('notifications')
                ->where('notifiable_id', $request->user()->id)
                ->update(['read_at' => now()]);
            return response()->json(['message' => 'All notifications marked as read.']);
        });

        // Properties / Listings Collections
        Route::get('/properties', function (Illuminate\Http\Request $request) {
            if (!$request->user()?->isAdmin()) {
                abort(403);
            }
            $listings = \App\Models\Listing::with(['owner', 'images'])->latest()->get();
            return response()->json(['data' => $listings]);
        });

        Route::get('/listings', function (Illuminate\Http\Request $request) {
            if (!$request->user()?->isAdmin()) {
                abort(403);
            }
            $listings = \App\Models\Listing::with(['owner', 'images'])->latest()->get();
            return response()->json(['data' => $listings]);
        });

        // Users & Owners Filtering (Ensures Proper Role Account Tracking)
        Route::get('/users', function (Illuminate\Http\Request $request) {
            if (!$request->user()?->isAdmin()) {
                abort(403);
            }
            $users = \App\Models\User::where('role', 'user')->latest()->get();
            return response()->json(['data' => $users]);
        });

        Route::get('/owners', function (Illuminate\Http\Request $request) {
            if (!$request->user()?->isAdmin()) {
                abort(403);
            }
            $owners = \App\Models\User::where('role', 'owner')->latest()->get();
            return response()->json(['data' => $owners]);
        });

        // Reviews Layer
        Route::get('/reviews', function (Illuminate\Http\Request $request) {
            if (!$request->user()?->isAdmin()) {
                abort(403);
            }
            $reviews = \App\Models\Review::with(['user', 'property'])->latest()->get();
            return response()->json(['data' => $reviews]);
        });

        // Support Tickets Management
        Route::get('/support-messages', function (Illuminate\Http\Request $request) {
            if (!$request->user()?->isAdmin()) {
                abort(403);
            }
            $messages = \App\Models\SupportMessage::latest()->get();
            return response()->json(['data' => $messages]);
        });
    });


    // Profile & Authentication
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::get('/me', [AuthController::class, 'me']);
    Route::get('/me/stats', [AuthController::class, 'stats']);
    Route::put('/auth/me', [AuthController::class, 'updateProfile']);
    Route::put('/me', [AuthController::class, 'updateProfile']);
    Route::post('/me/photo', [AuthController::class, 'uploadPhoto']);
    Route::post('/auth/logout', [AuthController::class, 'logout']);

    // Whatsapp Actions
    Route::get('/user-whatsapp-numbers', [UserWhatsappNumberController::class, 'index']);
    Route::post('/user-whatsapp-numbers', [UserWhatsappNumberController::class, 'store']);
    Route::put('/user-whatsapp-numbers/{userWhatsappNumber}', [UserWhatsappNumberController::class, 'update']);
    Route::delete('/user-whatsapp-numbers/{userWhatsappNumber}', [UserWhatsappNumberController::class, 'destroy']);
    Route::post('/me/whatsapp-numbers', [UserWhatsappNumberController::class, 'store']);
    Route::put('/me/whatsapp-numbers/{userWhatsappNumber}', [UserWhatsappNumberController::class, 'update']);
    Route::delete('/me/whatsapp-numbers/{userWhatsappNumber}', [UserWhatsappNumberController::class, 'destroy']);

    // Favorites
    Route::get('/favorites', [FavoriteController::class, 'index']);
    Route::post('/favorites', [FavoriteController::class, 'store']);
    Route::delete('/favorites/{favorite}', [FavoriteController::class, 'destroy']);
    Route::post('/favorites/toggle', [FavoriteController::class, 'toggle']);

    // Support Messaging (Standard Access)
    Route::get('/support-messages', [SupportMessageController::class, 'index']);
    Route::get('/support-messages/{supportMessage}', [SupportMessageController::class, 'show']);
    Route::put('/support-messages/{supportMessage}', [SupportMessageController::class, 'update']);
    Route::delete('/support-messages/{supportMessage}', [SupportMessageController::class, 'destroy']);
    Route::get('/support/admin-contact', [SupportMessageController::class, 'adminContact']);

    // Standard Notifications
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::post('/notifications/mark-all-read', [NotificationController::class, 'markAllRead']);

    // Properties / Listings Data Controls
    Route::post('/properties', [ListingController::class, 'store']);
    Route::put('/properties/{listing}', [ListingController::class, 'update']);
    Route::delete('/properties/{listing}', [ListingController::class, 'destroy']);
    Route::post('/listings', [ListingController::class, 'store']);
    Route::put('/listings/{listing}', [ListingController::class, 'update']);
    Route::delete('/listings/{listing}', [ListingController::class, 'destroy']);

    // Media
    Route::get('/properties/{listing}/images', [PropertyImageController::class, 'index']);
    Route::post('/properties/{listing}/images', [PropertyImageController::class, 'store']);
    Route::put('/property-images/{propertyImage}', [PropertyImageController::class, 'update']);
    Route::delete('/property-images/{propertyImage}', [PropertyImageController::class, 'destroy']);
    // Bookings Framework Layout
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

    // Reviews & Comments 
    Route::get('/reviews', [ReviewController::class, 'index']);
    Route::get('/reviews/{review}', [ReviewController::class, 'show']);
    Route::post('/reviews', [ReviewController::class, 'store']);
    Route::put('/reviews/{review}', [ReviewController::class, 'update']);
    Route::delete('/reviews/{review}', [ReviewController::class, 'destroy']);
    Route::get('/owner/reviews', [ReviewController::class, 'index']);

    // Live Instant Messages
    Route::get('/messages', [MessageController::class, 'index']);
    Route::get('/messages/{message}', [MessageController::class, 'show']);
    Route::post('/messages', [MessageController::class, 'store']);
    Route::put('/messages/{message}', [MessageController::class, 'update']);
    // ... (Your messaging controls mapping finishes up perfectly downstream)
    Route::delete('/messages/{message}', [MessageController::class, 'destroy']);
    Route::post('/message', [MessageController::class, 'store']);
    Route::get('/conversations', [MessageController::class, 'conversations']);

    // Payment Processing
    Route::get('/payments', function (Illuminate\Http\Request $request) {
        $user = $request->user();
        $payments = \App\Models\Payment::query()
            ->whereHas('booking', function ($query) use ($user) {
                $query->where('user_id', $user?->id);
            })
            ->with(['booking.property'])
            ->latest()
            ->get();

        return response()->json([
            'data' => [
                'data' => $payments
            ]
        ]);
    });
    Route::get('/payments/{payment}', [PaymentController::class, 'show']);
    Route::post('/payments', [PaymentController::class, 'store']);
    Route::put('/payments/{payment}', [PaymentController::class, 'update']);
    Route::delete('/payments/{payment}', [PaymentController::class, 'destroy']);

    // Property Owner Core Business Portals
    Route::get('/owner/properties', function (Illuminate\Http\Request $request) {
        $request->merge(['owner_id' => $request->user()?->id]);
        return app(ListingController::class)->index($request);
    });

    Route::get('/owner/bookings', function (Illuminate\Http\Request $request) {
        $user = $request->user();
        $bookings = \App\Models\Booking::with(['user', 'property.owner', 'property.images', 'payment'])
            ->whereHas('property', fn($query) => $query->where('owner_id', $user?->id))
            ->latest()
            ->get();
        return response()->json(['data' => $bookings]);
    });

    Route::put('/owner/bookings/{booking}/status', function (Illuminate\Http\Request $request, \App\Models\Booking $booking) {
        $user = $request->user();
        abort_if((int) $booking->property->owner_id !== (int) $user->id, 403);
        $validated = $request->validate([
            'status' => ['required', 'in:approved,rejected,cancelled,completed'],
        ]);
        $booking->update(['status' => $validated['status']]);
        return response()->json($booking->load(['user', 'property.owner', 'property.images', 'payment']));
    });

    Route::get('/owner/tenants', function (Illuminate\Http\Request $request) {
        $user = $request->user();
        $tenants = \App\Models\User::whereHas('bookings', function ($query) use ($user) {
            $query->whereHas('property', fn($q) => $q->where('owner_id', $user?->id))
                  ->whereIn('status', ['approved', 'confirmed', 'paid', 'completed']);
        })->get();
        return response()->json(['data' => $tenants]);
    });

    Route::get('/owner/payments', function (Illuminate\Http\Request $request) {
        $user = $request->user();
        $payments = \App\Models\Payment::with(['booking.user', 'booking.property.owner', 'booking.property.images'])
            ->whereHas('booking.property', fn($query) => $query->where('owner_id', $user?->id))
            ->latest()
            ->get();
        return response()->json(['data' => $payments]);
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
