<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('properties', function (Blueprint $table) {
            $table->id();
            $table->foreignId('owner_id')->constrained('users')->cascadeOnDelete();
            $table->string('title');
            $table->decimal('price', 10, 2);
            $table->enum('price_duration', ['day', 'week', 'month'])->default('month');
            $table->unsignedSmallInteger('stay_duration')->default(1);
            $table->decimal('weekly_discount', 5, 2)->default(10);
            $table->decimal('monthly_discount', 5, 2)->default(20);
            $table->decimal('long_stay_discount', 5, 2)->default(25);
            $table->string('location')->index();
            $table->text('description');
            $table->unsignedTinyInteger('rooms')->default(1);
            $table->unsignedTinyInteger('bathrooms')->default(1);
            $table->string('property_type', 60)->nullable();
            $table->string('governorate')->nullable();
            $table->string('city')->nullable();
            $table->string('university')->nullable();
            $table->string('address')->nullable();
            $table->decimal('latitude', 10, 7)->nullable();
            $table->decimal('longitude', 10, 7)->nullable();
            $table->json('amenities')->nullable();
            $table->json('rules')->nullable();
            $table->json('availability')->nullable();
            $table->string('contact_email')->nullable();
            $table->string('contact_whatsapp_country_code', 8)->nullable();
            $table->string('contact_whatsapp_number', 24)->nullable();
            $table->enum('contact_type', ['email', 'whatsapp', 'both'])->default('email');
            $table->enum('status', ['draft', 'active', 'archived'])->default('active')->index();
            $table->timestamps();

            $table->index(['price', 'rooms']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('properties');
    }
};
