package util;

import model.User;
import java.util.regex.Pattern;

public class Validator {

    private static final Pattern PASSWORD_PATTERN = Pattern.compile("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$");

    public static boolean isValidUsername(String username) {
        return username != null && !username.trim().isEmpty();
    }

    public static boolean isValidPassword(String username, String password) {
        if (password == null || password.isEmpty()) {
            return false;
        }

        if (username != null && !username.trim().isEmpty()) {
            if (password.toLowerCase().contains(username.trim().toLowerCase())) {
                return false;
            }
        }

        return PASSWORD_PATTERN.matcher(password).matches();
    }

    public static boolean isValidPassword(User user) {
        if (user == null) {
            return false;
        }
        String username = user.getUserName() != null ? user.getUserName() : user.getUsername();
        return isValidPassword(username, user.getPassword());
    }
}