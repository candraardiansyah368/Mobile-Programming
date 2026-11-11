// 1. Buat abstract class Orang
abstract class Orang {
  String nama;
  Orang(this.nama);

  void perkenalan();
}

// 2. Buat class Mahasiswa yang extends Orang
class Mahasiswa extends Orang {
  String nim;
  List<int> nilaiTugas;

  Mahasiswa(String nama, this.nim, this.nilaiTugas) : super(nama);

  @override
  void perkenalan() {
    print("Halo, saya $nama dengan NIM $nim");
  }
}

// 3. Function hitungRataRata menggunakan loop
double hitungRataRata(List<int> nilai) {
  // Melempar exception agar bisa ditangkap oleh try-catch di bawah
  if (nilai.isEmpty) {
    throw Exception("Nilai tugas kosong, tidak bisa dibagi dengan nol.");
  }

  int total = 0;
  for (int i = 0; i < nilai.length; i++) {
    total += nilai[i];
  }
  return total / nilai.length;
}

void main() {
  // 6. Buat minimal 2 objek Mahasiswa
  // Nilai Sinta (90+80)/2 = 85.0
  Mahasiswa mhs1 = Mahasiswa("Sinta", "2201001", [90, 80]);
  // Nilai Budi (65+72)/2 = 68.5
  Mahasiswa mhs2 = Mahasiswa("Budi", "2201002", [65, 72]);
  // Objek ke-3 untuk menguji Exception handling (data kosong)
  Mahasiswa mhs3 = Mahasiswa("Joko", "2201003", []);

  // Memasukkan objek ke dalam list agar mudah dipanggil berulang
  List<Mahasiswa> daftarMahasiswa = [mhs1, mhs2, mhs3];

  for (var mhs in daftarMahasiswa) {
    mhs.perkenalan();

    // 5. Bungkus dengan try-catch
    try {
      double rataRata = hitungRataRata(mhs.nilaiTugas);

      // 4. Conditional expression (Ternary Operator) untuk penentuan predikat
      String predikat = rataRata >= 80
          ? "Sangat Baik"
          : (rataRata >= 60 ? "Baik" : "Perlu Perbaikan");

      print("Rata-rata nilai: $rataRata - Predikat: $predikat\n");
    } catch (e) {
      // Menangkap error jika nilaiTugas kosong (seperti pada data Joko)
      print(
        "Gagal menghitung: ${e.toString().replaceAll('Exception: ', '')}\n",
      );
    }
  }
}
