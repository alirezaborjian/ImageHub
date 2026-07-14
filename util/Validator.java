package util;

import model.User;

public class Validator {
    public static boolean isValidPassword(String username, String password) {
        if (password == null || password.length() < 8) {
            return false;
        }
        
        boolean hasUppercase = !password.equals(password.toLowerCase());
        boolean hasLowercase = !password.equals(password.toUpperCase());
        boolean hasDigit = password.matches(".*\\d.*");
        
        if (!hasUppercase || !hasLowercase || !hasDigit) {
            return false;
        }

        if (username != null && !username.isEmpty() && password.contains(username)) {
            return false;
        }

        return true;
    }

    public static boolean isValidPassword(User user) {
        if (user == null) return false;
        return isValidPassword(user.getUserName(), user.getPassword());
    }
}