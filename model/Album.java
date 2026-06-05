package model;

import java.util.ArrayList;
import java.util.List;

public class Album {
    private String title;
    private List<Image> images;

    public Album(String title) {
        this.title = title;
        this.images = new ArrayList<>();
    }

    public String getTitle() {
        return title;
    }

    public List<Image> getImages() {
        return images;
    }

    public void addImage(Image image) {
        images.add(image);
    }

    public void removeImage(Image image) {
        images.remove(image);
    }
}
