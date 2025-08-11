import jwt from 'jsonwebtoken';

const secretKey = process.env.JWT_SECRET;

export const  generateTokenAndSetCookie = (res, userId, userRole) => {
    const token = jwt.sign({ userId, role:userRole}, secretKey, {
        expiresIn: "7d",
    })
    res.cookie("token", token, {
        httpOnly: true,
        secure: process.env.NODE_ENV === "production",
        sameSite: "strict",
        maxAge: 7 * 24 * 60 * 60 * 1000,    
    });
    return token;
}