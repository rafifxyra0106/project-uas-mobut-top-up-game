<?php
require_once __DIR__ . "/db.php";

// admin_key dikirim via multipart POST
$admin_key = $_POST["admin_key"] ?? "";
if ($admin_key !== ADMIN_KEY) fail("Unauthorized (admin only)", 401);

if (!isset($_FILES["image"])) fail("File 'image' wajib", 400);

$err = $_FILES["image"]["error"];
if ($err !== UPLOAD_ERR_OK) fail("Upload error: " . $err, 400);

// validasi tipe file
$allowed = [
  "image/jpeg" => "jpg",
  "image/png"  => "png",
  "image/webp" => "webp"
];

$tmp = $_FILES["image"]["tmp_name"];
$mime = mime_content_type($tmp);
if (!isset($allowed[$mime])) fail("Format harus jpg/png/webp", 400);

$ext = $allowed[$mime];

// ✅ Folder upload: public_html/uploads
// Lokasi file ini ada di: public_html/api_project_uas_mobut/
// Jadi naik 1 level -> public_html/, lalu masuk uploads/
$uploadDir = __DIR__ . "/../uploads/";
if (!is_dir($uploadDir)) {
  @mkdir($uploadDir, 0755, true);
}
if (!is_dir($uploadDir)) fail("Folder upload tidak ditemukan: public_html/uploads", 500);

$filename = "game_" . time() . "_" . bin2hex(random_bytes(4)) . "." . $ext;
$target = $uploadDir . $filename;

if (!move_uploaded_file($tmp, $target)) {
  fail("Gagal menyimpan file", 500);
}

// URL publik
$base = "https://" . $_SERVER["HTTP_HOST"];
$imageUrl = $base . "/uploads/" . $filename;

ok([
  "image_url" => $imageUrl,
  "filename" => $filename
]);
