<?php
require_once __DIR__ . "/db.php";

// ✅ cek admin dari DB (role) pakai user_id yang dikirim form-data
require_admin_form($conn);

$name = trim($_POST["name"] ?? "");
if ($name === "") fail("name wajib");

// wajib file image
if (!isset($_FILES["image"]) || $_FILES["image"]["error"] !== UPLOAD_ERR_OK) {
  fail("image wajib diupload");
}

// folder uploads: public_html/uploads
$uploadDir = realpath(__DIR__ . "/../uploads");
if (!$uploadDir) fail("Folder uploads tidak ditemukan", 500);

$ext = strtolower(pathinfo($_FILES["image"]["name"], PATHINFO_EXTENSION));
$allowed = ["jpg","jpeg","png","webp"];
if (!in_array($ext, $allowed)) fail("Format gambar tidak didukung");

$filename = "game_" . time() . "_" . rand(1000,9999) . "." . $ext;
$target = $uploadDir . "/" . $filename;

if (!move_uploaded_file($_FILES["image"]["tmp_name"], $target)) {
  fail("Gagal menyimpan gambar", 500);
}

// url gambar
$scheme = (!empty($_SERVER["HTTPS"]) && $_SERVER["HTTPS"] !== "off") ? "https" : "http";
$host = $_SERVER["HTTP_HOST"];
$image_url = $scheme . "://" . $host . "/uploads/" . $filename;

$stmt = $conn->prepare("INSERT INTO games (name, image_url) VALUES (?, ?)");
$stmt->bind_param("ss", $name, $image_url);

if (!$stmt->execute()) fail("Gagal tambah game", 500);

ok([
  "id" => $conn->insert_id,
  "name" => $name,
  "image_url" => $image_url
]);
