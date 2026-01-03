const { Sequelize } = require('sequelize');
const path = require('path');

const sequelize = new Sequelize({
  dialect: 'sqlite',
  storage: path.join(__dirname, 'mindflip.sqlite'),
  logging: (msg) => console.log(`[DB]: ${msg}`),
});

module.exports = sequelize;