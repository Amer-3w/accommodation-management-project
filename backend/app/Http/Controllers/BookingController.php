<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class BookingController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $this->requireRole($request, 'user');

        $bookings = Booking::with(['user', 'property.owner', 'property.images', 'payment'])
            ->where('user_id', $user->id)
            ->latest()
            ->get();

        return response()->json($bookings);
    }

    public function show(Request $request, Booking $booking): JsonResponse
    {
        $this->ensureBookingOwnership($request, $booking);

        return response()->json($booking->load(['user', 'property.owner', 'property.images', 'payment']));
    }

    public function store(Request $request): JsonResponse
    {
        $user = $this->requireRole($request, 'user');

        $this->normalizeBookingPayload($request);

        $validated = $request->validate([
            'property_id' => ['required', 'exists:properties,id'],
            'date_from' => ['required', 'date'],
            'date_to' => ['required', 'date', 'after_or_equal:date_from'],
            'guests' => ['nullable', 'integer', 'min:1'],
            'total_price' => ['required', 'numeric', 'min:0'],
            'status' => ['nullable', Rule::in(['pending', 'confirmed', 'cancelled', 'paid', 'completed'])],
            'notes' => ['nullable', 'string'],
        ]);

        $this->ensureListingIsAvailable(
            (int) $validated['property_id'],
            $validated['date_from'],
            $validated['date_to']
        );

        $booking = Booking::create([
            'user_id' => $user->id,
            'property_id' => $validated['property_id'],
            'date_from' => $validated['date_from'],
            'date_to' => $validated['date_to'],
            'guests' => $validated['guests'] ?? 1,
            'total_price' => $validated['total_price'],
            'status' => $validated['status'] ?? 'pending',
            'notes' => $validated['notes'] ?? null,
        ]);

        return response()->json($booking->load(['user', 'property.owner', 'property.images', 'payment']), 201);
    }

    public function update(Request $request, Booking $booking): JsonResponse
    {
        $this->ensureBookingOwnership($request, $booking);

        $this->normalizeBookingPayload($request);

        $validated = $request->validate([
            'property_id' => ['required', 'exists:properties,id'],
            'date_from' => ['required', 'date'],
            'date_to' => ['required', 'date', 'after_or_equal:date_from'],
            'guests' => ['nullable', 'integer', 'min:1'],
            'total_price' => ['required', 'numeric', 'min:0'],
            'status' => ['nullable', Rule::in(['pending', 'confirmed', 'cancelled', 'paid', 'completed'])],
            'notes' => ['nullable', 'string'],
        ]);

        $this->ensureListingIsAvailable(
            (int) $validated['property_id'],
            $validated['date_from'],
            $validated['date_to'],
            $booking->id
        );

        $booking->update([
            'user_id' => $booking->user_id,
            'property_id' => $validated['property_id'],
            'date_from' => $validated['date_from'],
            'date_to' => $validated['date_to'],
            'guests' => $validated['guests'] ?? 1,
            'total_price' => $validated['total_price'],
            'status' => $validated['status'] ?? 'pending',
            'notes' => $validated['notes'] ?? null,
        ]);

        return response()->json($booking->load(['user', 'property.owner', 'property.images', 'payment']));
    }

    private function normalizeBookingPayload(Request $request): void
    {
        $request->merge([
            'property_id' => $request->input('property_id', $request->input('listing_id')),
            'date_from' => $request->input('date_from', $request->input('check_in_date')),
            'date_to' => $request->input('date_to', $request->input('check_out_date')),
        ]);
    }

    private function ensureListingIsAvailable(int $propertyId, string $dateFrom, string $dateTo, ?int $ignoreBookingId = null): void
    {
        $isConflictingBooking = Booking::query()
            ->where('property_id', $propertyId)
            ->when($ignoreBookingId !== null, function ($bookingQuery) use ($ignoreBookingId): void {
                $bookingQuery->where('id', '!=', $ignoreBookingId);
            })
            ->whereDate('date_from', '<=', $dateTo)
            ->whereDate('date_to', '>=', $dateFrom)
            ->exists();

        if ($isConflictingBooking) {
            throw ValidationException::withMessages([
                'property_id' => ['The selected property is already booked for the chosen dates.'],
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
