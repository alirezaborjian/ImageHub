package service;

import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;
import model.Album;
import model.User;
import model.Image;

public class AlbumService {
    private List<Image> allImages;

    public enum SortBy {
        NAME,
        DATE,
        LIKES
    }

    public AlbumService(List<Image> allImages) {
        this.allImages = allImages;
    }

    public Album createAlbum(User user, String title) {
        boolean exists = user.getAlbums().stream().anyMatch(a -> a.getName().equalsIgnoreCase(title));
        if (exists) return null;

        String newId = String.valueOf(user.getAlbums().size() + 1);
        Album album = new Album(newId, title, user.getUserName());
        user.getAlbums().add(album);
        return album;
    }

    public void deleteAlbum(User user, Album album) {
        user.getAlbums().remove(album);
    }

    public List<Image> sortImages(List<Image> imagesToSort, SortBy sortBy) {
        Comparator<Image> comparator;

        switch (sortBy) {
            case NAME:
                comparator = Comparator.comparing(Image::getTitle);
                break;
            case DATE:
                comparator = Comparator.comparing(Image::getUploadDate).reversed();
                break;
            case LIKES:
                comparator = Comparator.comparingInt((Image img) -> img.getLikes().size()).reversed();
                break;
            default:
                comparator = Comparator.comparing(Image::getTitle);
        }

        return imagesToSort.stream()
                .sorted(comparator)
                .collect(Collectors.toList());
    }

    public boolean moveImageOtherAlbum(Album sourceAlbum, Album targetAlbum, Image image) {
        if (sourceAlbum == null || targetAlbum == null || image == null) {
            return false;
        }

        if (sourceAlbum.getImages().contains(image)) {
            sourceAlbum.getImages().remove(image);
            targetAlbum.getImages().add(image);
            return true;
        }
        return false;
    }
}