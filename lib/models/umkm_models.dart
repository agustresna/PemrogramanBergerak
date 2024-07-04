class Umkm {
  final String id;
  final String namaUmkm;
  final String namaPemilik;
  final String email;
  final String password;
  final String nomor;

  Umkm({
    required this.id,
    required this.namaUmkm,
    required this.namaPemilik,
    required this.email,
    required this.password,
    required this.nomor,
  });

  factory Umkm.fromJson(Map<String, dynamic> json) {
    return Umkm(
      id: json['id'],
      namaUmkm: json['nama_umkm'],
      namaPemilik: json['nama_pemilik'],
      email: json['email'],
      password: json['password'],
      nomor: json['nomor_hp'],
    );
  }
}
