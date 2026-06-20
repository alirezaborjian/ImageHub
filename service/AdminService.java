package service;

import model.User;

import java.util.Set;

public class AdminService {
    private Set<User> bannedUsers;

    public AdminService(Set<User> bannedUsers) {
        this.bannedUsers = bannedUsers;
    }

    public void banUser(User user) {
        if(!bannedUsers.contains(user)){
            bannedUsers.add(user);
            user.setBanned(true); 
        }
    }

    public int checkNumberOfAlbums(User user){
        return user.getAlbums().size();
    }

    public int checkNumberOfImages(User user) {
        return user.getUploadImages().size();
    }
}
