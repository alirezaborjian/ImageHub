package service;

import model.User;
import util.Validator;
import java.util.List;

public class UserService {
    private List<User> users;

    public UserService(List<User> users) {
        this.users = users;
    }

    public void signup(User user) throws AuthException {
        if (user.isBanned()) {
            throw new AuthException("This user is banned.");
        }
        if (users.stream().anyMatch(u -> u.getUserName().equalsIgnoreCase(user.getUserName()))) {
            throw new AuthException("User already exists.");
        }
        if (!Validator.isValidPassword(user.getUserName(), user.getPassword())) {
            throw new AuthException("Password does not meet requirements (8+ chars, upper, lower, digits, no username).");
        }
        
        user.setLoggedIn(true);
        users.add(user);
    }

    public User login(String username, String password) throws AuthException {
        User foundUser = users.stream()
            .filter(u -> u.getUserName().equalsIgnoreCase(username))
            .findFirst()
            .orElse(null);

        if (foundUser == null) {
            throw new AuthException("You are not registered.");
        }

        if (foundUser.isBanned()) {
            throw new AuthException("You are banned by admin.");
        }
        
        if (!foundUser.getPassword().equals(password)) {
            throw new AuthException("Invalid password.");
        }
        
        foundUser.setLoggedIn(true);
        return foundUser; 
    }

    public List<User> getUsers() {
        return users;
    }

    public String getProfile(User user) {
        return String.format("USERNAME: %s | NUMBER OF PHOTOS: %d | NUMBER OF ALBUMS: %d",
            user.getUserName(),
            user.getUploadImages().size(),
            user.getAlbums().size());
    }

    public boolean changeName(User user, String newUserName) {
        if (newUserName == null || newUserName.trim().isEmpty()) {
            return false;
        }
        boolean exists = users.stream().anyMatch(u -> u.getUserName().equalsIgnoreCase(newUserName));
        if (exists) {
            return false;
        }
        user.setUserName(newUserName);
        return true;
    }

    public boolean changePassword(User user, String oldPassword, String newPassword) {
        if (!user.getPassword().equals(oldPassword)) {
            return false;
        }
        if (!Validator.isValidPassword(user.getUserName(), newPassword)) {
            return false;
        }
        
        user.setPassword(newPassword);
        return true;
    }

    public boolean deleteAccount(User user, String enteredUsername, String enteredPassword) {
        if (!user.getUserName().equals(enteredUsername) || !user.getPassword().equals(enteredPassword)) {
            return false;
        }

        user.getUploadImages().clear();
        user.getAlbums().clear();
        users.remove(user);
        return true;
    }

    public void logout(User user) {
        if (user != null) {
            user.setLoggedIn(false);
        }
    }
}