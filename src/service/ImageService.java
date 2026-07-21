package service;

import model.*;
import java.util.List;
import java.util.stream.Collectors;

public class ImageService {
    private List<Image> allImages;

    public enum SearchType {
        NAME,
        DATE,
        COMMENT,
        ALL
    }

    public ImageService(List<Image> allImages) {
        this.allImages = allImages;
    }

    public void uploadImage(User user, Image image) {
        user.getUploadImages().add(image);
        allImages.add(image);
    }

    public void likeImage(Image image, String username) {
        if (!image.getLikes().contains(username)) {
            image.getLikes().add(username);
        } else {
            image.getLikes().remove(username);
        }
    }

    public void addComment(Image image, String userName, String text) {
        image.getComments().add(new Comment(userName, text));
    }

    public List<Image> search(SearchType type, String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return allImages;
        }

        String lowerKeyword = keyword.toLowerCase();

        switch (type) {
            case NAME:
                return allImages.stream()
                        .filter(img -> img.getTitle() != null && img.getTitle().toLowerCase().contains(lowerKeyword))
                        .collect(Collectors.toList());

            case COMMENT:
                return allImages.stream()
                        .filter(img -> img.getComments() != null && img.getComments().stream()
                                .anyMatch(c -> c.getText() != null && c.getText().toLowerCase().contains(lowerKeyword)))
                        .collect(Collectors.toList());

            case DATE:
                return allImages.stream()
                        .filter(img -> img.getUploadDate() != null && img.getUploadDate().contains(keyword))
                        .collect(Collectors.toList());

            case ALL:
                return allImages.stream()
                        .filter(img ->
                                (img.getTitle() != null && img.getTitle().toLowerCase().contains(lowerKeyword)) ||
                                        (img.getComments() != null && img.getComments().stream().anyMatch(c -> c.getText() != null && c.getText().toLowerCase().contains(lowerKeyword))) ||
                                        (img.getUploadDate() != null && img.getUploadDate().contains(keyword))
                        )
                        .collect(Collectors.toList());

            default:
                return allImages;
        }
    }
}