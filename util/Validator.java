package util;

import java.util.regex.Pattern;
import model.User;

public class Validator {
    public static boolean isValidPassword(User newUser) {
        String pattern = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$";
        boolean patternCondition = newUser.getPassword().matches(pattern);
        boolean havingUserName = newUser.getPassword().contains(newUser.getUserName());
        return patternCondition && !havingUserName;
    }
}
