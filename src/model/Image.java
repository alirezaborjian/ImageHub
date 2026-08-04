package model;

import java.util.ArrayList;
import java.util.List;

public class Image {
    private String id;
    private String title;
    private String path;
    private String ownerUsername;
    private String uploadDate;
    private List<String> likes;
    private List<Comment> comments;

    public Image() {
        this.likes = new ArrayList<>();
        this.comments = new ArrayList<>();
    }

    public Image(String id, String title, String path, String ownerUsername, String uploadDate) {
        this.id = id;
        this.title = title;
        this.path = path;
        this.ownerUsername = ownerUsername;
        this.uploadDate = uploadDate;
        this.likes = new ArrayList<>();
        this.comments = new ArrayList<>();
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getPath() {
        return path;
    }

    public String getImagePath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public String getOwnerUsername() {
        return ownerUsername;
    }

    public void setOwnerUsername(String ownerUsername) {
        this.ownerUsername = ownerUsername;
    }

    public String getUploadDate() {
        return uploadDate;
    }

    public void setUploadDate(String uploadDate) {
        this.uploadDate = uploadDate;
    }

    public List<String> getLikes() {
        if (likes == null) {
            likes = new ArrayList<>();
        }
        return likes;
    }

    public void setLikes(List<String> likes) {
        this.likes = likes;
    }

    public List<Comment> getComments() {
        if (comments == null) {
            comments = new ArrayList<>();
        }
        return comments;
    }

    public void setComments(List<Comment> comments) {
        this.comments = comments;
    }

    private List<String> tags = new ArrayList<>();

    public List<String> getTags() { return tags; }
    public void setTags(List<String> tags) { this.tags = tags; }
}