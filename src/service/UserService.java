package service;

import model.User;
import util.DatabaseManager;

import java.util.List;

public class UserService {

    public String registerUser(String username, String password, String email) {
        if (username == null || username.trim().isEmpty()) {
            return "{\"statusCode\": 400, \"message\": \"Username cannot be empty.\", \"payload\": null}";
        }

        if (password == null || password.length() < 8) {
            return "{\"statusCode\": 400, \"message\": \"Password does not meet security requirements.\", \"payload\": null}";
        }

        List<User> users = DatabaseManager.loadUsers();
        for (User user : users) {
            if (user.getUserName().equalsIgnoreCase(username.trim())) {
                return "{\"statusCode\": 400, \"message\": \"Username already exists.\", \"payload\": null}";
            }
        }

        String newId = String.valueOf(users.size() + 1);
        User newUser = new User(newId, username.trim(), password, email);
        users.add(newUser);

        DatabaseManager.saveData(users, DatabaseManager.loadImages());

        return "{\"statusCode\": 200, \"message\": \"User registered successfully!\", \"payload\": {\"id\": \"" + newId + "\", \"username\": \"" + username + "\"}}";
    }

    public String loginUser(String username, String password) {
        if (username == null || password == null) {
            return "{\"statusCode\": 401, \"message\": \"Invalid credentials.\", \"payload\": null}";
        }

        List<User> users = DatabaseManager.loadUsers();
        for (User user : users) {
            if (user.getUserName().equalsIgnoreCase(username.trim()) && user.getPassword().equals(password)) {
                return "{\"statusCode\": 200, \"message\": \"Successfully logged in!\", \"payload\": {\"username\": \"" + user.getUserName() + "\", \"email\": \"" + user.getEmail() + "\"}}";
            }
        }

        return "{\"statusCode\": 401, \"message\": \"Invalid username or password.\", \"payload\": null}";
    }
}