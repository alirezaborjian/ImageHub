package service;

import model.User;
import util.DatabaseManager;

import java.util.List;

public class UserService {

    public String registerUser(String username, String password, String email, List<User> sharedUsers) {
        if (username == null || username.trim().isEmpty()) {
            return "{\"statusCode\": 400, \"message\": \"Username cannot be empty.\", \"payload\": null}";
        }

        if (password == null || password.length() < 6) {
            return "{\"statusCode\": 400, \"message\": \"Password must be at least 6 characters long.\", \"payload\": null}";
        }

        String trimmedUser = username.trim();

        synchronized (sharedUsers) {
            for (User user : sharedUsers) {
                if (user.getUserName() != null && user.getUserName().equalsIgnoreCase(trimmedUser)) {
                    return "{\"statusCode\": 400, \"message\": \"Username already exists.\", \"payload\": null}";
                }
            }

            String newId = String.valueOf(sharedUsers.size() + 1);
            User newUser = new User(newId, trimmedUser, password, email);
            sharedUsers.add(newUser);

            DatabaseManager.saveData(sharedUsers, DatabaseManager.loadImages());

            return "{\"statusCode\": 200, \"message\": \"User registered successfully!\", \"payload\": {\"id\": \"" + newId + "\", \"username\": \"" + trimmedUser + "\"}}";
        }
    }

    public String loginUser(String username, String password, List<User> sharedUsers) {
        if (username == null || password == null) {
            return "{\"statusCode\": 401, \"message\": \"Invalid credentials.\", \"payload\": null}";
        }

        String trimmedUser = username.trim();

        synchronized (sharedUsers) {
            for (User user : sharedUsers) {
                if (user.getUserName() != null && 
                    user.getUserName().equalsIgnoreCase(trimmedUser) && 
                    user.getPassword() != null && 
                    user.getPassword().equals(password)) {
                    
                    return "{\"statusCode\": 200, \"message\": \"Successfully logged in!\", \"payload\": {\"username\": \"" + user.getUserName() + "\", \"email\": \"" + (user.getEmail() != null ? user.getEmail() : "") + "\"}}";
                }
            }
        }

        return "{\"statusCode\": 401, \"message\": \"Invalid username or password.\", \"payload\": null}";
    }
}