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

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents("php://input"));

    $email = $data->email;
    $password = $data->password;

    $sql = "SELECT * FROM umkm WHERE email=? AND password=?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ss", $email, $password);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $response = [
            'status' => 'success',
            'message' => 'Login berhasil!',
            'user_id' => $row['id'],
            'nama_umkm' => $row['nama_umkm'],
            'nama_pemilik' => $row['nama_pemilik'],
            'email' => $row['email'],

        ];
    } else {
        $response = [
            'status' => 'error',
            'message' => 'Email atau password salah.'
        ];
    }

    header('Content-Type: application/json');
    echo json_encode($response);
}

$conn->close();
