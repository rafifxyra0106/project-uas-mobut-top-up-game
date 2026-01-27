<?php
require_once __DIR__ . "/config.php";

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
  http_response_code(200);
  exit;
}

// jangan tampilkan error HTML ke client (biar JSON aman)
error_reporting(E_ALL);
ini_set('display_errors', 0);

$conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
if ($conn->connect_error) {
  http_response_code(500);
  echo json_encode(["success" => false, "message" => "DB connection failed"]);
  exit;
}
$conn->set_charset("utf8mb4");

// helper response
function ok($data) {
  echo json_encode(["success" => true, "data" => $data]);
  exit;
}

function fail($msg, $code = 400) {
  http_response_code($code);
  echo json_encode(["success" => false, "message" => $msg]);
  exit;
}

// ambil JSON body
function body_json() {
  $raw = file_get_contents("php://input");
  $data = json_decode($raw, true);
  return is_array($data) ? $data : [];
}
function require_admin_form($conn) {
  $user_id = (int)($_POST["user_id"] ?? 0);
  if ($user_id <= 0) fail("user_id wajib", 401);

  $q = $conn->prepare("SELECT role FROM users WHERE id=? LIMIT 1");
  $q->bind_param("i", $user_id);
  $q->execute();
  $res = $q->get_result();
  $u = $res->fetch_assoc();

  if (!$u) fail("User tidak ditemukan", 401);
  if (($u["role"] ?? "user") !== "admin") fail("Admin only", 403);

  return $user_id;
}
