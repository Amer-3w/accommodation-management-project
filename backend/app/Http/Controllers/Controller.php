<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\Listing;
use App\Models\Payment;
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

    protected function ensureListingOwnership(Request $request, Listing $listing): User
    {
        $user = $this->requireRole($request, 'owner');

        abort_unless((int) $listing->owner_id === (int) $user->id, 403);

        return $user;
    }

    protected function ensureBookingOwnership(Request $request, Booking $booking): User
    {
        $user = $this->requireRole($request, 'tenant');

        abort_unless((int) $booking->tenant_id === (int) $user->id, 403);

        return $user;
    }

    protected function ensurePaymentOwnership(Request $request, Payment $payment): User
    {
        $user = $this->requireRole($request, 'tenant');

        $payment->loadMissing('booking');

        abort_unless($payment->booking !== null && (int) $payment->booking->tenant_id === (int) $user->id, 403);

        return $user;
    }
}
