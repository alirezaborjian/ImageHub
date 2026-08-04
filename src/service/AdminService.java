package service;

import model.User;
import java.util.Set;

public class AdminService {
    private final Set<User> bannedUsers;

    public AdminService(Set<User> bannedUsers) {
        this.bannedUsers = bannedUsers;
    }

    public synchronized void banUser(User user) {
        if (user != null && !bannedUsers.contains(user)) {
            bannedUsers.add(user);
        }
    }

    public synchronized void unbanUser(User user) {
        if (user != null) {
            bannedUsers.remove(user);
        }
    }

    public int checkNumberOfAlbums(User user) {
        if (user == null || user.getAlbums() == null) {
            return 0;
        }
        return user.getAlbums().size();
    }

    public int checkNumberOfImages(User user) {
        if (user == null || user.getUploadImages() == null) {
            return 0;
        }
        return user.getUploadImages().size();
    }
}