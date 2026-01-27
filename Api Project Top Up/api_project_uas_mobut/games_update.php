<?php
require_once __DIR__ . "/db.php";
require_once __DIR__ . "/admin_key.php";

$admin_key = trim($_POST["admin_key"] ?? "");
if ($admin_key !== ADMIN_KEY) fail("Admin only", 403);

$id = (int)($_POST["id"] ?? 0);
$name = trim($_POST["name"] ?? "");

if ($id <= 0) fail("id wajib");
if ($name === "") fail("name wajib");

// ambil current image_url
$cur = $conn->prepare("SELECT image_url FROM games WHERE id=? LIMIT 1");
$cur->bind_param("i", $id);
$cur->execute();
$res = $cur->get_result();
$row = $res->fetch_assoc();
if (!$row) fail("Game tidak ditemukan", 404);

$image_url = $row["image_url"];

// kalau ada image baru → upload
if (isset($_FILES["image"]) && $_FILES["image"]["error"] === UPLOAD_ERR_OK) {
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

  $scheme = (!empty($_SERVER["HTTPS"]) && $_SERVER["HTTPS"] !== "off") ? "https" : "http";
  $host = $_SERVER["HTTP_HOST"];
  $image_url = $scheme . "://" . $host . "/uploads/" . $filename;
}

$stmt = $conn->prepare("UPDATE games SET name=?, image_url=? WHERE id=?");
$stmt->bind_param("ssi", $name, $image_url, $id);

if (!$stmt->execute()) fail("Gagal update game", 500);

ok([
  "id" => $id,
  "name" => $name,
  "image_url" => $image_url
]);
