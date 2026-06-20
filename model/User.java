package model;

import java.util.ArrayList;
import java.util.List;

public class User {
    private String userName;
    private String password;
    private List<Album> albums;
    private List<Image> uploadImages;
    private boolean isBanned;     
    private boolean isAdmin;
    private boolean isLoggedIn;

    public User(String userName, String password) {
        this.userName = userName;
        this.password = password;
        this.albums = new ArrayList<>();
        this.uploadImages = new ArrayList<>();
        this.isBanned = false;
        this.isAdmin = false;
        this.isLoggedIn = false;
    }

    
    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public List<Album> getAlbums() {
        return albums;
    }

    public List<Image> getUploadImages() {
        return uploadImages;
    }

    public void addAlbum(Album album) {
        albums.add(album);
    }

    public void addImage(Image image) {
        uploadImages.add(image);
    }

    public boolean isBanned() {
        return isBanned;
    }

    public void setBanned(boolean isBanned) {
        this.isBanned = isBanned;
    }

    public boolean isAdmin() {
        return isAdmin;
    }

    public void setAdmin(boolean isAdmin) {
        this.isAdmin = isAdmin;
    }

    public boolean isLoggedIn() {
        return isLoggedIn;
    }

    public void setLoggedIn(boolean isLoggedIn) {
        this.isLoggedIn = isLoggedIn;
    }
}