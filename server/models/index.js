
const sequelize = require('../database');
const Category = require('./Category');
const Flashcard = require('./Flashcard');


Category.hasMany(Flashcard, { foreignKey: 'categoryId', onDelete: 'CASCADE' });
Flashcard.belongsTo(Category, { foreignKey: 'categoryId' });

module.exports = {
  sequelize,
  Category,
  Flashcard,
};