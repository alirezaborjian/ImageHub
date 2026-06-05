package service;

import model.*;

import java.util.ArrayList;
import java.util.List;

public class ImageService {
    private List<Image> allImages;

    public ImageService(List<Image> allImages) {
        this.allImages = allImages;
    }

    public void uploadImage(User user, Image image) {
        user.addImage(image);
        allImages.add(image);
    }

    public void likeImage(Image image) {
        image.like();
    }

    public void addComment(Image image, String userName, String text) {
        image.addComment(new Comment(userName, text));
    }
}