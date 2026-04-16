<?php

namespace Tests\Feature;

use App\Models\Booking;
use App\Models\Listing;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class RoleAccessTest extends TestCase
{
    use RefreshDatabase;

    public function test_owner_can_create_listing(): void
    {
        $owner = User::factory()->owner()->create();

        $response = $this->actingAs($owner)->postJson('/api/listings', [
            'title' => 'Owner Listing',
            'listing_type' => 'room',
            'description' => 'Created by the owner account.',
            'city' => 'Cairo',
            'area' => 'Nasr City',
            'address' => 'Test Address',
            'price' => 600,
            'bedrooms' => 1,
            'bathrooms' => 1,
            'furnished' => false,
            'gender_preference' => 'any',
            'cover_image' => null,
            'status' => 'published',
            'available_from' => '2026-05-01',
            'is_featured' => false,
        ]);

        $response->assertStatus(201);
        $response->assertJsonPath('owner.id', $owner->id);
    }

    public function test_tenant_cannot_create_listing(): void
    {
        $tenant = User::factory()->tenant()->create();

        $response = $this->actingAs($tenant)->postJson('/api/listings', [
            'title' => 'Tenant Listing',
            'listing_type' => 'room',
            'description' => 'This request should be blocked.',
            'city' => 'Cairo',
            'area' => 'Nasr City',
            'address' => 'Test Address',
            'price' => 600,
            'bedrooms' => 1,
            'bathrooms' => 1,
            'furnished' => false,
            'gender_preference' => 'any',
            'cover_image' => null,
            'status' => 'published',
            'available_from' => '2026-05-01',
            'is_featured' => false,
        ]);

        $response->assertStatus(403);
    }

    public function test_tenant_can_create_booking(): void
    {
        [$owner, $tenant, $listing] = $this->createListingContext();

        $response = $this->actingAs($tenant)->postJson('/api/bookings', [
            'listing_id' => $listing->id,
            'check_in_date' => '2026-06-10',
            'check_out_date' => '2026-06-15',
            'guests' => 2,
            'total_price' => 900,
            'status' => 'pending',
            'notes' => null,
        ]);

        $response->assertStatus(201);
        $response->assertJsonPath('tenant.id', $tenant->id);
    }

    public function test_owner_cannot_create_booking(): void
    {
        [$owner, $tenant, $listing] = $this->createListingContext();

        $response = $this->actingAs($owner)->postJson('/api/bookings', [
            'listing_id' => $listing->id,
            'check_in_date' => '2026-06-10',
            'check_out_date' => '2026-06-15',
            'guests' => 2,
            'total_price' => 900,
            'status' => 'pending',
            'notes' => null,
        ]);

        $response->assertStatus(403);
    }

    public function test_tenant_can_create_payment_for_own_booking(): void
    {
        [, $tenant, $listing] = $this->createListingContext();

        $booking = Booking::create([
            'tenant_id' => $tenant->id,
            'listing_id' => $listing->id,
            'check_in_date' => '2026-06-10',
            'check_out_date' => '2026-06-15',
            'guests' => 2,
            'total_price' => 900,
            'status' => 'confirmed',
            'notes' => null,
        ]);

        $response = $this->actingAs($tenant)->postJson('/api/payments', [
            'booking_id' => $booking->id,
            'amount' => 900,
            'payment_method' => 'card',
            'status' => 'paid',
            'transaction_reference' => 'TXN-2026-001',
            'paid_at' => '2026-06-09 12:00:00',
            'notes' => null,
        ]);

        $response->assertStatus(201);
        $response->assertJsonPath('booking.id', $booking->id);
    }

    private function createListingContext(): array
    {
        $owner = User::factory()->owner()->create();
        $tenant = User::factory()->tenant()->create();

        $listing = Listing::create([
            'owner_id' => $owner->id,
            'title' => 'Test Room',
            'listing_type' => 'room',
            'description' => 'Test listing for access control.',
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
