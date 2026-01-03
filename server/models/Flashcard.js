const { DataTypes } = require('sequelize');
const sequelize = require('../database');

const Flashcard = sequelize.define('Flashcard', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  question: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  answer: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  difficulty: {
    type: DataTypes.INTEGER, 
    allowNull: false,
  },
  lastModified: {
    type: DataTypes.INTEGER,
    defaultValue: () => Date.now(),
  }
}, {
  timestamps: false 
});

module.exports = Flashcard;