package service;

import model.*;
import util.Validator;

import java.util.List;


public class UserService {
    private List<User> users;

    public UserService(List<User> users) {
        this.users = users;
    }

    public void signup(User user) throws AuthException {
        if(user.isBanned()){
            System.out.println("You are banned.");
            return;
        }
        if (users.stream().anyMatch(u -> u.getUserName().equals(user.getUserName()))) {
            throw new AuthException("User already exists");
        }
        
        if (!Validator.isValidPassword(user)) {
            throw new AuthException("Invalid username or password.");
        }
        user.setLoggedIn(true);
        System.out.println("Successful sign up");
        users.add(user);
    }

    public void login(String username, String password) throws AuthException {
        User foundUser = users.stream()
            .filter(u -> u.getUserName().equals(username))
            .findFirst()
            .orElse(null);

        if (foundUser == null) {
            throw new AuthException("You are not registered.");
        }

        if(foundUser.isBanned()) {
            System.out.println("You are banned.");
            return;
        }
        
        if (!foundUser.getPassword().equals(password)) {
            throw new AuthException("Invalid password.");
        }
        foundUser.setLoggedIn(true);
        System.out.println("Successful log in.");
    }

    public List<User> getUsers() {
        return users;
    }


    public String getProfile(User user) {
        return String.format(" USERNAME: %s | NUMBER OF PHOTOES : %d | NUMBER OF ALBUMS : %d",
            user.getUserName(),
            user.getUploadImages().size(),
            user.getAlbums().size());
    }

    public boolean changeName(User user, String newUserName) {
        if (newUserName == null || newUserName.trim().isEmpty()) {
            System.out.println("Error!!!");
            return false;
        }
        user.setUserName(newUserName);
        System.out.println("Successful");
        return true;

    }
    

    public boolean changePassword(User user, String oldPassword, String newPassword) {

        if (!user.getPassword().equals(oldPassword)) {
            System.out.println("Your last password isn't correct!");
            return false;
        }

        if (!Validator.isValidPassword(user)) {
            System.out.println("Your new password isn't valid");
            return false;
        }
        
        
        user.setPassword(newPassword);
        System.out.println("Successful");
        return true;
    }

    public boolean deleteAccount(User user, String enteredUsername, String enteredPassword) {
        if (!user.getUserName().equals(enteredUsername)) 
            return false;
        if (!user.getPassword().equals(enteredPassword)) 
            return false;

        user.getUploadImages().clear();
        user.getAlbums().clear();
        user.setUserName(null);
        user.setPassword(null);
        users.remove(user);
    
        return true;
    }

    public void logout(User user) {
        user.setLoggedIn(false);
        System.out.println("با موفقیت خارج شدید");
    }

    
}