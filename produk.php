<?php
error_reporting(0);
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "umkm";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Koneksi Gagal: " . $conn->connect_error);
}

// API endpoint untuk CRUD Produk
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    if (isset($_GET['id_umkm'])) {
        $id_umkm = $_GET['id_umkm'];
        $sql = "SELECT * FROM produk WHERE id_umkm = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("i", $id_umkm);
    } else {
        $sql = "SELECT * FROM produk";
        $stmt = $conn->prepare($sql);
    }

    $stmt->execute();
    $result = $stmt->get_result();

    $produk = [];
    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $produk[] = $row;
        }
    }

    header('Content-Type: application/json');
    echo json_encode($produk);
} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents("php://input"), true);

    $id_umkm = $data['id_umkm'];
    $nama_produk = $data['nama_produk'];
    $harga = $data['harga'];
    $stok = $data['stok'];

    $gambar = null;
    if (isset($_FILES['gambar'])) {
        $target_dir = "uploads/";
        $target_file = $target_dir . basename($_FILES["gambar"]["name"]);
        if (move_uploaded_file($_FILES["gambar"]["tmp_name"], $target_file)) {
            $gambar = $target_file;
        }
    }

    $sql = "INSERT INTO produk (id_umkm, nama_produk, harga, stok, gambar) VALUES (?, ?, ?, ?, ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("issis", $id_umkm, $nama_produk, $harga, $stok, $gambar);
    $stmt->execute();

    $response = [
        'status' => 'success',
        'message' => 'Produk berhasil ditambahkan!'
    ];
    header('Content-Type: application/json');
    echo json_encode($response);
} elseif ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    // Endpoint untuk mengedit produk
    $data = json_decode(file_get_contents("php://input"), true);

    $id = $data['id'];
    $id_umkm = $data['id_umkm'];
    $nama_produk = $data['nama_produk'];
    $harga = $data['harga'];
    $stok = $data['stok'];

    $gambar = null;
    if (isset($_FILES['gambar'])) {
        $target_dir = "uploads/";
        $target_file = $target_dir . basename($_FILES["gambar"]["name"]);
        if (move_uploaded_file($_FILES["gambar"]["tmp_name"], $target_file)) {
            $gambar = $target_file;
        }
    }

    if ($gambar) {
        $sql = "UPDATE produk SET id_umkm=?, nama_produk=?, harga=?, stok=?, gambar=? WHERE id=?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("issisi", $id_umkm, $nama_produk, $harga, $stok, $gambar, $id);
    } else {
        $sql = "UPDATE produk SET id_umkm=?, nama_produk=?, harga=?, stok=? WHERE id=?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("issii", $id_umkm, $nama_produk, $harga, $stok, $id);
    }

    $stmt->execute();
    $response = [
        'status' => 'success',
        'message' => 'Produk berhasil diupdate!'
    ];
    header('Content-Type: application/json');
    echo json_encode($response);
} elseif ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    // Endpoint untuk menghapus produk
    $data = json_decode(file_get_contents("php://input"));

    $id = $data->id;

    $sql = "DELETE FROM produk WHERE id=?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $id);
    $stmt->execute();
    $response = [
        'status' => 'success',
        'message' => 'Produk berhasil dihapus!'
    ];
    header('Content-Type: application/json');
    echo json_encode($response);
}

$conn->close();
