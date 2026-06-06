<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_whatsapp_numbers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('country_code', 8);
            $table->string('number', 24);
            $table->timestamps();

            $table->unique(['user_id', 'country_code', 'number'], 'user_whatsapp_numbers_unique');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_whatsapp_numbers');
    }
};
