<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\Message;
use App\Models\Listing;
use App\Models\Payment;
use App\Models\Review;
use App\Models\User;
use Illuminate\Http\Request;

abstract class Controller
{
    protected function currentUser(Request $request): User
    {
        $user = $request->user();

        abort_unless($user instanceof User, 401);

        return $user;
    }

    protected function requireRole(Request $request, string $role): User
    {
        $user = $this->currentUser($request);

        abort_unless($user->role === $role, 403);

        return $user;
    }

    protected function ensurePropertyOwnership(Request $request, Listing $property): User
    {
        $user = $this->requireRole($request, 'owner');

        abort_unless((int) $property->owner_id === (int) $user->id, 403);

        return $user;
    }

    protected function ensureListingOwnership(Request $request, Listing $listing): User
    {
        return $this->ensurePropertyOwnership($request, $listing);
    }

    protected function ensureBookingOwnership(Request $request, Booking $booking): User
    {
        $user = $this->requireRole($request, 'user');

        abort_unless((int) $booking->user_id === (int) $user->id, 403);

        return $user;
    }

    protected function ensurePaymentOwnership(Request $request, Payment $payment): User
    {
        $user = $this->requireRole($request, 'user');

        $payment->loadMissing('booking');

        abort_unless($payment->booking !== null && (int) $payment->booking->user_id === (int) $user->id, 403);

        return $user;
    }

    protected function ensureReviewOwnership(Request $request, Review $review): User
    {
        $user = $this->requireRole($request, 'user');

        abort_unless((int) $review->user_id === (int) $user->id, 403);

        return $user;
    }

    protected function ensureMessageOwnership(Request $request, Message $message): User
    {
        $user = $this->currentUser($request);

        abort_unless(
            (int) $message->sender_id === (int) $user->id || (int) $message->receiver_id === (int) $user->id,
            403
        );

        return $user;
    }
}
