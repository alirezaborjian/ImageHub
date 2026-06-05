package service;

import model.User;

public class AdminService {
    public void banUser(User user) {
        user.setBanned(true);
    }

    public void unbanUser(User user) {
        user.setBanned(false);
    }
}