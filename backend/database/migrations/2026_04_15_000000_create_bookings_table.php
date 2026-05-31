<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('bookings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('property_id')->constrained('properties')->cascadeOnDelete();
            $table->date('date_from');
            $table->date('date_to');
            $table->unsignedTinyInteger('guests')->default(1);
            $table->enum('status', ['pending', 'confirmed', 'cancelled', 'paid', 'completed'])->default('pending')->index();
            $table->text('notes')->nullable();
            $table->decimal('total_price', 10, 2);
            $table->timestamps();

            $table->index(['property_id', 'date_from', 'date_to'], 'bookings_property_dates_index');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('bookings');
    }
};
