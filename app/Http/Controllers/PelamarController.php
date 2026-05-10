<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\DB;

class PelamarController extends Controller
{
    public function showForm()
    {
        return view('pelamar.form');
    }

    public function submitForm(Request $request)
    {
        // Validasi input
        $request->validate([
            'nama' => 'required|string|max:255',
            'email' => 'required|email',
            'ktp' => 'required|image|mimes:jpeg,png,jpg|max:5120', // Maks 5MB
        ]);

        // 1. Mengunggah File ke Object Storage (S3) [cite: 21]
        if ($request->hasFile('ktp')) {
            $file = $request->file('ktp');
            $path = $file->store('berkas_ktp', 's3');
            
            // Mendapatkan URL Publik secara otomatis [cite: 22]
            $urlKtp = Storage::disk('s3')->url($path); 

            // 2. Menyimpan Teks & URL ke Database (RDS) [cite: 23]
            DB::table('pelamars')->insert([
                'nama' => $request->nama,
                'email' => $request->email,
                'ktp_url' => $urlKtp,
            ]);

            return back()->with('success', 'Pendaftaran berhasil! URL KTP: ' . $urlKtp);
        }

        return back()->with('error', 'Gagal mengunggah KTP.');
    }
}