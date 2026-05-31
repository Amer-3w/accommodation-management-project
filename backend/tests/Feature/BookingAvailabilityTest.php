<?php

namespace Tests\Feature;

use App\Models\Booking;
use App\Models\Listing;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class BookingAvailabilityTest extends TestCase
{
    use RefreshDatabase;

    public function test_store_rejects_overlapping_booking_dates(): void
    {
        [, $user, $listing] = $this->createPropertyContext();

        Booking::create([
            'user_id' => $user->id,
            'property_id' => $listing->id,
            'date_from' => '2026-05-10',
            'date_to' => '2026-05-15',
            'guests' => 1,
            'total_price' => 500,
            'status' => 'confirmed',
            'notes' => null,
        ]);

        $response = $this->actingAs($user)->postJson('/api/bookings', [
            'property_id' => $listing->id,
            'date_from' => '2026-05-12',
            'date_to' => '2026-05-18',
            'guests' => 2,
            'total_price' => 700,
            'status' => 'pending',
            'notes' => null,
        ]);

        $response->assertStatus(422);
        $response->assertJsonValidationErrors(['property_id']);
    }

    public function test_update_rejects_overlapping_booking_dates(): void
    {
        [, $user, $listing] = $this->createPropertyContext();

        Booking::create([
            'user_id' => $user->id,
            'property_id' => $listing->id,
            'date_from' => '2026-05-10',
            'date_to' => '2026-05-15',
            'guests' => 1,
            'total_price' => 500,
            'status' => 'confirmed',
            'notes' => null,
        ]);

        $bookingToUpdate = Booking::create([
            'user_id' => $user->id,
            'property_id' => $listing->id,
            'date_from' => '2026-05-20',
            'date_to' => '2026-05-25',
            'guests' => 1,
            'total_price' => 500,
            'status' => 'pending',
            'notes' => null,
        ]);

        $response = $this->actingAs($user)->putJson('/api/bookings/' . $bookingToUpdate->id, [
            'property_id' => $listing->id,
            'date_from' => '2026-05-12',
            'date_to' => '2026-05-18',
            'guests' => 1,
            'total_price' => 500,
            'status' => 'pending',
            'notes' => null,
        ]);

        $response->assertStatus(422);
        $response->assertJsonValidationErrors(['property_id']);
    }

    private function createPropertyContext(): array
    {
        $owner = User::factory()->create([
            'role' => 'owner',
        ]);

        $tenant = User::factory()->create([
            'role' => 'user',
        ]);

        $listing = Listing::create([
            'owner_id' => $owner->id,
            'title' => 'Test Room',
            'price' => 500,
            'location' => 'Cairo - Nasr City',
            'description' => 'Test property for booking availability.',
            'rooms' => 1,
            'amenities' => ['wifi'],
            'status' => 'active',
        ]);

        return [$owner, $tenant, $listing];
    }
}
