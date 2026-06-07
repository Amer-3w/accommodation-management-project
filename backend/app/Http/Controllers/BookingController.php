<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\Listing;
use Carbon\Carbon;
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
            'notes' => ['nullable', 'string'],
            'base_price' => ['nullable', 'numeric', 'min:0'],
            'price_period' => ['nullable', Rule::in(['day', 'week', 'month'])],
            'number_of_days' => ['nullable', 'integer', 'min:1'],
            'base_total' => ['nullable', 'numeric', 'min:0'],
            'discount_percent' => ['nullable', 'numeric', 'min:0'],
            'discount_amount' => ['nullable', 'numeric', 'min:0'],
            'service_fee' => ['nullable', 'numeric', 'min:0'],
            'security_deposit' => ['nullable', 'numeric', 'min:0'],
            'final_total' => ['nullable', 'numeric', 'min:0'],
            'status' => ['nullable', Rule::in(['pending', 'approved', 'rejected', 'cancelled', 'completed', 'paid', 'confirmed'])],
        ]);

        $property = Listing::findOrFail((int) $validated['property_id']);
        $financials = $this->resolveBookingFinancials($validated, $property);

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
            'notes' => $validated['notes'] ?? null,
            'base_price' => $financials['base_price'],
            'price_period' => $financials['price_period'],
            'number_of_days' => $financials['number_of_days'],
            'base_total' => $financials['base_total'],
            'discount_percent' => $financials['discount_percent'],
            'discount_amount' => $financials['discount_amount'],
            'service_fee' => $financials['service_fee'],
            'security_deposit' => $financials['security_deposit'],
            'final_total' => $financials['final_total'],
            'status' => $validated['status'] ?? 'pending',
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
            'notes' => ['nullable', 'string'],
            'base_price' => ['nullable', 'numeric', 'min:0'],
            'price_period' => ['nullable', Rule::in(['day', 'week', 'month'])],
            'number_of_days' => ['nullable', 'integer', 'min:1'],
            'base_total' => ['nullable', 'numeric', 'min:0'],
            'discount_percent' => ['nullable', 'numeric', 'min:0'],
            'discount_amount' => ['nullable', 'numeric', 'min:0'],
            'service_fee' => ['nullable', 'numeric', 'min:0'],
            'security_deposit' => ['nullable', 'numeric', 'min:0'],
            'final_total' => ['nullable', 'numeric', 'min:0'],
            'status' => ['nullable', Rule::in(['pending', 'approved', 'rejected', 'cancelled', 'completed', 'paid', 'confirmed'])],
        ]);

        $property = Listing::findOrFail((int) $validated['property_id']);
        $financials = $this->resolveBookingFinancials($validated, $property);

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
            'notes' => $validated['notes'] ?? null,
            'base_price' => $financials['base_price'],
            'price_period' => $financials['price_period'],
            'number_of_days' => $financials['number_of_days'],
            'base_total' => $financials['base_total'],
            'discount_percent' => $financials['discount_percent'],
            'discount_amount' => $financials['discount_amount'],
            'service_fee' => $financials['service_fee'],
            'security_deposit' => $financials['security_deposit'],
            'final_total' => $financials['final_total'],
            'status' => $validated['status'] ?? 'pending',
        ]);

        return response()->json($booking->load(['user', 'property.owner', 'property.images', 'payment']));
    }

    private function normalizeBookingPayload(Request $request): void
    {
        $propertyId = $request->input('property_id', $request->input('listing_id'));
        $dateFrom = $request->input('date_from', $request->input('check_in_date'));
        $dateTo = $request->input('date_to', $request->input('check_out_date'));

        $request->merge([
            'property_id' => $propertyId,
            'date_from' => $dateFrom,
            'date_to' => $dateTo,
            'final_total' => $request->input('final_total', $request->input('total_price')),
            'price_period' => $request->input('price_period', 'month'),
        ]);
    }

    private function resolveBookingFinancials(array $validated, Listing $property): array
    {
        $dateFrom = Carbon::parse($validated['date_from']);
        $dateTo = Carbon::parse($validated['date_to']);

        $numberOfDays = max(1, (int) ($validated['number_of_days'] ?? $dateFrom->diffInDays($dateTo) + 1));
        $basePrice = (float) ($validated['base_price'] ?? $property->price);
        $pricePeriod = $validated['price_period'] ?? $property->price_duration ?? 'month';
        $baseTotal = (float) ($validated['base_total'] ?? round($basePrice * $numberOfDays, 2));

        $discountPercent = $validated['discount_percent'] ?? match ($pricePeriod) {
            'week' => (float) ($property->weekly_discount ?? 0),
            'month' => (float) ($property->monthly_discount ?? 0),
            default => $numberOfDays >= (int) ($property->stay_duration ?? 1)
                ? (float) ($property->long_stay_discount ?? 0)
                : 0.0,
        };

        $discountAmount = (float) ($validated['discount_amount'] ?? round($baseTotal * ($discountPercent / 100), 2));
        $serviceFee = (float) ($validated['service_fee'] ?? 50);
        $securityDeposit = (float) ($validated['security_deposit'] ?? 0);
        $finalTotal = (float) ($validated['final_total'] ?? round($baseTotal - $discountAmount + $serviceFee + $securityDeposit, 2));

        return [
            'base_price' => $basePrice,
            'price_period' => $pricePeriod,
            'number_of_days' => $numberOfDays,
            'base_total' => $baseTotal,
            'discount_percent' => (float) $discountPercent,
            'discount_amount' => $discountAmount,
            'service_fee' => $serviceFee,
            'security_deposit' => $securityDeposit,
            'final_total' => $finalTotal,
        ];
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

    public function status(Request $request, Booking $booking): JsonResponse
    {
        $this->ensureBookingOwnership($request, $booking);

        $validated = $request->validate([
            'status' => ['required', Rule::in(['pending', 'approved', 'rejected', 'cancelled', 'completed', 'paid', 'confirmed'])],
        ]);

        $booking->update(['status' => $validated['status']]);

        return response()->json($booking->load(['user', 'property.owner', 'property.images', 'payment']));
    }

    public function cancel(Request $request, Booking $booking): JsonResponse
    {
        $this->ensureBookingOwnership($request, $booking);

        $booking->update(['status' => 'cancelled']);

        return response()->json($booking->load(['user', 'property.owner', 'property.images', 'payment']));
    }
}
