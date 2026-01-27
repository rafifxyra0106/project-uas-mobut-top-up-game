<?php
require_once __DIR__ . "/db.php";

$data = body_json();
$name = trim($data["name"] ?? "");
$username = trim($data["username"] ?? "");
$email = trim($data["email"] ?? "");
$password = $data["password"] ?? "";

if ($name === "" || $username === "" || $email === "" || $password === "") {
  fail("name, username, email, password wajib");
}

if (!preg_match('/^[a-zA-Z0-9_]{3,20}$/', $username)) {
  fail("username hanya huruf/angka/_ dan 3-20 karakter");
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
  fail("format email tidak valid");
}

if (strlen($password) < 6) {
  fail("password minimal 6 karakter");
}

$check = $conn->prepare("SELECT id FROM users WHERE username=? OR email=? LIMIT 1");
$check->bind_param("ss", $username, $email);
$check->execute();
$res = $check->get_result();
if ($res->fetch_assoc()) fail("username atau email sudah dipakai", 409);

$hash = password_hash($password, PASSWORD_BCRYPT);

$stmt = $conn->prepare("INSERT INTO users (name, username, email, password_hash, role) VALUES (?, ?, ?, ?, 'user')");
$stmt->bind_param("ssss", $name, $username, $email, $hash);

if (!$stmt->execute()) fail("Gagal register", 500);

ok([
  "id" => $conn->insert_id,
  "name" => $name,
  "username" => $username,
  "email" => $email,
  "role" => "user"
]);
