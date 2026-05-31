<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        User::factory()->admin()->create([
            'name' => 'System Admin',
            'email' => 'admin@example.com',
        ]);

        User::factory()->owner()->create([
            'name' => 'Property Owner',
            'email' => 'owner@example.com',
        ]);

        User::factory()->user()->create([
            'name' => 'App User',
            'email' => 'user@example.com',
        ]);
    }
}
