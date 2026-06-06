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
            $table->text('notes')->nullable();
            $table->decimal('base_price', 10, 2)->default(0);
            $table->string('price_period', 16)->default('month');
            $table->unsignedInteger('number_of_days')->default(1);
            $table->decimal('base_total', 10, 2)->default(0);
            $table->decimal('discount_percent', 5, 2)->default(0);
            $table->decimal('discount_amount', 10, 2)->default(0);
            $table->decimal('service_fee', 10, 2)->default(50);
            $table->decimal('security_deposit', 10, 2)->default(0);
            $table->decimal('final_total', 10, 2)->default(0);
            $table->enum('status', ['pending', 'approved', 'rejected', 'cancelled', 'completed', 'paid', 'confirmed'])->default('pending')->index();
            $table->timestamps();

            $table->index(['property_id', 'date_from', 'date_to'], 'bookings_property_dates_index');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('bookings');
    }
};
