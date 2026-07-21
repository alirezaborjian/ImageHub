package service;

import model.User;
import java.util.Set;

public class AdminService {
    private Set<User> bannedUsers;

    public AdminService(Set<User> bannedUsers) {
        this.bannedUsers = bannedUsers;
    }

    public synchronized void banUser(User user) {
        if (user != null && !bannedUsers.contains(user)) {
            bannedUsers.add(user);
        }
    }

    public synchronized void unbanUser(User user) {
        if (user != null && bannedUsers.contains(user)) {
            bannedUsers.remove(user);
        }
    }

    public int checkNumberOfAlbums(User user) {
        return user.getAlbums().size();
    }

    public int checkNumberOfImages(User user) {
        return user.getUploadImages().size();
    }
}