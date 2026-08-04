package model;

import java.util.ArrayList;
import java.util.List;

public class Image {
    private String id;
    private String title;
    private String imagePath;
    private String uploader;
    private String uploadDate;
    private String caption; 
    private List<String> likes;
    private List<String> tags;
    private List<Comment> comments;

    public Image() {
        this.caption = "";
        this.likes = new ArrayList<>();
        this.tags = new ArrayList<>();
        this.comments = new ArrayList<>();
    }

    public Image(String id, String title, String imagePath, String uploader, String uploadDate) {
        this.id = id;
        this.title = title;
        this.imagePath = imagePath;
        this.uploader = uploader;
        this.uploadDate = uploadDate;
        this.caption = "";
        this.likes = new ArrayList<>();
        this.tags = new ArrayList<>();
        this.comments = new ArrayList<>();
    }

    public String getCaption() {
        return caption;
    }

    public void setCaption(String caption) {
        this.caption = caption;
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

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    public String getUploader() {
        return uploader;
    }

    public void setUploader(String uploader) {
        this.uploader = uploader;
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

    public List<String> getTags() {
        if (tags == null) {
            tags = new ArrayList<>();
        }
        return tags;
    }

    public void setTags(List<String> tags) {
        this.tags = tags;
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
}