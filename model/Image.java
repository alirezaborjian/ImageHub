package model;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class Image {
    private String name;
    private String caption;
    private LocalDateTime uploadDate;
    private int likes;
    private List<String> tags;
    private List<Comment> comments;
    private List<String> albumTitles;

    public Image(String name, String caption) {
        this.name = name;
        this.caption = caption;
        this.uploadDate = LocalDateTime.now();
        this.likes = 0;
        this.tags = new ArrayList<>();
        this.comments = new ArrayList<>();
        this.albumTitles = new ArrayList<>();
    }

    public void like() { this.likes++; }
    public void addTag(String tag) { this.tags.add(tag); }
    public void addComment(Comment comment) { this.comments.add(comment); }

    public void addAlbumTitle(String title) {
        if (!albumTitles.contains(title)) { albumTitles.add(title); }
    }

    public void removeAlbumTitle(String title) { albumTitles.remove(title); }

    public String getName() { return name; }
    public String getCaption() { return caption; }
    public LocalDateTime getUploadDate() { return uploadDate; }
    public int getLikes() { return likes; }
    public List<String> getTags() { return tags; }
    public List<Comment> getComments() { return comments; }
    public List<String> getAlbumTitles() { return albumTitles; }
}