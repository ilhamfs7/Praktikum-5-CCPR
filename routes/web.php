<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\PelamarController; // Wajib di-import agar router mengenali controller

Route::get('/', function () {
    return view('welcome');
});

// Menampilkan halaman form pendaftaran
Route::get('/daftar', [PelamarController::class, 'showForm']);

// Menangkap data yang dikirim dari form (tombol submit)
Route::post('/daftar', [PelamarController::class, 'submitForm']);