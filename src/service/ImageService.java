package service;

import model.Comment;
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
        if (image != null && username != null && !username.trim().isEmpty()) {
            if (image.getLikes() == null) {
                image.setLikes(new ArrayList<>());
            }
            String cleanUsername = username.trim();
            if (image.getLikes().contains(cleanUsername)) {
                image.getLikes().remove(cleanUsername);
            } else {
                image.getLikes().add(cleanUsername);
            }
        }
    }

    public void addComment(Image image, String username, String commentText) {
        if (image != null && username != null && commentText != null && !commentText.trim().isEmpty()) {
            if (image.getComments() == null) {
                image.setComments(new ArrayList<>());
            }
            image.getComments().add(new Comment(username.trim(), commentText.trim()));
        }
    }

    public void addTag(Image image, String tag) {
        if (image != null && tag != null && !tag.trim().isEmpty()) {
            if (image.getTags() == null) {
                image.setTags(new ArrayList<>());
            }
            String cleanTag = tag.trim();
            if (!image.getTags().contains(cleanTag)) {
                image.getTags().add(cleanTag);
            }
        }
    }
}