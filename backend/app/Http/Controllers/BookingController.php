<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class BookingController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $tenant = $this->requireRole($request, 'tenant');

        $bookings = Booking::with(['tenant', 'listing.owner', 'payment'])
            ->where('tenant_id', $tenant->id)
            ->latest()
            ->get();

        return response()->json($bookings);
    }

    public function show(Request $request, Booking $booking): JsonResponse
    {
        $this->ensureBookingOwnership($request, $booking);

        return response()->json($booking->load(['tenant', 'listing.owner', 'payment']));
    }

    public function store(Request $request): JsonResponse
    {
        $tenant = $this->requireRole($request, 'tenant');

        $validated = $request->validate([
            'listing_id' => ['required', 'exists:listings,id'],
            'check_in_date' => ['required', 'date'],
            'check_out_date' => ['required', 'date', 'after_or_equal:check_in_date'],
            'guests' => ['nullable', 'integer', 'min:1'],
            'total_price' => ['required', 'numeric', 'min:0'],
            'status' => ['nullable', 'string', 'max:255'],
            'notes' => ['nullable', 'string'],
        ]);

        $this->ensureListingIsAvailable(
            (int) $validated['listing_id'],
            $validated['check_in_date'],
            $validated['check_out_date']
        );

        $booking = Booking::create([
            'tenant_id' => $tenant->id,
            'listing_id' => $validated['listing_id'],
            'check_in_date' => $validated['check_in_date'],
            'check_out_date' => $validated['check_out_date'],
            'guests' => $validated['guests'] ?? 1,
            'total_price' => $validated['total_price'],
            'status' => $validated['status'] ?? 'pending',
            'notes' => $validated['notes'] ?? null,
        ]);

        return response()->json($booking->load(['tenant', 'listing.owner', 'payment']), 201);
    }

    public function update(Request $request, Booking $booking): JsonResponse
    {
        $this->ensureBookingOwnership($request, $booking);

        $validated = $request->validate([
            'listing_id' => ['required', 'exists:listings,id'],
            'check_in_date' => ['required', 'date'],
            'check_out_date' => ['required', 'date', 'after_or_equal:check_in_date'],
            'guests' => ['nullable', 'integer', 'min:1'],
            'total_price' => ['required', 'numeric', 'min:0'],
            'status' => ['nullable', 'string', 'max:255'],
            'notes' => ['nullable', 'string'],
        ]);

        $this->ensureListingIsAvailable(
            (int) $validated['listing_id'],
            $validated['check_in_date'],
            $validated['check_out_date'],
            $booking->id
        );

        $booking->update([
            'tenant_id' => $booking->tenant_id,
            'listing_id' => $validated['listing_id'],
            'check_in_date' => $validated['check_in_date'],
            'check_out_date' => $validated['check_out_date'],
            'guests' => $validated['guests'] ?? 1,
            'total_price' => $validated['total_price'],
            'status' => $validated['status'] ?? 'pending',
            'notes' => $validated['notes'] ?? null,
        ]);

        return response()->json($booking->load(['tenant', 'listing.owner', 'payment']));
    }

    private function ensureListingIsAvailable(int $listingId, string $checkInDate, string $checkOutDate, ?int $ignoreBookingId = null): void
    {
        $isConflictingBooking = Booking::query()
            ->where('listing_id', $listingId)
            ->when($ignoreBookingId !== null, function ($bookingQuery) use ($ignoreBookingId): void {
                $bookingQuery->where('id', '!=', $ignoreBookingId);
            })
            ->whereDate('check_in_date', '<=', $checkOutDate)
            ->whereDate('check_out_date', '>=', $checkInDate)
            ->exists();

        if ($isConflictingBooking) {
            throw ValidationException::withMessages([
                'listing_id' => ['The selected listing is already booked for the chosen dates.'],
            ]);
        }
    }

    public function destroy(Request $request, Booking $booking): JsonResponse
    {
        $this->ensureBookingOwnership($request, $booking);

        $booking->delete();

        return response()->json([
            'message' => 'Booking deleted successfully.',
        ]);
    }
}
