package model;

import java.util.ArrayList;
import java.util.List;

public class Album {
    private String id;
    private String name;
    private String ownerUsername;
    private List<Image> images;

    public Album() {
        this.images = new ArrayList<>();
    }

    public Album(String id, String name, String ownerUsername) {
        this.id = id;
        this.name = name;
        this.ownerUsername = ownerUsername;
        this.images = new ArrayList<>();
    }

    public String getId() { 
        return id; 
    }
    
    public void setId(String id) { 
        this.id = id; 
    }

    public String getName() { 
        return name; 
    }
    
    public void setName(String name) { 
        this.name = name; 
    }

    public String getOwnerUsername() { 
        return ownerUsername; 
    }
    
    public void setOwnerUsername(String ownerUsername) { 
        this.ownerUsername = ownerUsername; 
    }

    public List<Image> getImages() {
        if (images == null) {
            images = new ArrayList<>();
        }
        return images;
    }

    public void setImages(List<Image> images) {
        this.images = images;
    }

    public void addImage(Image image) {
        getImages().add(image);
    }

    public void removeImage(Image image) {
        getImages().remove(image);
    }
}