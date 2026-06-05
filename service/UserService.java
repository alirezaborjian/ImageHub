package service;

import model.User;
import java.util.HashMap;
import java.util.Map;

public class UserService {
    private Map<String, User> users = new HashMap<>();

    public boolean registerUser(String userName, String password) {
        if (users.containsKey(userName)) {
            return false;
        }
        User newUser = new User(userName, password);
        users.put(userName, newUser);
        return true;
    }

    public User loginUser(String userName, String password) {
        User user = users.get(userName);
        if (user != null && user.getPassword().equals(password)) {
            if (user.isBanned()) {
                return null;
            }
            return user;
        }
        return null;
    }

    public User getUser(String userName) {
        return users.get(userName);
    }
}