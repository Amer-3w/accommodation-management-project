<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_register_and_receive_token(): void
    {
        $response = $this->postJson('/api/auth/register', [
            'name' => 'New Tenant',
            'email' => 'tenant@example.com',
            'phone' => '01000000001',
            'role' => 'tenant',
            'password' => 'password123',
            'password_confirmation' => 'password123',
        ]);

        $response->assertStatus(201);
        $response->assertJsonStructure([
            'user' => ['id', 'name', 'email', 'role'],
            'token',
            'token_type',
        ]);
        $response->assertJsonPath('user.role', 'tenant');
        $response->assertJsonPath('token_type', 'Bearer');
    }

    public function test_user_can_login_and_access_protected_route(): void
    {
        $user = User::factory()->tenant()->create([
            'password' => 'password',
        ]);

        $loginResponse = $this->postJson('/api/auth/login', [
            'email' => $user->email,
            'password' => 'password',
        ]);

        $loginResponse->assertStatus(200);
        $loginResponse->assertJsonStructure([
            'user' => ['id', 'name', 'email', 'role'],
            'token',
            'token_type',
        ]);

        $token = $loginResponse->json('token');

        $meResponse = $this->withHeader('Authorization', 'Bearer ' . $token)->getJson('/api/auth/me');

        $meResponse->assertStatus(200);
        $meResponse->assertJsonPath('email', $user->email);

        $bookingsResponse = $this->withHeader('Authorization', 'Bearer ' . $token)->getJson('/api/bookings');

        $bookingsResponse->assertStatus(200);
    }

    public function test_user_can_logout_and_revoke_token(): void
    {
        $user = User::factory()->tenant()->create([
            'password' => 'password',
        ]);

        $loginResponse = $this->postJson('/api/auth/login', [
            'email' => $user->email,
            'password' => 'password',
        ]);

        $token = $loginResponse->json('token');

        $logoutResponse = $this->withHeader('Authorization', 'Bearer ' . $token)->postJson('/api/auth/logout');

        $logoutResponse->assertStatus(200);

        $meResponse = $this->withHeader('Authorization', 'Bearer ' . $token)->getJson('/api/auth/me');

        $meResponse->assertStatus(401);
    }
}
