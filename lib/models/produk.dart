class Produk {
  final int id;
  final int idUmkm;
  final String namaProduk;
  final String harga;
  final int stok;

  Produk({
    required this.id,
    required this.idUmkm,
    required this.namaProduk,
    required this.harga,
    required this.stok,
  });

  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      id: json['id'] ?? 0,
      idUmkm: json['id_umkm'] ?? 0,
      namaProduk: json['nama_produk'] ?? '',
      harga: json['harga'] ?? '0',
      stok: json['stok'] ?? 0,
    );
  }
}
