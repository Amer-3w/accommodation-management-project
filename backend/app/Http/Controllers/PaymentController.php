<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\Payment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class PaymentController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $tenant = $this->requireRole($request, 'tenant');

        $payments = Payment::with(['booking.tenant', 'booking.listing.owner'])
            ->whereHas('booking', function ($bookingQuery) use ($tenant): void {
                $bookingQuery->where('tenant_id', $tenant->id);
            })
            ->latest()
            ->get();

        return response()->json($payments);
    }

    public function show(Request $request, Payment $payment): JsonResponse
    {
        $this->ensurePaymentOwnership($request, $payment);

        return response()->json($payment->load(['booking.tenant', 'booking.listing.owner']));
    }

    public function store(Request $request): JsonResponse
    {
        $tenant = $this->requireRole($request, 'tenant');

        $validated = $request->validate([
            'booking_id' => ['required', 'exists:bookings,id', 'unique:payments,booking_id'],
            'amount' => ['required', 'numeric', 'min:0'],
            'payment_method' => ['required', 'string', 'max:255'],
            'status' => ['nullable', 'string', 'max:255'],
            'transaction_reference' => ['nullable', 'string', 'max:255'],
            'paid_at' => ['nullable', 'date'],
            'notes' => ['nullable', 'string'],
        ]);

        $booking = Booking::with('listing')->findOrFail($validated['booking_id']);

        abort_unless((int) $booking->tenant_id === (int) $tenant->id, 403);

        $payment = Payment::create([
            'booking_id' => $validated['booking_id'],
            'amount' => $validated['amount'],
            'payment_method' => $validated['payment_method'],
            'status' => $validated['status'] ?? 'pending',
            'transaction_reference' => $validated['transaction_reference'] ?? null,
            'paid_at' => $validated['paid_at'] ?? null,
            'notes' => $validated['notes'] ?? null,
        ]);

        return response()->json($payment->load(['booking.tenant', 'booking.listing.owner']), 201);
    }

    public function update(Request $request, Payment $payment): JsonResponse
    {
        $tenant = $this->ensurePaymentOwnership($request, $payment);

        $validated = $request->validate([
            'booking_id' => [
                'required',
                'exists:bookings,id',
                Rule::unique('payments', 'booking_id')->ignore($payment->id),
            ],
            'amount' => ['required', 'numeric', 'min:0'],
            'payment_method' => ['required', 'string', 'max:255'],
            'status' => ['nullable', 'string', 'max:255'],
            'transaction_reference' => ['nullable', 'string', 'max:255'],
            'paid_at' => ['nullable', 'date'],
            'notes' => ['nullable', 'string'],
        ]);

        $booking = Booking::with('listing')->findOrFail($validated['booking_id']);

        abort_unless((int) $booking->tenant_id === (int) $tenant->id, 403);

        $payment->update([
            'booking_id' => $validated['booking_id'],
            'amount' => $validated['amount'],
            'payment_method' => $validated['payment_method'],
            'status' => $validated['status'] ?? 'pending',
            'transaction_reference' => $validated['transaction_reference'] ?? null,
            'paid_at' => $validated['paid_at'] ?? null,
            'notes' => $validated['notes'] ?? null,
        ]);

        return response()->json($payment->load(['booking.tenant', 'booking.listing.owner']));
    }

    public function destroy(Request $request, Payment $payment): JsonResponse
    {
        $this->ensurePaymentOwnership($request, $payment);

        $payment->delete();

        return response()->json([
            'message' => 'Payment deleted successfully.',
        ]);
    }
}
