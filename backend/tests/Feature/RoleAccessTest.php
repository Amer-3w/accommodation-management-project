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

    public function test_owner_can_create_property(): void
    {
        $owner = User::factory()->owner()->create();

        $response = $this->actingAs($owner)->postJson('/api/properties', [
            'title' => 'Owner Listing',
            'price' => 600,
            'location' => 'Cairo - Nasr City',
            'description' => 'Created by the owner account.',
            'rooms' => 1,
            'amenities' => ['wifi', 'furnished'],
            'status' => 'active',
        ]);

        $response->assertStatus(201);
        $response->assertJsonPath('owner.id', $owner->id);
    }

    public function test_user_cannot_create_property(): void
    {
        $user = User::factory()->user()->create();

        $response = $this->actingAs($user)->postJson('/api/properties', [
            'title' => 'User Property',
            'price' => 600,
            'location' => 'Cairo - Nasr City',
            'description' => 'This request should be blocked.',
            'rooms' => 1,
            'amenities' => ['wifi'],
            'status' => 'active',
        ]);

        $response->assertStatus(403);
    }

    public function test_user_can_create_booking(): void
    {
        [$owner, $user, $listing] = $this->createPropertyContext();

        $response = $this->actingAs($user)->postJson('/api/bookings', [
            'property_id' => $listing->id,
            'date_from' => '2026-06-10',
            'date_to' => '2026-06-15',
            'guests' => 2,
            'total_price' => 900,
            'status' => 'pending',
            'notes' => null,
        ]);

        $response->assertStatus(201);
        $response->assertJsonPath('user.id', $user->id);
    }

    public function test_owner_cannot_create_booking(): void
    {
        [$owner, $user, $listing] = $this->createPropertyContext();

        $response = $this->actingAs($owner)->postJson('/api/bookings', [
            'property_id' => $listing->id,
            'date_from' => '2026-06-10',
            'date_to' => '2026-06-15',
            'guests' => 2,
            'total_price' => 900,
            'status' => 'pending',
            'notes' => null,
        ]);

        $response->assertStatus(403);
    }

    public function test_user_can_create_payment_for_own_booking(): void
    {
        [, $user, $listing] = $this->createPropertyContext();

        $booking = Booking::create([
            'user_id' => $user->id,
            'property_id' => $listing->id,
            'date_from' => '2026-06-10',
            'date_to' => '2026-06-15',
            'guests' => 2,
            'total_price' => 900,
            'status' => 'confirmed',
            'notes' => null,
        ]);

        $response = $this->actingAs($user)->postJson('/api/payments', [
            'booking_id' => $booking->id,
            'amount' => 900,
            'method' => 'card',
            'status' => 'paid',
            'reference' => 'TXN-2026-001',
            'paid_at' => '2026-06-09 12:00:00',
            'notes' => null,
        ]);

        $response->assertStatus(201);
        $response->assertJsonPath('booking.id', $booking->id);
    }

    private function createPropertyContext(): array
    {
        $owner = User::factory()->owner()->create();
        $user = User::factory()->user()->create();

        $listing = Listing::create([
            'owner_id' => $owner->id,
            'title' => 'Test Room',
            'price' => 500,
            'location' => 'Cairo - Nasr City',
            'description' => 'Test property for access control.',
            'rooms' => 1,
            'amenities' => ['wifi'],
            'status' => 'active',
        ]);

        return [$owner, $user, $listing];
    }
}
