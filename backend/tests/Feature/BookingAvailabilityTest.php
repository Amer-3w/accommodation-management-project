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
        [, $tenant, $listing] = $this->createListingContext();

        Booking::create([
            'tenant_id' => $tenant->id,
            'listing_id' => $listing->id,
            'check_in_date' => '2026-05-10',
            'check_out_date' => '2026-05-15',
            'guests' => 1,
            'total_price' => 500,
            'status' => 'confirmed',
            'notes' => null,
        ]);

        $response = $this->actingAs($tenant)->postJson('/api/bookings', [
            'listing_id' => $listing->id,
            'check_in_date' => '2026-05-12',
            'check_out_date' => '2026-05-18',
            'guests' => 2,
            'total_price' => 700,
            'status' => 'pending',
            'notes' => null,
        ]);

        $response->assertStatus(422);
        $response->assertJsonValidationErrors(['listing_id']);
    }

    public function test_update_rejects_overlapping_booking_dates(): void
    {
        [, $tenant, $listing] = $this->createListingContext();

        Booking::create([
            'tenant_id' => $tenant->id,
            'listing_id' => $listing->id,
            'check_in_date' => '2026-05-10',
            'check_out_date' => '2026-05-15',
            'guests' => 1,
            'total_price' => 500,
            'status' => 'confirmed',
            'notes' => null,
        ]);

        $bookingToUpdate = Booking::create([
            'tenant_id' => $tenant->id,
            'listing_id' => $listing->id,
            'check_in_date' => '2026-05-20',
            'check_out_date' => '2026-05-25',
            'guests' => 1,
            'total_price' => 500,
            'status' => 'pending',
            'notes' => null,
        ]);

        $response = $this->actingAs($tenant)->putJson('/api/bookings/' . $bookingToUpdate->id, [
            'listing_id' => $listing->id,
            'check_in_date' => '2026-05-12',
            'check_out_date' => '2026-05-18',
            'guests' => 1,
            'total_price' => 500,
            'status' => 'pending',
            'notes' => null,
        ]);

        $response->assertStatus(422);
        $response->assertJsonValidationErrors(['listing_id']);
    }

    private function createListingContext(): array
    {
        $owner = User::factory()->create([
            'role' => 'owner',
        ]);

        $tenant = User::factory()->create([
            'role' => 'tenant',
        ]);

        $listing = Listing::create([
            'owner_id' => $owner->id,
            'title' => 'Test Room',
            'listing_type' => 'room',
            'description' => 'Test listing for booking availability.',
            'city' => 'Cairo',
            'area' => 'Nasr City',
            'address' => 'Test Address',
            'price' => 500,
            'bedrooms' => 1,
            'bathrooms' => 1,
            'furnished' => false,
            'gender_preference' => 'any',
            'cover_image' => null,
            'status' => 'published',
            'available_from' => '2026-05-01',
            'is_featured' => false,
        ]);

        return [$owner, $tenant, $listing];
    }
}
