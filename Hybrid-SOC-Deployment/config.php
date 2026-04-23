<?php
define('DB_SERVER', 'localhost');
define('DB_USERNAME', 'admin'); 
define('DB_PASSWORD', 'your_password'); 
define('DB_NAME', 'insa_project');

$conn = mysqli_connect(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_NAME);

if($conn === false){
    die("ERROR: Could not connect. " . mysqli_connect_error());
}
?>