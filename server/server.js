const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');
const bodyParser = require('body-parser');
const { sequelize, Category, Flashcard } = require('./models');

const app = express();
const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST", "PUT", "DELETE"]
  }
});

const PORT = 3000;

app.use(cors());
app.use(bodyParser.json());

app.use((req, res, next) => {
  console.log(`[API REQUEST] ${req.method} ${req.url}`);
  next();
});

const broadcast = (event, data, socketId) => {
  if (socketId) {
    const socket = io.sockets.sockets.get(socketId);
    if (socket) {
      console.log(`[SOCKET] Broadcasting '${event}' to everyone except ${socketId}`);
      socket.broadcast.emit(event, data);
      return;
    }
  }
  console.log(`[SOCKET] Broadcasting '${event}' to all clients`);
  io.emit(event, data);
};

const error_handling = (req, res, entityType) => {
  const { name, question, answer, difficulty, categoryId } = req.body;
  const isCreate = req.method === 'POST';

  if (entityType === 'category') {
    
    if (!name || typeof name !== 'string' || name.trim() === '') {
      res.status(400).json({ error: 'Field "name" is required and cannot be empty.' });
      return true;
    }
    
    if (name.length > 30) {
      res.status(400).json({ error: 'Field "name" exceeds maximum length of 30 characters.' });
      return true;
    }
  } 
  
  else if (entityType === 'flashcard') {
    
    if (!question || typeof question !== 'string' || question.trim() === '') {
      res.status(400).json({ error: 'Field "question" is required and cannot be empty.' });
      return true;
    }
    if (question.length > 150) {
      res.status(400).json({ error: 'Field "question" exceeds maximum length of 150 characters.' });
      return true;
    }

    if (!answer || typeof answer !== 'string' || answer.trim() === '') {
      res.status(400).json({ error: 'Field "answer" is required and cannot be empty.' });
      return true;
    }
    if (answer.length > 150) {
      res.status(400).json({ error: 'Field "answer" exceeds maximum length of 150 characters.' });
      return true;
    }

    if (isCreate) {
      
      if (difficulty === undefined || typeof difficulty !== 'number' || difficulty < 0 || difficulty > 2) {
        res.status(400).json({ error: 'Field "difficulty" must be an integer between 0 and 2.' });
        return true;
      }
      if (!categoryId) {
        res.status(400).json({ error: 'Field "categoryId" is required.' });
        return true;
      }
    } else {
      
      if (difficulty !== undefined && (typeof difficulty !== 'number' || difficulty < 0 || difficulty > 2)) {
        res.status(400).json({ error: 'Field "difficulty" must be an integer between 0 and 2.' });
        return true;
      }
    }
  }
  
  return false; 
};

app.get('/sync', async (req, res) => {
  try {
    const categories = await Category.findAll();
    const flashcards = await Flashcard.findAll();
    res.json({ categories, flashcards });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/category', async (req, res) => {
  try {
    if (error_handling(req, res, 'category')) return;

    const { name, lastModified } = req.body;
    const socketId = req.headers['x-socket-id'];

    const category = await Category.create({ 
      name: name.trim(), 
      lastModified: lastModified || Date.now() 
    });
    
    broadcast('category_created', category, socketId);
    res.json(category);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/flashcard', async (req, res) => {
  try {
    if (error_handling(req, res, 'flashcard')) return;

    const { question, answer, difficulty, categoryId, lastModified } = req.body;
    const socketId = req.headers['x-socket-id'];

    const category = await Category.findByPk(categoryId);
    if (!category) return res.status(404).json({ error: "Category not found" });

    const flashcard = await Flashcard.create({ 
      question: question.trim(), 
      answer: answer.trim(), 
      difficulty, 
      categoryId, 
      lastModified: lastModified || Date.now() 
    });

    await category.increment('flashcardCount');

    broadcast('flashcard_created', flashcard, socketId);
    res.json(flashcard);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/category/:id', async (req, res) => {
  try {
    if (error_handling(req, res, 'category')) return;

    const { id } = req.params;
    const { name, lastModified } = req.body;
    const socketId = req.headers['x-socket-id'];

    const category = await Category.findByPk(id);
    if (!category) return res.status(404).json({ error: 'Category not found' });

    if (lastModified && lastModified < category.lastModified) {
       console.log(`[CONFLICT] Ignoring update for Category ${id}. Client: ${lastModified}, DB: ${category.lastModified}`);
       return res.json(category);
    }

    category.name = name.trim();
    category.lastModified = lastModified || Date.now();
    await category.save();

    broadcast('category_updated', category, socketId);
    res.json(category);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/flashcard/:id', async (req, res) => {
  try {
    if (error_handling(req, res, 'flashcard')) return;

    const { id } = req.params;
    const { question, answer, difficulty, lastModified } = req.body;
    const socketId = req.headers['x-socket-id'];

    const flashcard = await Flashcard.findByPk(id);
    if (!flashcard) return res.status(404).json({ error: 'Flashcard not found' });

    if (lastModified && lastModified < flashcard.lastModified) {
       console.log(`[CONFLICT] Ignoring update for Flashcard ${id}. Client: ${lastModified}, DB: ${flashcard.lastModified}`);
       return res.json(flashcard);
    }

    flashcard.question = question.trim();
    flashcard.answer = answer.trim();
    if (difficulty !== undefined) flashcard.difficulty = difficulty;
    flashcard.lastModified = lastModified || Date.now();
    await flashcard.save();

    broadcast('flashcard_updated', flashcard, socketId);
    res.json(flashcard);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/category/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const socketId = req.headers['x-socket-id'];

    const count = await Category.destroy({ where: { id } });
    if (count === 0) return res.status(404).json({ error: 'Category not found' });

    broadcast('category_deleted', { id: parseInt(id) }, socketId);
    res.json({ success: true, id: parseInt(id) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/flashcard/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const socketId = req.headers['x-socket-id'];

    const flashcard = await Flashcard.findByPk(id);
    if (!flashcard) return res.status(404).json({ error: 'Flashcard not found' });
    
    const categoryId = flashcard.categoryId;
    await flashcard.destroy();
    
    const category = await Category.findByPk(categoryId);
    if(category) await category.decrement('flashcardCount');

    broadcast('flashcard_deleted', { id: parseInt(id) }, socketId);
    res.json({ success: true, id: parseInt(id) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

sequelize.sync({ force: false }).then(() => {
  console.log('[DB] Database synced.');
  server.listen(PORT, '0.0.0.0', () => {
    console.log(`[SERVER] Running on port ${PORT}`);
  });
}).catch(err => console.error('[DB] Sync failed:', err));