<?php
require_once __DIR__ . "/db.php";

$data = body_json();

$login = trim($data["login"] ?? "");
$password = $data["password"] ?? "";

if ($login === "" || $password === "") {
  fail("Username/Email dan password wajib diisi");
}

$stmt = $conn->prepare("
  SELECT id, name, username, email, role, password_hash
  FROM users
  WHERE username = ? OR email = ?
  LIMIT 1
");
$stmt->bind_param("ss", $login, $login);
$stmt->execute();
$res = $stmt->get_result();
$user = $res->fetch_assoc();

if (!$user) fail("User tidak ditemukan", 401);

if (!password_verify($password, $user["password_hash"])) {
  fail("Password salah", 401);
}

$token = base64_encode($user["id"] . "|" . $user["email"] . "|" . time());

ok([
  "user" => [
    "id" => (int)$user["id"],
    "name" => $user["name"],
    "username" => $user["username"],
    "email" => $user["email"],
    "role" => $user["role"] ?? "user",
  ],
  "token" => $token
]);
