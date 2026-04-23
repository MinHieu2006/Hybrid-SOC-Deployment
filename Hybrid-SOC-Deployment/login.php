<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>STI Project Login</title>
    <style>
        body { font-family: Arial; display: flex; justify-content: center; align-items: center; height: 100vh; background: #f0f2f5; }
        form { background: white; padding: 2rem; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
        input { display: block; width: 100%; margin-bottom: 1rem; padding: 0.5rem; }
        button { width: 100%; padding: 0.5rem; background: #007bff; color: white; border: none; cursor: pointer; }
    </style>
</head>
<body>
    <form action="authenticate.php" method="POST">
        <h2>System Login</h2>
        <input type="text" name="username" placeholder="Username" required>
        <input type="password" name="password" placeholder="Password" required>
        <button type="submit">Login</button>
    </form>
</body>
</html>