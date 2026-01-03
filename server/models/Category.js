const { DataTypes } = require('sequelize');
const sequelize = require('../database');

const Category = sequelize.define('Category', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  flashcardCount: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  lastModified: {
    type: DataTypes.INTEGER,
    defaultValue: () => Date.now(), 
  }
}, {
  timestamps: false 
});

module.exports = Category;