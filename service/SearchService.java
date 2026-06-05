package service;

import model.Image;
import java.util.ArrayList;
import java.util.List;

public class SearchService {
    private List<Image> allImages;

    public SearchService(List<Image> allImages) {
        this.allImages = allImages;
    }

    public List<Image> searchByName(String query) {
        List<Image> results = new ArrayList<>();
        for (Image img : allImages) {
            if (img.getName().toLowerCase().contains(query.toLowerCase())) {
                results.add(img);
            }
        }
        return results;
    }

    public List<Image> searchByTag(String tag) {
        List<Image> results = new ArrayList<>();
        for (Image img : allImages) {
            if (img.getTags().contains(tag)) {
                results.add(img);
            }
        }
        return results;
    }
}