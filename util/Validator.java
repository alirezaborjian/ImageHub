package util;

import java.util.regex.Pattern;

public class Validator {
    public static boolean isValidPassword(String password, String userName) {
        if (password == null || userName == null) return false;

        String regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$";

        if (!Pattern.matches(regex, password)) {
            return false;
        }

        return !password.contains(userName);
    }
}