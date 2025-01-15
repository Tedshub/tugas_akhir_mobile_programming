const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const bodyParser = require('body-parser');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const upload = multer({ dest: './uploads/' });

// Setup Express app
const app = express();
const port = 5000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use('/uploads', express.static('uploads'));

// MySQL connection
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'flutter_api' // Nnama database
});

db.connect(err => {
  if (err) throw err;
  console.log('Connected to MySQL!');
});

// Endpoint untuk mengambil data profil berdasarkan ID
app.get('/profile/:id', (req, res) => {
  const { id } = req.params;
  const query = 'SELECT * FROM users WHERE id = ?';

  console.log(`Fetching profile for user with ID: ${id}`);

  db.query(query, [id], (err, result) => {
    if (err) {
      return res.status(500).json({ message: 'Error fetching profile', error: err });
    }
    if (result.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Mengirimkan data profil pengguna
    res.json(result[0]);
  });
});

// Endpoint untuk memperbarui profil pengguna berdasarkan ID
app.put('/profile/:id/update', (req, res) => {
  const { id } = req.params;
  const { profile } = req.body;

  // Logging untuk debugging
  console.log('Request received for ID:', id);
  console.log('Request body:', req.body);
  console.log('Profile URL to be updated:', profile);

  // Validasi input
  if (!profile) {
    console.log('Profile URL is missing');
    return res.status(400).json({ message: 'Profile URL is required' });
  }

  const query = 'UPDATE users SET profile = ? WHERE id = ?';
  console.log('Executing query:', query);
  console.log('Query parameters:', [profile, id]);

  db.query(query, [profile, id], (err, result) => {
    if (err) {
      console.error('MySQL Error:', err);
      return res.status(500).json({ message: 'Failed to update profile', error: err });
    }

    console.log('MySQL Result:', result);

    if (result.affectedRows === 0) {
      console.log('No rows affected - user not found');
      return res.status(404).json({ message: 'User not found' });
    }

    console.log('Profile updated successfully');
    res.status(200).json({
      message: 'Profile updated successfully',
      affectedRows: result.affectedRows
    });
  });
});

// Register route
app.post('/register', (req, res) => {
  const { email, username, password } = req.body;

  // Cek apakah email atau username sudah ada
  const checkQuery = 'SELECT * FROM users WHERE email = ? OR username = ?';
  db.query(checkQuery, [email, username], (err, result) => {
    if (err) throw err;

    if (result.length > 0) {
      return res.status(400).json({ message: 'Username or Email is already taken' });
    }

    // Jika tidak ada, lanjutkan proses registrasi
    bcrypt.hash(password, 10, (err, hashedPassword) => {
      if (err) throw err;
      const query = 'INSERT INTO users (email, username, password) VALUES (?, ?, ?)';
      db.query(query, [email, username, hashedPassword], (err, result) => {
        if (err) throw err;
        res.json({ message: 'User registered successfully!' });
      });
    });
  });
});

// Login route
app.post('/login', (req, res) => {
  const { username, password } = req.body;
  const query = 'SELECT * FROM users WHERE username = ?';
  db.query(query, [username], (err, result) => {
    if (err) throw err;
    if (result.length > 0) {
      bcrypt.compare(password, result[0].password, (err, match) => {
        if (match) {
          const token = jwt.sign({ userId: result[0].id }, 'f1utt3r4p1m0b1l3');
          res.json({ message: 'Login successful', token });
        } else {
          res.status(400).json({ message: 'Invalid username/password' });
        }
      });
    } else {
      res.status(400).json({ message: 'User not found' });
    }
  });
});

// Fetch content route
app.get('/content', (req, res) => {
  const query = 'SELECT * FROM content';
  db.query(query, (err, result) => {
    if (err) throw err;
    res.json(result);
  });
});

// Endpoint untuk menambahkan konten baru
app.post('/content', (req, res) => {
  const { image_item, item_name, description } = req.body;

  // Logging untuk memastikan data terekstrak dengan benar
  console.log('Received data:', { image_item, item_name, description });

  // Validasi input
  if (!image_item || !item_name || !description) {
    return res.status(400).json({
      message: 'All fields are required',
      receivedData: { image_item, item_name, description }
    });
  }

  // Validasi URL image
  const urlPattern = /^(http(s)?:\/\/)?([a-zA-Z0-9-]+\.)+[a-zA-Z0-9]{2,4}(\/[^\s]*)?$/;
  if (!urlPattern.test(image_item)) {
    return res.status(400).json({
      message: 'Invalid image URL format',
      receivedData: { image_item, item_name, description }
    });
  }

  const query = 'INSERT INTO content (image_item, item_name, description) VALUES (?, ?, ?)';

  db.query(query, [image_item, item_name, description], (err, result) => {
    if (err) {
      return res.status(500).json({
        message: 'Failed to add content',
        error: err.message,
        sqlMessage: err.sqlMessage
      });
    }

    res.status(200).json({
      message: 'Content added successfully',
      id: result.insertId,
      content: {
        image_item,
        item_name,
        description
      }
    });
  });
});

// Fetch content by ID route
app.get('/content/:id', (req, res) => {
  const { id } = req.params;
  const query = 'SELECT * FROM content WHERE id_item = ?';

  db.query(query, [id], (err, result) => {
    if (err) {
      return res.status(500).json({ message: 'Error fetching content detail', error: err });
    }
    if (result.length === 0) {
      return res.status(404).json({ message: 'Content not found' });
    }

    res.json(result[0]);
  });
});

// Endpoint untuk memperbarui konten berdasarkan ID
app.put('/content/:id_item', (req, res) => {
  const { id_item } = req.params;
  const { image_item, item_name, description } = req.body;

  // Validasi input
  if (!image_item || !item_name || !description) {
    return res.status(400).json({
      message: 'All fields are required',
      receivedData: { image_item, item_name, description }
    });
  }

  const query = 'UPDATE content SET image_item = ?, item_name = ?, description = ? WHERE id_item = ?';

  db.query(query, [image_item, item_name, description, id_item], (err, result) => {
    if (err) {
      return res.status(500).json({ message: 'Failed to update content', error: err });
    }
    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Content not found' });
    }
    res.status(200).json({ message: 'Content updated successfully' });
  });
});

// Endpoint untuk menghapus konten berdasarkan ID
app.delete('/content/:id', (req, res) => {
  const { id } = req.params;
  const query = 'DELETE FROM content WHERE id_item = ?';
  db.query(query, [id], (err, result) => {
    if (err) {
      return res.status(500).json({ message: 'Failed to delete content', error: err });
    }
    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Content not found' });
    }
    res.status(200).json({ message: 'Content deleted successfully' });
  });
});

// Start server
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
