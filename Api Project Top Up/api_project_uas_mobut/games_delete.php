<?php
require_once __DIR__ . "/db.php";
require_once __DIR__ . "/admin_key.php";

$data = body_json();
$admin_key = trim($data["admin_key"] ?? "");
if ($admin_key !== ADMIN_KEY) fail("Admin only", 403);

$id = (int)($data["id"] ?? 0);
if ($id <= 0) fail("id wajib");

$stmt = $conn->prepare("DELETE FROM games WHERE id=?");
$stmt->bind_param("i", $id);

if (!$stmt->execute()) fail("Gagal hapus game", 500);

ok(["deleted" => true, "id" => $id]);
