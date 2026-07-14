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
            user.setBanned(true); 
            user.setLoggedIn(false); 
        }
    }

    public synchronized void unbanUser(User user) {
        if (user != null && bannedUsers.contains(user)) {
            bannedUsers.remove(user);
            user.setBanned(false);
        }
    }

    public int checkNumberOfAlbums(User user){
        return user.getAlbums().size();
    }

    public int checkNumberOfImages(User user) {
        return user.getUploadImages().size();
    }
}