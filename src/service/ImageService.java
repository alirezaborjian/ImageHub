package service;

import model.Image;
import model.User;

import java.util.ArrayList;
import java.util.List;

public class ImageService {
    private List<Image> allImages;

    public ImageService(List<Image> allImages) {
        this.allImages = allImages;
    }

    public void uploadImage(User user, Image image) {
        if (user != null && image != null) {
            allImages.add(image);
            if (user.getUploadImages() == null) {
                user.setUploadImages(new ArrayList<>());
            }
            user.getUploadImages().add(image);
        }
    }

    public void likeImage(Image image, String username) {
        if (image != null && username != null) {
            if (image.getLikes() == null) {
                image.setLikes(new ArrayList<>());
            }
            if (image.getLikes().contains(username)) {
                image.getLikes().remove(username);
            } else {
                image.getLikes().add(username);
            }
        }
    }

    public void addComment(Image image, String username, String commentText) {
        if (image != null && username != null && commentText != null) {
            if (image.getComments() == null) {
                image.setComments(new ArrayList<>());
            }
            image.getComments().add(new model.Comment(username, commentText));
        }
    }

    public void addTag(Image image, String tag) {
        if (image != null && tag != null && !tag.trim().isEmpty()) {
            if (image.getTags() == null) {
                image.setTags(new ArrayList<>());
            }
            if (!image.getTags().contains(tag.trim())) {
                image.getTags().add(tag.trim());
            }
        }
    }
}