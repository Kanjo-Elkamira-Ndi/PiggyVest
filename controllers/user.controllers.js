import pool from '../config/database.js'; 
import { extractTokenInfo } from '../utils/gen_token.js';
import axios from 'axios';

export const getUser = async (req, res) => {
  console.log("getUser called");

  const user = extractTokenInfo(req);
  if (!user) {
    return res.status(401).json({ message: "Unauthorized" });
  }

  const userId = user.userId;
  console.log(userId);

  try {
    const { rows } = await pool.query(
      'SELECT fname, lname FROM users WHERE id = $1',
      [userId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: "User not found" });
    }

    const fname = rows[0].fname;
    const lname = rows[0].lname;
    const initials = fname.charAt(0).toUpperCase() + lname.charAt(0).toUpperCase();

    const { rows: amountRows } = await pool.query(
      'SELECT SUM(amount) as total FROM transactions WHERE user_id = $1',
      [userId]
    );
    const amount = amountRows[0].total || 0;

    console.log({ fname, lname, initials, amount });
    res.status(200).json({ fname, lname, initials, amount });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Internal server error" });
  }
};

export const getUserTarget = async (req, res) => {
  console.log("getUserTarget called");

  const user = extractTokenInfo(req);
  if (!user) {
    return res.status(401).json({ message: "Unauthorized" });
  }

  const userId = user.userId;
  console.log(userId);
  try {
    const { rows } = await pool.query(
      'SELECT id, name, des, objective, current_amount, deadline FROM targets WHERE user_id = $1',
      [userId]
    );
  console.log(rows);
  return res.status(200).json(rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Internal server error" });
  }
}

export const createTarget = async (req, res) => {
  console.log("createTarget called");
  
  const user = extractTokenInfo(req);
  if (!user) {
    return res.status(401).json({ message: "Unauthorized" });
  }

  const userId = user.userId;
  console.log("User ID:", userId);
  
  // fine is now in percentage
  const { name, objective, deadline, fine, category } = req.body;
  
  if (!name || !objective || !deadline || fine === undefined || !category) {
    return res.status(400).json({ message: "All fields are required" });
  }

  try {
    // Fixed: Only 6 placeholders for 6 values
    const { rows } = await pool.query(
      'INSERT INTO targets (user_id, name, objective, deadline, fine, category) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
      [userId, name, objective, deadline, fine, category]
    );

    console.log("Created target:", rows[0]);
    res.status(201).json({
      message: "Target created successfully",
      target: rows[0]
    });
  } catch (error) {
    console.error("Database error:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};

export const depositeToTarget = async (req, res) => {
  console.log("depositeToTarget called");
  console.log(req.body);

  const user = extractTokenInfo(req);
  if (!user) {
    return res.status(401).json({ message: "Unauthorized" });
  }

  const userId = user.userId;
  console.log("User ID:", userId);

  const { targetId, amount, number } = req.body;

  if (!targetId || !amount || !number) {
    return res.status(400).json({ message: "All fields are required" });
  }

  // insert into transactions table
  // we will just insert into transactions table and then update the target table without any external api call
  try {
    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      const insertTransactionText = 'INSERT INTO transactions (targets_id, user_id, amount, trx_id, tell) VALUES ($1, $2, $3, $4, $5) RETURNING *';
      const insertTransactionValues = [targetId, userId, amount, "test"+ new Date(), number];
      const { rows: transactionRows } = await client.query(insertTransactionText, insertTransactionValues);
      console.log("Inserted transaction:", transactionRows[0]);

      const updateTargetText = 'UPDATE targets SET current_amount = current_amount + $1 WHERE id = $2 AND user_id = $3 RETURNING *';
      const updateTargetValues = [amount, targetId, userId];
      const { rows: targetRows } = await client.query(updateTargetText, updateTargetValues);

      if (targetRows.length === 0) {
        await client.query('ROLLBACK');
        return res.status(404).json({ message: "Target not found" });
      }

      await client.query('COMMIT');
      console.log("Updated target:", targetRows[0]);

      res.status(200).json({
        message: "Deposited to target successfully",
        transaction: transactionRows[0],
        target: targetRows[0]
      });
    } catch (error) {
      await client.query('ROLLBACK');
      console.error("Transaction error:", error);
      res.status(500).json({ message: "Internal server error" });
    } finally {
      client.release();
    }
  } catch (error) {
    console.error("Connection error:", error);
    res.status(500).json({ message: "Internal server error" });
  }
  
}