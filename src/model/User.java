package model;

import java.util.ArrayList;
import java.util.List;

public class User {
    private String id;
    private String userName;
    private String password;
    private String email;
    private boolean isAdmin;
    private List<Image> uploadImages;
    private List<Album> albums;

    public User() {
        this.uploadImages = new ArrayList<>();
        this.albums = new ArrayList<>();
    }

    public User(String id, String userName, String password, String email) {
        this.id = id;
        this.userName = userName;
        this.password = password;
        this.email = email;
        this.isAdmin = false;
        this.uploadImages = new ArrayList<>();
        this.albums = new ArrayList<>();
    }

    public User(String userName, String password) {
        this(null, userName, password, null);
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getUserName() {
        return userName;
    }

    public String getUsername() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public void setUsername(String username) {
        this.userName = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public boolean isAdmin() {
        return isAdmin;
    }

    public void setAdmin(boolean admin) {
        isAdmin = admin;
    }

    public List<Image> getUploadImages() {
        if (uploadImages == null) {
            uploadImages = new ArrayList<>();
        }
        return uploadImages;
    }

    public void setUploadImages(List<Image> uploadImages) {
        this.uploadImages = uploadImages;
    }

    public List<Album> getAlbums() {
        if (albums == null) {
            albums = new ArrayList<>();
        }
        return albums;
    }

    public void setAlbums(List<Album> albums) {
        this.albums = albums;
    }
}