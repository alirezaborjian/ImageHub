package service;

import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;
import model.Album;
import model.User;
import model.Image;

public class AlbumService {
    private final List<Image> allImages;

    public enum SortBy {
        NAME,
        DATE,
        LIKES
    }

    public AlbumService(List<Image> allImages) {
        this.allImages = allImages;
    }

    public Album createAlbum(User user, String title) {
        if (user == null || title == null || title.trim().isEmpty()) {
            return null;
        }

        boolean exists = user.getAlbums().stream()
                .anyMatch(a -> a.getName() != null && a.getName().equalsIgnoreCase(title.trim()));
        
        if (exists) {
            return null;
        }

        String newId = String.valueOf(user.getAlbums().size() + 1);
        Album album = new Album(newId, title.trim(), user.getUserName());
        user.getAlbums().add(album);
        return album;
    }

    public void deleteAlbum(User user, Album album) {
        if (user != null && album != null) {
            user.getAlbums().remove(album);
        }
    }

    public List<Image> sortImages(List<Image> imagesToSort, SortBy sortBy) {
        if (imagesToSort == null) {
            return List.of();
        }

        Comparator<Image> comparator;

        switch (sortBy) {
            case NAME:
                comparator = Comparator.comparing(
                    Image::getTitle, 
                    Comparator.nullsLast(String.CASE_INSENSITIVE_ORDER)
                );
                break;
            case DATE:
                comparator = Comparator.comparing(
                    Image::getUploadDate, 
                    Comparator.nullsLast(Comparator.naturalOrder())
                ).reversed();
                break;
            case LIKES:
                comparator = Comparator.comparingInt(
                    (Image img) -> img.getLikes() != null ? img.getLikes().size() : 0
                ).reversed();
                break;
            default:
                comparator = Comparator.comparing(
                    Image::getTitle, 
                    Comparator.nullsLast(String.CASE_INSENSITIVE_ORDER)
                );
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