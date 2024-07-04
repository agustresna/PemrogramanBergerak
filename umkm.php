<?php

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "umkm";
$conn = new mysqli($servername, $username, $password, $dbname);

error_reporting(0);
if ($conn->connect_error) {
    die("Koneksi Gagal: " . $conn->connect_error);
}

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Endpoint untuk mengambil semua data UMKM
    $sql = "SELECT * FROM umkm";
    $result = $conn->query($sql);

    $umkm = [];
    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $umkm[] = $row;
        }
    }

    header('Content-Type: application/json');
    echo json_encode($umkm);
} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Endpoint untuk membuat data UMKM baru
    $data = json_decode(file_get_contents("php://input"));

    $nama_umkm = $data->nama_umkm;
    $nama_pemilik = $data->nama_pemilik;
    $email = $data->email;
    $password = $data->password;
    $nomor_hp = $data->nomor_hp;

    $sql = "INSERT INTO umkm (nama_umkm, nama_pemilik, email, password, nomor_hp) VALUES (?, ?, ?, ?, ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sssss", $nama_umkm, $nama_pemilik, $email, $password, $nomor_hp);
    $stmt->execute();

    $response = [
        'status' => 'success',
        'message' => 'UMKM berhasil ditambahkan!'
    ];
    header('Content-Type: application/json');
    echo json_encode($response);
} elseif ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    // Endpoint untuk mengedit data UMKM
    $data = json_decode(file_get_contents("php://input"));

    $id = $data->id;
    $nama_umkm = $data->nama_umkm;
    $nama_pemilik = $data->nama_pemilik;
    $email = $data->email;
    $password = $data->password;
    $nomor_hp = $data->nomor_hp;

    $sql = "UPDATE umkm SET nama_umkm=?, nama_pemilik=?, email=?, password=?,nomor_hp=? WHERE id=?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sssssi", $nama_umkm, $nama_pemilik, $email, $password, $nomor_hp, $id);
    $stmt->execute();

    $response = [
        'status' => 'success',
        'message' => 'UMKM berhasil diupdate!'
    ];
    header('Content-Type: application/json');
    echo json_encode($response);
} elseif ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    // Endpoint untuk menghapus data UMKM
    $data = json_decode(file_get_contents("php://input"));

    $id = $data->id;

    $sql = "DELETE FROM umkm WHERE id=?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $id);
    $stmt->execute();

    $response = [
        'status' => 'success',
        'message' => 'UMKM berhasil dihapus!'
    ];
    header('Content-Type: application/json');
    echo json_encode($response);
}

$conn->close();
