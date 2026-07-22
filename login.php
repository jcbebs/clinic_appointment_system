<?php
require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/functions.php';

if (!empty($_SESSION['staff'])) {
    header('Location: dashboard.php');
    exit;
}

$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = trim($_POST['username'] ?? '');
    $password = $_POST['password'] ?? '';

    if (attemptStaffLogin($username, $password)) {
        header('Location: dashboard.php');
        exit;
    }
    $error = 'Invalid username or password.';
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Staff Login - <?= e(APP_NAME) ?></title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="../assets/css/style.css">
</head>
<body>
<div class="container login-wrap">
  <div class="card glass">
    <h2 class="section-title" style="text-align:center;">Clinic Staff Login</h2>
    <p style="text-align:center;color:var(--color-text-muted);font-size:0.85rem;margin-top:-8px;">For administrators and the school nurse</p>
    <?php if ($error): ?><div class="alert alert-error"><?= e($error) ?></div><?php endif; ?>
    <form method="POST">
      <label>Username</label>
      <input type="text" name="username" required autofocus>
      <label>Password</label>
      <input type="password" name="password" required>
      <div style="margin-top:20px;"><button type="submit" class="btn btn-primary" style="width:100%;">Log In</button></div>
    </form>
    <p style="text-align:center;margin-top:16px;"><a href="../index.php">&larr; Back to homepage</a></p>
  </div>
</div>
<script src="../assets/js/theme.js"></script>
</body>
</html>
