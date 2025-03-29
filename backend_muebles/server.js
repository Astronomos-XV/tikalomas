const express = require('express');
const { Pool } = require('pg');
const app = express();
const port = 3000;

// Conexion SQL
const pool = new Pool({
    host: 'localhost',
    port: 5432,
    database: 'app_muebles',
    user: 'postgres',
    password: 'admin',
});

// Metodo de creacion de tabla sino existe
async function initializeDatabase() {
    try {
        console.log('Verificando si la tabla "muebles" existe...');
        const tableCheckQuery = `
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'muebles'
      );
    `;
        const result = await pool.query(tableCheckQuery);
        const tableExists = result.rows[0].exists;

        if (!tableExists) {
            console.log('La tabla "muebles" no existe. Creándola...');
            const createTableQuery = `
        CREATE TABLE muebles (
          id SERIAL PRIMARY KEY,
          nombre VARCHAR(255) NOT NULL,
          tipo VARCHAR(100) NOT NULL,
          estado VARCHAR(100) NOT NULL
        );
      `;
            await pool.query(createTableQuery);
            console.log('Tabla "muebles" creada exitosamente.');
        } else {
            console.log('La tabla "muebles" ya existe.');
        }
    } catch (err) {
        console.error('Error al inicializar la base de datos:', err.stack);
    }
}

// Prueba de conexion
pool.connect((err, client, release) => {
    if (err) {
        console.error('Error al conectar a PostgreSQL:', err.stack);
        return;
    }
    console.log('Conexión a PostgreSQL exitosa');
    release();

    initializeDatabase();
});

// Parsear JSON
app.use(express.json());

// Habilitar CORS
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
    res.header('Access-Control-Allow-Headers', 'Content-Type');
    next();
});

// Muestra la informacion de la tabla muebles
app.get('/muebles', async (req, res) => {
    try {
        console.log('Intentando obtener los muebles...');
        const result = await pool.query('SELECT * FROM muebles');
        console.log('Muebles obtenidos:', result.rows);
        res.json(result.rows);
    } catch (err) {
        console.error('Error al obtener los muebles:', err.stack);
        res.status(500).json({ error: 'Error al obtener los muebles', details: err.message });
    }
});

// Para agregar un mueble
app.post('/muebles', async (req, res) => {
    const { nombre, tipo, estado } = req.body;
    try {
        console.log('Intentando agregar un mueble:', { nombre, tipo, estado });
        const result = await pool.query(
            'INSERT INTO muebles (nombre, tipo, estado) VALUES ($1, $2, $3) RETURNING *',
            [nombre, tipo, estado]
        );
        console.log('Mueble agregado:', result.rows[0]);
        res.json(result.rows[0]);
    } catch (err) {
        console.error('Error al agregar el mueble:', err.stack);
        res.status(500).json({ error: 'Error al agregar el mueble', details: err.message });
    }
});

// Para actualizar un mueble
app.put('/muebles/:id', async (req, res) => {
    const { id } = req.params;
    const { nombre, tipo, estado } = req.body;
    try {
        console.log('Intentando actualizar el mueble con ID:', id);
        const result = await pool.query(
            'UPDATE muebles SET nombre = $1, tipo = $2, estado = $3 WHERE id = $4 RETURNING *',
            [nombre, tipo, estado, id]
        );
        console.log('Mueble actualizado:', result.rows[0]);
        res.json(result.rows[0]);
    } catch (err) {
        console.error('Error al actualizar el mueble:', err.stack);
        res.status(500).json({ error: 'Error al actualizar el mueble', details: err.message });
    }
});

// Para eliminar un mueble
app.delete('/muebles/:id', async (req, res) => {
    const { id } = req.params;
    try {
        console.log('Intentando eliminar el mueble con ID:', id);
        await pool.query('DELETE FROM muebles WHERE id = $1', [id]);
        console.log('Mueble eliminado con ID:', id);
        res.json({ message: 'Mueble eliminado' });
    } catch (err) {
        console.error('Error al eliminar el mueble:', err.stack);
        res.status(500).json({ error: 'Error al eliminar el mueble', details: err.message });
    }
});

// Inicializa el server(API)
app.listen(port, () => {
    console.log(`Servidor corriendo en http://localhost:${port}`);
});