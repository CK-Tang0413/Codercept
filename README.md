# Codercept - E-Learning Platform

Welcome to the repository for **Codercept**, a web-based learning platform tailored for programming education. 

## 🚀 Tech Stack
* **Frontend:** HTML, CSS, JavaScript (Custom Responsive Design)
* **Backend:** ASP.NET Web Forms (C#)
* **Database:** Microsoft SQL Server (LocalDB)

---

## 📥 Getting Started

Follow these steps to clone the repository and get the project running on your local machine.

### 1. Clone the Repository
Open your terminal or Developer Command Prompt and run:
```bash
git clone https://github.com/CK-Tang0413/Codercept.git
```

### 2. Open the Project
1. Launch **Visual Studio**.
2. Click **Open a project or solution**.
3. Navigate to your cloned folder and open the `Codercept.sln` file.
4. *Note: The default launch page is configured to `signIn.aspx`.*

---

## 🗄️ Database Setup (Crucial for All Teammates)

To prevent Git merge conflicts, we **do not track or share** the raw `.mdf` and `.ldf` database files in this repository. Instead, we use a master SQL script to synchronize the database schema and mock data across the team.

### Initial Setup (First Time Only)
If this is your first time pulling the project, you must set up your local database:

1. **Create the Local Database File:**
   * In Visual Studio's Solution Explorer, right-click the `App_Data` folder.
   * Select **Add** > **New Item...**
   * Choose **SQL Server Database** and name it exactly **`Codercept_db.mdf`**.
2. **Execute the Master Setup Script:**
   * Go to **View** > **SQL Server Object Explorer**.
   * Expand **SQL Server** > **(localdb)\MSSQLLocalDB** > **Databases**.
   * Right-click `Codercept_db` (or its full file path) and select **New Query**.
   * Open the `Database/database_setup.sql` file from the Solution Explorer, copy all the code, and paste it into the New Query window.
   * Click the green **Execute** button (Play icon) or press `Ctrl + Shift + E`.
   * *Check the Messages pane to ensure "Commands completed successfully." Your tables and mock data are now perfectly synced!*

---

## 🔄 Updating the Database in the Future

The `database_setup.sql` script uses `DROP TABLE IF EXISTS` commands. This means it safely wipes the old tables and cleanly rebuilds them with the latest data every time it is run.

**When you need to make a database change (e.g., adding a column):**
1. Do not attempt to push your local `.mdf` file.
2. Open `Database/database_setup.sql` in Visual Studio.
3. Manually type your new column or table into the existing `CREATE TABLE` statements.
4. Commit and push the updated `database_setup.sql` file to GitHub.

**When pulling someone else's database updates:**
1. Pull the latest code from the GitHub repository.
2. Open a **New Query** window for your local `Codercept_db` via the SQL Server Object Explorer.
3. Paste the contents of the newly pulled `Database/database_setup.sql` and click **Execute**.
4. *Your local database is instantly refreshed to match the team's latest schema without causing Git conflicts.*

---

## 🤝 Collaboration Guidelines

When coordinating on GitHub repository branches and managing code merges with Ian and the rest of the development team, ensure that any backend C# logic that relies on newly added database columns is pushed in the exact same commit as the updated `database_setup.sql` file. This guarantees that the project compiles and runs smoothly for everyone immediately upon pulling.
