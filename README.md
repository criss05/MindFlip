# 📱 MindFlip Mobile Application

---

## 📝 Project Description
The *MindFlip* app is a mobile application designed to help students and learners organize, practice, and retain study materials using digital flashcards. Users can create personalized *categories*, such as *Algebra*, *Databases*, or *History*. Within each category, users can add *flashcards* containing a **question**, an **answer**, and a **difficulty level** (*Easy, Medium, Hard*).  

The app provides full support for *CRUD operations* (Create, Read, Update, Delete), allowing users to add new categories and flashcards, view and edit existing content, and remove items when no longer needed. Categories automatically track the number of flashcards they contain, giving learners a clear overview of their study materials.  

A key feature of MindFlip is its ability to function *offline*: all changes are stored locally and persist across app restarts. When an internet connection is available, the app synchronizes automatically with a **remote server**, ensuring that user progress and study data are securely backed up and consistent across devices. This combination of offline reliability and online synchronization makes MindFlip an effective and flexible tool for learning anytime, anywhere.

---

## 🧠 Domain Details

### Entity 1: *Category*
| Field             | Description |
|------------------ |------------ |
| *id*              | Unique identifier (auto-generated). |
| *name*            | Category title (e.g., Algebra, Databases). |
| *flashcard_count* | Number of flashcards in this category. |

---

### Entity 2: *Flashcard*
| Field        | Description |
|------------- |------------ |
| *id*         | Unique identifier (auto-generated). |
| *question*   | The question text. |
| *answer*     | The answer text. |
| *difficulty* | One of *Easy, Medium, Hard*. |
| *category_id*| The category the flashcard belongs to. |

---

## ⚙️ CRUD Operations

### Category-Related
- *Create:* Add a new category from the main screen.
- *Read:* View all categories with their flashcard counts.
- *Update:* Edit the category name.
- *Delete:* Remove a category and all flashcards it contains.

---

### Flashcard-Related
- *Create:* Add a new flashcard (question, answer, difficulty).
- *Read:* Display all flashcards inside a category.
- *Update:* Modify the question, answer, difficulty or category.
- *Delete:* Remove a flashcard and update the category’s flashcard count.

---

## 💾 Persistence & Synchronization

### Local Database
- Stores the categories and flashcards.
- Operations survive restarts and are queued if offline.

### Remote Server (REST API)
- Stores the same entities for synchronization.



*Endpoints:*
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET    | /categories | Retrieve all categories. |
| POST   | /categories | Create a new category. |
| PUT    | /categories/{id} | Update a category. |
| DELETE | /categories/{id} | Delete a category. |
| GET    | /categories/{id}/flashcards | Retrieve all flashcards in a category. |
| POST   | /flashcards | Create a new flashcard. |
| PUT    | /flashcards/{id} | Update a flashcard. |
| DELETE | /flashcards/{id} | Delete a flashcard. |

---

## 🌐 Offline Behavior

The application is fully functional offline, with all changes queued locally and synchronized automatically once the device reconnects.

### 🔹 *Create (Category/Flashcard)*
- Created locally with a **temporary id** and marked as **pending sync**.
- On reconnect, new items are sent to the server, and server IDs replace local temporary IDs.

### 🔹 *Read (Categories/Flashcards)*
- Displays data from the local database.
- Shows a banner: *“Offline mode: Content may not be up-to-date”*

### 🔹 *Update (Edit Category/Flashcard)*
- Edits are saved locally and marked as **pending sync**.
- Once online, updates are pushed to the server.

### 🔹 *Delete (Category/Flashcard)*
- Deleted locally, hidden from the interface and marked as **pending sync** and **deleted**.
- Once online, delete request is sent to the server.

---

## 🧭 App Screens

1. **🏠 Main Screen (Categories)**

2. **📑 Category View**

3. **✏️ Add / Edit Flashcard**

4. **🎯 Practice Mode**

5. **📶 Offline Mode Banner**

---

*Author:* Cristiana Bărnuț  
*Course:* Mobile Applications  
*Project:* MindFlip App
