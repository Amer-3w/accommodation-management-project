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
        $user = $this->requireRole($request, 'user');

        $payments = Payment::with(['booking.user', 'booking.property.owner', 'booking.property.images'])
            ->whereHas('booking', function ($bookingQuery) use ($user): void {
                $bookingQuery->where('user_id', $user->id);
            })
            ->latest()
            ->get();

        return response()->json($payments);
    }

    public function show(Request $request, Payment $payment): JsonResponse
    {
        $this->ensurePaymentOwnership($request, $payment);

        return response()->json($payment->load(['booking.user', 'booking.property.owner', 'booking.property.images']));
    }

    public function store(Request $request): JsonResponse
    {
        $user = $this->requireRole($request, 'user');

        $this->normalizePaymentPayload($request);

        $validated = $request->validate([
            'booking_id' => ['required', 'exists:bookings,id', 'unique:payments,booking_id'],
            'amount' => ['required', 'numeric', 'min:0'],
            'method' => ['required', Rule::in(['cash', 'card'])],
            'status' => ['nullable', Rule::in(['pending', 'paid', 'failed', 'refunded'])],
            'reference' => ['required', 'string', 'max:255', 'unique:payments,reference'],
            'paid_at' => ['nullable', 'date'],
            'notes' => ['nullable', 'string'],
        ]);

        $booking = Booking::with('property')->findOrFail($validated['booking_id']);

        abort_unless((int) $booking->user_id === (int) $user->id, 403);

        $payment = Payment::create([
            'booking_id' => $validated['booking_id'],
            'amount' => $validated['amount'],
            'method' => $validated['method'],
            'status' => $validated['status'] ?? 'pending',
            'reference' => $validated['reference'],
            'paid_at' => $validated['paid_at'] ?? null,
            'notes' => $validated['notes'] ?? null,
        ]);

        return response()->json($payment->load(['booking.user', 'booking.property.owner', 'booking.property.images']), 201);
    }

    public function update(Request $request, Payment $payment): JsonResponse
    {
        $user = $this->ensurePaymentOwnership($request, $payment);

        $this->normalizePaymentPayload($request);

        $validated = $request->validate([
            'booking_id' => [
                'required',
                'exists:bookings,id',
                Rule::unique('payments', 'booking_id')->ignore($payment->id),
            ],
            'amount' => ['required', 'numeric', 'min:0'],
            'method' => ['required', Rule::in(['cash', 'card'])],
            'status' => ['nullable', Rule::in(['pending', 'paid', 'failed', 'refunded'])],
            'reference' => ['required', 'string', 'max:255', Rule::unique('payments', 'reference')->ignore($payment->id)],
            'paid_at' => ['nullable', 'date'],
            'notes' => ['nullable', 'string'],
        ]);

        $booking = Booking::with('property')->findOrFail($validated['booking_id']);

        abort_unless((int) $booking->user_id === (int) $user->id, 403);

        $payment->update([
            'booking_id' => $validated['booking_id'],
            'amount' => $validated['amount'],
            'method' => $validated['method'],
            'status' => $validated['status'] ?? 'pending',
            'reference' => $validated['reference'],
            'paid_at' => $validated['paid_at'] ?? null,
            'notes' => $validated['notes'] ?? null,
        ]);

        return response()->json($payment->load(['booking.user', 'booking.property.owner', 'booking.property.images']));
    }

    private function normalizePaymentPayload(Request $request): void
    {
        $request->merge([
            'method' => $request->input('method', $request->input('payment_method')),
            'reference' => $request->input('reference', $request->input('transaction_reference')),
        ]);
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
