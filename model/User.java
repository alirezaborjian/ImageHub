package model;

import java.util.ArrayList;
import java.util.List;

public class User {
    private String userName;
    private String password;
    private List<Album> albums;
    private List<Image> uploadImages;
    private boolean isBanned;

    public User(String userName, String password) {
        this.userName = userName;
        this.password = password;
        this.albums = new ArrayList<>();
        this.uploadImages = new ArrayList<>();
        this.isBanned = false;
    }

    public String getUserName() { return userName; }
    public String getPassword() { return password; }
    public List<Album> getAlbums() { return albums; }
    public List<Image> getUploadImages() { return uploadImages; }

    public boolean isBanned() { return isBanned; }
    public void setBanned(boolean banned) { this.isBanned = banned; }

    public void addAlbum(Album album) { albums.add(album); }
    public void addImage(Image image) { uploadImages.add(image); }
}