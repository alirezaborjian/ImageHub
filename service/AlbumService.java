package service;

import java.util.ArrayList;
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
        boolean exists = user.getAlbums().stream().anyMatch(a -> a.getTitle().equalsIgnoreCase(title));
        if (exists) return null;

        Album album = new Album(title);
        user.addAlbum(album);
        return album;
    }

    public void deleteAlbum(User user, Album album) {
        user.getAlbums().remove(album);
    }

    public List<Image> sortImages(List<Image> imagesToSort, SortBy sortBy) {
        Comparator<Image> comparator;

        switch (sortBy) {
            case NAME:
                comparator = Comparator.comparing(Image::getName);
                break;
            case DATE:
                comparator = Comparator.comparing(Image::getUploadDate).reversed();
                break;
            case LIKES:
                comparator = Comparator.comparingInt(Image::getLikes).reversed();
                break;
            default:
                comparator = Comparator.comparing(Image::getName);
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
            sourceAlbum.removeImage(image);
            targetAlbum.addImage(image);
            return true;
        }
        return false;
    }
}