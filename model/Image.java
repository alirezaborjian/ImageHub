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

    public Image(String name, String caption) {
        this.name = name;
        this.caption = caption;
        this.uploadDate = LocalDateTime.now();
        this.likes = 0;
        this.tags = new ArrayList<>();
        this.comments = new ArrayList<>();
    }

    public void like() {
        likes++;
    }

    public void addTag(String tag) {
        tags.add(tag);
    }

    public void addComment(Comment comment) {
        comments.add(comment);
    }

    public String getName() {
        return name;
    }

    public int getLikes() {
        return likes;
    }

    public LocalDateTime getUploadDate() {
        return uploadDate;
    }

    public List<String> getTags() {
        return tags;
    }

    public List<Comment> getComments() {
        return comments;
    }

    public String getCaption(){
        return this.caption;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((name == null) ? 0 : name.hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        Image other = (Image) obj;
        if (name == null) {
            if (other.name != null)
                return false;
        } else if (!name.equals(other.name))
            return false;
        return true;
    }

    @Override
    public String toString() {
        return "Image [name=" + name + ", caption=" + caption + ", uploadDate=" + uploadDate + ", likes=" + likes
                + ", tags=" + tags + ", comments=" + comments + "]";
    }



    



    
}